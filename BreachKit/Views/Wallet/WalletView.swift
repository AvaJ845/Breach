import SwiftUI
import StoreKit

struct WalletView: View {
    @Bindable var store: BreachStore
    @Binding var showSettings: Bool
    @Environment(\.requestReview) private var requestReview
    @State private var path = NavigationPath()

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
                    BreachDetailView(store: store, breach: breach)
                }
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

            if !store.activeClaims.isEmpty {
                Section("In progress") {
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
            // Tab switching is handled by the parent; this keeps the CTA honest.
            Text("Open the Settlements tab to start.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func markClaimed(_ id: String) {
        let happy = store.markClaimed(id)
        if happy, ReviewPrompt.registerSuccessAndShouldRequest() {
            requestReview()
        }
        Task {
            await NotificationService.scheduleDeadlineReminders(
                for: store.activeClaims,
                enabled: store.notifyDeadlines
            )
        }
    }
}
