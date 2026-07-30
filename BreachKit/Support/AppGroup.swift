import Foundation

/// Shared storage between the app, widget, and App Intents.
/// Falls back to standard defaults if the App Group isn't provisioned.
enum AppGroup {
    static let identifier = "group.com.avaresearch.breachkit"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}

enum SharedStorage {
    private static let glanceKey = "breachkit.glance.v1"

    static func saveGlance(_ snapshot: WalletGlanceSnapshot) {
        if let data = try? JSONEncoder().encode(snapshot) {
            AppGroup.defaults.set(data, forKey: glanceKey)
        }
    }

    static func loadGlance() -> WalletGlanceSnapshot? {
        guard let data = AppGroup.defaults.data(forKey: glanceKey) else { return nil }
        return try? JSONDecoder().decode(WalletGlanceSnapshot.self, from: data)
    }
}
