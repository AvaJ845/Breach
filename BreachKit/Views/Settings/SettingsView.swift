import SwiftUI

struct SettingsView: View {
    @Bindable var store: BreachStore
    @Bindable var entitlements: EntitlementStore
    var onShowPaywall: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var legalDoc: LegalDoc?

    private enum LegalDoc: String, Identifiable {
        case privacy, terms
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Breach Kit Pro") {
                    if entitlements.isPro {
                        Label("Pro active", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                        Text("7/3/1-day reminders · custom settlements · Wallet share · weekly digest")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Button(action: onShowPaywall) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Upgrade to Pro")
                                    .font(.headline)
                                Text("$\(AppPricing.monthlyUSD)/mo after a 7-day free trial · or $\(AppPricing.yearlyUSD)/yr")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Reminders") {
                    Toggle("Deadline reminders", isOn: $store.notifyDeadlines)
                        .onChange(of: store.notifyDeadlines) { _, _ in
                            store.persistSettings()
                            Task { await reschedule() }
                        }
                    Text(
                        entitlements.unlocks(.reminderLadder)
                            ? "Pro ladder: local pings at 7, 3, and 1 day before a deadline."
                            : "Free: one local ping 3 days before. Pro adds a 7/3/1-day ladder."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                    if entitlements.unlocks(.weeklyDigest) {
                        Toggle("Weekly due-soon digest", isOn: $store.weeklyDigestEnabled)
                            .onChange(of: store.weeklyDigestEnabled) { _, _ in
                                store.persistSettings()
                                Task { await reschedule() }
                            }
                        Text("Sundays at 10:00 — a calm list of what’s due in 14 days.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Button("Unlock weekly digest with Pro") {
                            onShowPaywall()
                        }
                    }
                }

                Section("Privacy") {
                    LabeledContent("Account") { Text("None").foregroundStyle(.secondary) }
                    LabeledContent("Tracking") { Text("Off").foregroundStyle(.secondary) }
                    LabeledContent("Email scans") { Text("On-device").foregroundStyle(.secondary) }
                    LabeledContent("Widget data") { Text("On-device App Group").foregroundStyle(.secondary) }
                }

                Section("Legal") {
                    Button("Privacy Policy") { legalDoc = .privacy }
                    Button("Terms of Use") { legalDoc = .terms }
                    Button("Open Privacy Policy online") { openURL(AppLegal.privacyPolicyURL) }
                }

                Section("About") {
                    LabeledContent("App", value: "Breach Kit")
                    LabeledContent("Version", value: appVersion)
                    Button("Support & marketing site") { openURL(AppLegal.marketingURL) }
                }

                Section {
                    Text("Breach Kit organizes publicly described settlement opportunities and helps you finish claim checklists. It does not file claims, provide legal advice, or guarantee payment.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $legalDoc) { doc in
                NavigationStack {
                    switch doc {
                    case .privacy:
                        LegalDocumentView(
                            title: "Privacy Policy",
                            resourceName: AppLegal.privacyResourceName,
                            showsDoneButton: true
                        )
                    case .terms:
                        LegalDocumentView(
                            title: "Terms of Use",
                            resourceName: AppLegal.termsResourceName,
                            showsDoneButton: true
                        )
                    }
                }
            }
        }
    }

    private var appVersion: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(short) (\(build))"
    }

    private func reschedule() async {
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
