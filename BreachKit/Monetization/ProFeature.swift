import Foundation

/// Paid capabilities. Free stays fully useful for organizing claims;
/// Pro deepens reminders and power tools — never paywalls privacy or basic help.
enum ProFeature: String, CaseIterable, Identifiable, Sendable {
    case reminderLadder
    case customSettlements
    case walletShare
    case weeklyDigest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .reminderLadder: return "Smarter deadline ladder"
        case .customSettlements: return "Custom settlements"
        case .walletShare: return "Share your Wallet summary"
        case .weeklyDigest: return "Weekly due-soon digest"
        }
    }

    var detail: String {
        switch self {
        case .reminderLadder:
            return "Local reminders at 7, 3, and 1 day before a deadline — Free includes a 3-day ping."
        case .customSettlements:
            return "Add settlements that aren’t in the curated catalog yet."
        case .walletShare:
            return "Export a clean Wallet summary to Messages or Notes."
        case .weeklyDigest:
            return "A Sunday local digest of everything due in the next 14 days."
        }
    }

    var systemImage: String {
        switch self {
        case .reminderLadder: return "bell.badge"
        case .customSettlements: return "plus.rectangle.on.folder"
        case .walletShare: return "square.and.arrow.up"
        case .weeklyDigest: return "calendar.badge.clock"
        }
    }
}

enum FreeTierLimits {
    /// North Star: watching settlements is core help — not artificially scarce.
    static let maxWatches = Int.max
    static let freeReminderDaysBefore: [Int] = [3]
    static let proReminderDaysBefore: [Int] = [7, 3, 1]
}

enum AppPricing {
    static let monthlyUSD = "3.99"
    static let yearlyUSD = "24.99"
    static let monthlyTrial = "7-day free trial"
    static let annualTrial = "7-day free trial"
}
