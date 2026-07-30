import SwiftUI

struct SettingsView: View {
    @Bindable var store: BreachStore
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
                Section("Reminders") {
                    Toggle("Deadline reminders", isOn: $store.notifyDeadlines)
                        .onChange(of: store.notifyDeadlines) { _, enabled in
                            store.persistSettings()
                            Task {
                                await NotificationService.scheduleDeadlineReminders(
                                    for: store.activeClaims,
                                    enabled: enabled
                                )
                            }
                        }
                    Text("Local notifications only — three days before a watched claim’s deadline.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Privacy") {
                    LabeledContent("Account") {
                        Text("None")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Tracking") {
                        Text("Off")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Email scans") {
                        Text("On-device")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Legal") {
                    Button("Privacy Policy") { legalDoc = .privacy }
                    Button("Terms of Use") { legalDoc = .terms }
                    Button("Open Privacy Policy online") {
                        openURL(AppLegal.privacyPolicyURL)
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "Breach Kit")
                    LabeledContent("Version", value: appVersion)
                    Button("Support & marketing site") {
                        openURL(AppLegal.marketingURL)
                    }
                }

                Section {
                    Text("Breach Kit organizes publicly described settlement opportunities. It does not file claims for you, provide legal advice, or guarantee payment.")
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
                switch doc {
                case .privacy:
                    LegalDocumentView(title: "Privacy Policy", resourceName: AppLegal.privacyResourceName)
                case .terms:
                    LegalDocumentView(title: "Terms of Use", resourceName: AppLegal.termsResourceName)
                }
            }
        }
    }

    private var appVersion: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(short) (\(build))"
    }
}
