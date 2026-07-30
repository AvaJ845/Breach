import SwiftUI
import StoreKit

struct WalletView: View {
    @Bindable var store: BreachStore
    @Bindable var entitlements: EntitlementStore
    @Binding var showSettings: Bool
    var onBrowseSettlements: () -> Void
    var onShowPaywall: (String) -> Void

    @Environment(\.requestReview) private var requestReview
    @State private var path = NavigationPath()
    @State private var sharePayload: SharePayload?

    private struct SharePayload: Identifiable {
        let id = UUID()
        let text: String
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if store.activeClaims.isEmpty && store.finishedClaims.isEmpty {
                    emptyState
                } else {
                    listContent
                }
            }
            .navigationTitle("Wallet")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !store.activeClaims.isEmpty || !store.finishedClaims.isEmpty {
                        Button {
                            if entitlements.unlocks(.walletShare) {
                                sharePayload = SharePayload(text: store.walletShareText())
                                Haptics.light()
                            } else {
                                onShowPaywall("Share your Wallet summary with Breach Kit Pro.")
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share Wallet")
                    }
                }
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
            .sheet(item: $sharePayload) { payload in
                ShareSheet(items: [payload.text])
            }
        }
    }

    private var listContent: some View {
        List {
            Section {
                WalletSummaryCard(summary: store.summary)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            if !store.dueThisWeek.isEmpty {
                Section("Due this week") {
                    ForEach(store.dueThisWeek, id: \.breach.id) { pair in
                        Button {
                            path.append(pair.breach.id)
                        } label: {
                            ClaimRowView(breach: pair.breach, claim: pair.claim)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens settlement details")
                    }
                }
            }

            if !store.activeClaims.isEmpty {
                Section {
                    ForEach(store.activeClaims, id: \.breach.id) { pair in
                        Button {
                            path.append(pair.breach.id)
                        } label: {
                            ClaimRowView(breach: pair.breach, claim: pair.claim)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if pair.claim.status != .claimed && pair.claim.status != .paid {
                                Button("Claimed") {
                                    markClaimed(pair.breach.id)
                                }
                                .tint(Theme.claimed)
                            }
                        }
                        .accessibilityHint("Opens settlement details. Swipe to mark claimed.")
                    }
                } header: {
                    Text("In progress")
                } footer: {
                    if !entitlements.isPro {
                        Text("Free includes \(FreeTierLimits.maxWatches) watches · \(store.watchCount) used")
                    }
                }
            }

            if !store.finishedClaims.isEmpty {
                Section("Finished") {
                    ForEach(store.finishedClaims, id: \.breach.id) { pair in
                        Button {
                            path.append(pair.breach.id)
                        } label: {
                            ClaimRowView(breach: pair.breach, claim: pair.claim)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Your wallet is empty", systemImage: "tray")
        } description: {
            Text("Browse open settlements and tap Watch to track estimated recovery here.")
        } actions: {
            Button("Browse settlements") {
                Haptics.light()
                onBrowseSettlements()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
        }
    }

    private func markClaimed(_ id: String) {
        let happy = store.markClaimed(id)
        Haptics.success()
        if happy, ReviewPrompt.registerSuccessAndShouldRequest() {
            requestReview()
        }
        Task {
            await NotificationService.scheduleDeadlineReminders(
                for: store.activeClaims,
                enabled: store.notifyDeadlines,
                offsets: entitlements.reminderOffsets
            )
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
