import SwiftUI

struct SettingsView: View {
    @Bindable var store: BreachStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

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

                Section("About") {
                    LabeledContent("App", value: "Breach Kit")
                    LabeledContent("Version", value: appVersion)
                    Button("Privacy Policy") {
                        if let url = URL(string: "https://avaj845.github.io/BreachKit/privacy.html") {
                            openURL(url)
                        }
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
        }
    }

    private var appVersion: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(short) (\(build))"
    }
}
