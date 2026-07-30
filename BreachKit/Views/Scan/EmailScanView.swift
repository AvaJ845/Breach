import SwiftUI
import StoreKit

struct EmailScanView: View {
    @Bindable var store: BreachStore
    @Bindable var entitlements: EntitlementStore
    @Binding var showSettings: Bool
    var onShowPaywall: (String) -> Void

    @Environment(\.requestReview) private var requestReview
    @State private var email = ""
    @State private var results: [Breach] = []
    @State private var didScan = false
    @State private var isScanning = false
    @State private var path = NavigationPath()
    @FocusState private var emailFocused: Bool

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    intro
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section("Email to check") {
                    TextField("you@example.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .focused($emailFocused)
                        .submitLabel(.search)
                        .onSubmit { runScan() }

                    Button {
                        runScan()
                    } label: {
                        HStack {
                            if isScanning {
                                ProgressView()
                            }
                            Text(isScanning ? "Scanning on-device…" : "Scan privately")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isValidEmail || isScanning)
                }

                if didScan {
                    Section {
                        if results.isEmpty {
                            ContentUnavailableView(
                                "No catalog matches",
                                systemImage: "checkmark.shield",
                                description: Text("This curated catalog didn’t flag that address. Add settlements manually from Settlements — or keep watching the feed.")
                            )
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(results) { breach in
                                Button {
                                    path.append(breach.id)
                                } label: {
                                    BreachRowView(breach: breach, status: store.status(for: breach.id))
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing) {
                                    Button("Watch") {
                                        watchFromScan(breach)
                                    }
                                    .tint(Theme.accent)
                                }
                            }
                        }
                    } header: {
                        Text(results.isEmpty ? "Results" : "\(results.count) possible matches")
                    } footer: {
                        Text("Scan runs on-device against Breach Kit’s curated catalog — not a live breach database. Your email is never uploaded.")
                    }
                }

                if !store.watchedEmails.isEmpty {
                    Section("Saved addresses") {
                        ForEach(store.watchedEmails, id: \.self) { saved in
                            Button {
                                email = saved
                                runScan()
                            } label: {
                                Label(saved, systemImage: "envelope")
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.removeWatchedEmail(saved)
                                } label: {
                                    Text("Remove")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Scan")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(for: String.self) { id in
                if let breach = store.breach(id: id) {
                    BreachDetailView(
                        store: store,
                        entitlements: entitlements,
                        breach: breach,
                        onShowPaywall: onShowPaywall
                    )
                }
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Private by design", systemImage: "lock.shield.fill")
                .font(.headline)
                .foregroundStyle(Theme.accent)
            Text("Check whether addresses you use appear in known settlement catalogs — without creating an account or sending mail off-device.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.accent.opacity(0.08))
        )
    }

    private var isValidEmail: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".")
    }

    private func runScan() {
        emailFocused = false
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidEmail else { return }

        isScanning = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(450))
            results = store.scan(email: trimmed)
            didScan = true
            store.addWatchedEmail(trimmed)
            isScanning = false
            if !results.isEmpty {
                Haptics.success()
                if ReviewPrompt.registerSuccessAndShouldRequest() {
                    requestReview()
                }
            } else {
                Haptics.light()
            }
        }
    }

    private func watchFromScan(_ breach: Breach) {
        if store.wouldCountAsNewWatch(for: breach.id),
           !entitlements.canWatchMore(currentWatchCount: store.watchCount) {
            onShowPaywall("You've used all \(FreeTierLimits.maxWatches) free watches. Unlock unlimited with Pro.")
            return
        }
        store.watch(breach)
        store.markNotified(breach.id)
        Haptics.success()
        Task {
            await NotificationService.scheduleDeadlineReminders(
                for: store.activeClaims,
                enabled: store.notifyDeadlines,
                offsets: entitlements.reminderOffsets
            )
        }
    }
}
