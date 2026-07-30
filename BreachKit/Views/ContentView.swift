import SwiftUI

struct ContentView: View {
    let notificationDelegate: NotificationDelegate

    @State private var store = BreachStore()
    @State private var entitlements = EntitlementStore()
    @State private var selectedTab: Tab = .wallet
    @State private var showOnboarding = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var paywallReason: String?
    @State private var deepLinkBreachID: String?
    @AppStorage("breachkit.hasOnboarded") private var hasOnboarded = false

    enum Tab: Hashable {
        case wallet, settlements, scan
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            WalletView(
                store: store,
                entitlements: entitlements,
                showSettings: $showSettings,
                onBrowseSettlements: { selectedTab = .settlements },
                onShowPaywall: { reason in
                    paywallReason = reason
                    showPaywall = true
                }
            )
            .tabItem { Label("Wallet", systemImage: "creditcard") }
            .tag(Tab.wallet)

            BreachListView(
                store: store,
                entitlements: entitlements,
                showSettings: $showSettings,
                onShowPaywall: { reason in
                    paywallReason = reason
                    showPaywall = true
                }
            )
            .tabItem { Label("Settlements", systemImage: "list.bullet.rectangle") }
            .tag(Tab.settlements)

            EmailScanView(
                store: store,
                entitlements: entitlements,
                showSettings: $showSettings,
                onShowPaywall: { reason in
                    paywallReason = reason
                    showPaywall = true
                }
            )
            .tabItem { Label("Scan", systemImage: "envelope.badge.shield.half.filled") }
            .tag(Tab.scan)
        }
        .tint(Theme.accent)
        .sheet(isPresented: $showSettings) {
            SettingsView(
                store: store,
                entitlements: entitlements,
                onShowPaywall: {
                    showSettings = false
                    paywallReason = nil
                    showPaywall = true
                }
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(entitlements: entitlements, reason: paywallReason)
        }
        .sheet(item: Binding(
            get: { deepLinkBreachID.map { DeepLink($0) } },
            set: { deepLinkBreachID = $0?.id }
        )) { link in
            if let breach = store.breach(id: link.id) {
                NavigationStack {
                    BreachDetailView(
                        store: store,
                        entitlements: entitlements,
                        breach: breach,
                        onShowPaywall: { reason in
                            paywallReason = reason
                            showPaywall = true
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { deepLinkBreachID = nil }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasOnboarded = true
                showOnboarding = false
                store.seedDemoWalletIfNeeded()
                Task {
                    _ = await NotificationService.requestAuthorizationIfNeeded()
                    await rescheduleReminders()
                }
            }
        }
        .onAppear {
            notificationDelegate.store = store
            if !hasOnboarded {
                showOnboarding = true
            } else {
                store.seedDemoWalletIfNeeded()
            }
            store.refreshExpiredStatuses()
            store.publishGlance()
        }
        .onReceive(NotificationCenter.default.publisher(for: .breachKitOpenBreach)) { note in
            if let id = note.userInfo?["breachID"] as? String {
                selectedTab = .wallet
                deepLinkBreachID = id
            }
        }
        .task {
            await entitlements.loadProducts()
            await rescheduleReminders()
        }
        .onChange(of: entitlements.isPro) { _, _ in
            Task { await rescheduleReminders() }
        }
    }

    private func rescheduleReminders() async {
        await NotificationService.scheduleDeadlineReminders(
            for: store.activeClaims,
            enabled: store.notifyDeadlines,
            offsets: entitlements.reminderOffsets
        )
        await NotificationService.scheduleWeeklyDigest(
            dueSoon: store.dueSoonFourteenDays,
            enabled: entitlements.unlocks(.weeklyDigest) && store.weeklyDigestEnabled
        )
    }
}

private struct DeepLink: Identifiable {
    let id: String
    init(_ id: String) { self.id = id }
}

#Preview {
    ContentView(notificationDelegate: NotificationDelegate())
}
