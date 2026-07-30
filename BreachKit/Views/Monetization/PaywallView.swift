import StoreKit
import SwiftUI
import UIKit

struct PaywallView: View {
    @Bindable var entitlements: EntitlementStore
    var reason: String? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var manageError: String?
    @State private var legalPath: LegalRoute?

    private enum LegalRoute: String, Identifiable, Hashable {
        case privacy, terms
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Breach Kit Pro")
                            .font(.title2.weight(.bold))
                        Text("Optional upgrade for power helpers. Core watching and checklists stay free — Pro deepens reminders and tools.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let reason, !reason.isEmpty {
                            Text(reason)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.accent)
                                .padding(.top, 2)
                                .accessibilityLabel("Why this screen: \(reason)")
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Always free") {
                    Label("Browse curated settlements", systemImage: "list.bullet.rectangle")
                    Label("Unlimited watches & claim checklists", systemImage: "checklist")
                    Label("On-device email scan", systemImage: "lock.shield")
                    Label("3-day deadline reminder", systemImage: "bell")
                    Label("Home Screen due-soon widget", systemImage: "rectangle.on.rectangle")
                    Label("Private notes — never leave the phone", systemImage: "note.text")
                }

                Section("Pro adds") {
                    ForEach(ProFeature.allCases) { feature in
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(feature.title)
                                Text(feature.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: feature.systemImage)
                                .foregroundStyle(Theme.accent)
                        }
                    }
                }

                Section {
                    if entitlements.isLoading && entitlements.products.isEmpty {
                        HStack {
                            ProgressView()
                            Text("Loading App Store products…")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Monthly first — primary Fellow pricing decision.
                    if let monthly = entitlements.monthlyProduct {
                        purchaseButton(
                            monthly,
                            badge: "\(AppPricing.monthlyTrial), then \(monthly.displayPrice)/month",
                            highlighted: true,
                            badgeLabel: "PRIMARY"
                        )
                    }

                    if let yearly = entitlements.yearlyProduct {
                        let savings = entitlements.yearlySavingsPercent.map { " · save \($0)%" } ?? ""
                        purchaseButton(
                            yearly,
                            badge: "\(AppPricing.annualTrial), then \(yearly.displayPrice)/year\(savings)",
                            badgeLabel: "BEST VALUE"
                        )
                    }

                    if entitlements.products.isEmpty && !entitlements.isLoading {
                        VStack(alignment: .leading, spacing: 8) {
                            fairPriceRow(
                                label: "Pro Monthly",
                                price: "$\(AppPricing.monthlyUSD)/month",
                                note: "7-day free trial · primary plan"
                            )
                            fairPriceRow(
                                label: "Pro Yearly",
                                price: "$\(AppPricing.yearlyUSD)/year",
                                note: "7-day free trial · best value"
                            )
                            Text("Live purchase appears once products are in App Store Connect and Products.storekit is attached. Until then, use Debug unlock for QA.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Choose your plan")
                } footer: {
                    Text(subscriptionFooter)
                }

                Section("Legal") {
                    Button("Privacy Policy") { legalPath = .privacy }
                    Button("Terms of Use") { legalPath = .terms }
                    Link(
                        "Apple Standard EULA",
                        destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
                    )
                }

                Section {
                    Button("Restore purchases") {
                        Task { await entitlements.restore() }
                    }
                    Button("Manage subscription") {
                        Task { await manageSubscriptions() }
                    }
                    if entitlements.isPro {
                        Label("Pro active", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    }
                    if let error = entitlements.lastError ?? manageError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                #if DEBUG
                Section("Debug") {
                    Toggle(
                        "Unlock Pro (local QA)",
                        isOn: Binding(
                            get: { entitlements.debugUnlocked },
                            set: { entitlements.setDebugUnlocked($0) }
                        )
                    )
                }
                #endif
            }
            .navigationTitle("Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await entitlements.loadProducts() }
            .navigationDestination(item: $legalPath) { route in
                switch route {
                case .privacy:
                    LegalDocumentView(title: "Privacy Policy", resourceName: AppLegal.privacyResourceName)
                case .terms:
                    LegalDocumentView(title: "Terms of Use", resourceName: AppLegal.termsResourceName)
                }
            }
        }
    }

    private var subscriptionFooter: String {
        """
        Breach Kit Pro is an auto-renewable subscription: \
        Monthly ($\(AppPricing.monthlyUSD)/month, with a 7-day free trial) or Yearly ($\(AppPricing.yearlyUSD)/year, with a 7-day free trial). \
        Payment is charged to your Apple ID at purchase confirmation; a free trial converts to a paid period unless cancelled \
        at least 24 hours before it ends. Subscriptions renew unless cancelled at least 24 hours before the period ends. \
        Manage or cancel in Settings → Apple ID → Subscriptions. \
        Pro unlocks tracking convenience only — never legal advice, never claim filing, never a payment guarantee.
        """
    }

    private func purchaseButton(
        _ product: Product,
        badge: String,
        highlighted: Bool = false,
        badgeLabel: String
    ) -> some View {
        Button {
            Task {
                let ok = await entitlements.purchase(product)
                if ok {
                    Haptics.success()
                    dismiss()
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.headline)
                        Text(badgeLabel)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Theme.accent.opacity(highlighted ? 0.22 : 0.12), in: Capsule())
                            .foregroundStyle(Theme.accent)
                    }
                    Text(badge)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Theme.accent)
            }
        }
        .disabled(entitlements.isPro)
        .accessibilityLabel("\(product.displayName), \(badgeLabel), \(badge)")
        .accessibilityHint("Auto-renewable subscription")
    }

    private func fairPriceRow(label: String, price: String, note: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(price)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(Theme.accent)
        }
    }

    private func manageSubscriptions() async {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        do {
            try await AppStore.showManageSubscriptions(in: scene)
        } catch {
            manageError = error.localizedDescription
        }
    }
}
