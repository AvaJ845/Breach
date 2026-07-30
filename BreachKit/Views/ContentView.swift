import SwiftUI

struct ContentView: View {
    @State private var store = BreachStore()
    @State private var selectedTab: Tab = .wallet
    @State private var showOnboarding = false
    @State private var showSettings = false
    @AppStorage("breachkit.hasOnboarded") private var hasOnboarded = false

    enum Tab: Hashable {
        case wallet, settlements, scan
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            WalletView(store: store, showSettings: $showSettings)
                .tabItem { Label("Wallet", systemImage: "creditcard") }
                .tag(Tab.wallet)

            BreachListView(store: store, showSettings: $showSettings)
                .tabItem { Label("Settlements", systemImage: "list.bullet.rectangle") }
                .tag(Tab.settlements)

            EmailScanView(store: store, showSettings: $showSettings)
                .tabItem { Label("Scan", systemImage: "envelope.badge.shield.half.filled") }
                .tag(Tab.scan)
        }
        .tint(Theme.accent)
        .sheet(isPresented: $showSettings) {
            SettingsView(store: store)
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasOnboarded = true
                showOnboarding = false
                store.seedDemoWalletIfNeeded()
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
            await NotificationService.scheduleDeadlineReminders(
                for: store.activeClaims,
                enabled: store.notifyDeadlines
            )
        }
    }
}

#Preview {
    ContentView()
}
