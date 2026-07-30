import Foundation

/// A known data breach / class-action settlement users can track or claim.
struct Breach: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let company: String
    let title: String
    let summary: String
    let estimatedPayout: Double
    let deadline: Date
    let requiresProof: Bool
    let category: Category
    let dataTypes: [String]
    let claimURL: URL?
    let year: Int

    enum Category: String, Codable, CaseIterable, Sendable {
        case consumer
        case healthcare
        case finance
        case tech
        case retail

        var label: String {
            switch self {
            case .consumer: return "Consumer"
            case .healthcare: return "Healthcare"
            case .finance: return "Finance"
            case .tech: return "Technology"
            case .retail: return "Retail"
            }
        }

        var symbol: String {
            switch self {
            case .consumer: return "person.2.fill"
            case .healthcare: return "cross.case.fill"
            case .finance: return "building.columns.fill"
            case .tech: return "desktopcomputer"
            case .retail: return "bag.fill"
            }
        }
    }

    var isOpen: Bool { deadline > .now }
}

enum ClaimStatus: String, Codable, CaseIterable, Sendable {
    case watching
    case notified
    case claimed
    case paid
    case expired

    var label: String {
        switch self {
        case .watching: return "Watching"
        case .notified: return "Notified"
        case .claimed: return "Claimed"
        case .paid: return "Paid"
        case .expired: return "Expired"
        }
    }

    var symbol: String {
        switch self {
        case .watching: return "eye"
        case .notified: return "bell.badge"
        case .claimed: return "checkmark.circle.fill"
        case .paid: return "banknote.fill"
        case .expired: return "clock.badge.xmark"
        }
    }

    var isActive: Bool {
        switch self {
        case .watching, .notified, .claimed: return true
        case .paid, .expired: return false
        }
    }

    var isFinished: Bool {
        switch self {
        case .paid, .expired: return true
        case .watching, .notified, .claimed: return false
        }
    }
}

struct Claim: Identifiable, Hashable, Codable, Sendable {
    var id: String { breachID }
    let breachID: String
    var status: ClaimStatus
    var notedAt: Date
    var claimedAt: Date?
    var notes: String

    init(
        breachID: String,
        status: ClaimStatus = .watching,
        notedAt: Date = .now,
        claimedAt: Date? = nil,
        notes: String = ""
    ) {
        self.breachID = breachID
        self.status = status
        self.notedAt = notedAt
        self.claimedAt = claimedAt
        self.notes = notes
    }
}

struct WalletSummary: Equatable, Sendable {
    var estimatedPayout: Double
    var claimedCount: Int
    var notifiedCount: Int
    var watchingCount: Int
    var paidCount: Int
}
