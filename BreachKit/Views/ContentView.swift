import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var store = BreachStore()
    @State private var entitlements = EntitlementStore()
    @State private var selectedTab: Tab = .wallet
    @State private var showOnboarding = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var paywallReason: String?
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
            if !hasOnboarded {
                showOnboarding = true
            } else {
                store.seedDemoWalletIfNeeded()
            }
            store.refreshExpiredStatuses()
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
    }
}

#Preview {
    ContentView()
}
