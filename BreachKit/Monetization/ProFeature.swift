import Foundation

/// Paid capabilities. Free tier stays useful; Pro deepens tracking without paywalling privacy.
enum ProFeature: String, CaseIterable, Identifiable, Sendable {
    case unlimitedWatches
    case reminderLadder
    case customSettlements
    case walletShare

    var id: String { rawValue }

    var title: String {
        switch self {
        case .unlimitedWatches: return "Unlimited watches"
        case .reminderLadder: return "Smarter deadline ladder"
        case .customSettlements: return "Custom settlements"
        case .walletShare: return "Share your Wallet card"
        }
    }

    var detail: String {
        switch self {
        case .unlimitedWatches:
            return "Watch every open window that matters — Free includes \(FreeTierLimits.maxWatches)."
        case .reminderLadder:
            return "Local reminders at 7, 3, and 1 day before a deadline — not just one ping."
        case .customSettlements:
            return "Add settlements that aren’t in the catalog yet — company, amount, deadline."
        case .walletShare:
            return "Export a clean Wallet summary image to Messages or Notes."
        }
    }

    var systemImage: String {
        switch self {
        case .unlimitedWatches: return "infinity"
        case .reminderLadder: return "bell.badge"
        case .customSettlements: return "plus.rectangle.on.folder"
        case .walletShare: return "square.and.arrow.up"
        }
    }
}

enum FreeTierLimits {
    /// Generous enough to feel the product; scarce enough that power users upgrade.
    static let maxWatches = 3
    /// Free: single reminder 3 days out. Pro: 7 / 3 / 1.
    static let freeReminderDaysBefore: [Int] = [3]
    static let proReminderDaysBefore: [Int] = [7, 3, 1]
}

enum AppPricing {
    static let monthlyUSD = "3.99"
    static let yearlyUSD = "24.99"
    static let monthlyTrial = "7-day free trial"
    static let annualTrial = "7-day free trial"
}
