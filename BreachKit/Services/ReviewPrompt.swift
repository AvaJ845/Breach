import Foundation

/// Asks for an App Store rating only at a "happy moment" — after the user
/// successfully marks a claim, never at launch or after an error. At most once
/// per app version, after `threshold` successful claim actions.
enum ReviewPrompt {
    static let threshold = 2
    private static let countKey = "breachkit.review.successCount"
    private static let versionKey = "breachkit.review.lastPromptedVersion"

    static func registerSuccessAndShouldRequest(
        defaults: UserDefaults = .standard,
        version: String = currentVersion
    ) -> Bool {
        let count = defaults.integer(forKey: countKey) + 1
        defaults.set(count, forKey: countKey)

        guard count >= threshold else { return false }
        guard defaults.string(forKey: versionKey) != version else { return false }

        defaults.set(version, forKey: versionKey)
        return true
    }

    static var currentVersion: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(short) (\(build))"
    }
}
