import Foundation

/// A publicly described settlement opportunity users can organize and claim.
/// Amounts and steps are guidance — official claim sites are the source of truth.
struct Breach: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let company: String
    let title: String
    let summary: String
    /// Typical / illustrative award amount — never a guarantee.
    let estimatedPayout: Double
    let deadline: Date
    let requiresProof: Bool
    let category: Category
    let dataTypes: [String]
    let claimURL: URL?
    let year: Int
    /// Where this listing came from.
    let source: Source
    /// User-facing checklist to finish a claim (help them act, not just track).
    let eligibilitySteps: [String]
    /// Honest framing under the dollar amount.
    let payoutCaveat: String

    enum Source: String, Codable, Sendable {
        case curated
        case custom

        var label: String {
            switch self {
            case .curated: return "Curated listing"
            case .custom: return "Added by you"
            }
        }

        var detail: String {
            switch self {
            case .curated:
                return "Organized from publicly described settlements. Verify every detail on the official claim site."
            case .custom:
                return "You added this. Breach Kit doesn’t verify it — use the official administrator."
            }
        }
    }

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

    init(
        id: String,
        company: String,
        title: String,
        summary: String,
        estimatedPayout: Double,
        deadline: Date,
        requiresProof: Bool,
        category: Category,
        dataTypes: [String],
        claimURL: URL?,
        year: Int,
        source: Source = .curated,
        eligibilitySteps: [String]? = nil,
        payoutCaveat: String = "Estimate only — not guaranteed"
    ) {
        self.id = id
        self.company = company
        self.title = title
        self.summary = summary
        self.estimatedPayout = estimatedPayout
        self.deadline = deadline
        self.requiresProof = requiresProof
        self.category = category
        self.dataTypes = dataTypes
        self.claimURL = claimURL
        self.year = year
        self.source = source
        self.eligibilitySteps = eligibilitySteps ?? Breach.defaultSteps(requiresProof: requiresProof)
        self.payoutCaveat = payoutCaveat
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        company = try c.decode(String.self, forKey: .company)
        title = try c.decode(String.self, forKey: .title)
        summary = try c.decode(String.self, forKey: .summary)
        estimatedPayout = try c.decode(Double.self, forKey: .estimatedPayout)
        deadline = try c.decode(Date.self, forKey: .deadline)
        requiresProof = try c.decode(Bool.self, forKey: .requiresProof)
        category = try c.decode(Category.self, forKey: .category)
        dataTypes = try c.decode([String].self, forKey: .dataTypes)
        claimURL = try c.decodeIfPresent(URL.self, forKey: .claimURL)
        year = try c.decode(Int.self, forKey: .year)
        source = try c.decodeIfPresent(Source.self, forKey: .source) ?? (id.hasPrefix("custom-") ? .custom : .curated)
        let decodedSteps = try c.decodeIfPresent([String].self, forKey: .eligibilitySteps)
        eligibilitySteps = decodedSteps ?? Breach.defaultSteps(requiresProof: requiresProof)
        payoutCaveat = try c.decodeIfPresent(String.self, forKey: .payoutCaveat) ?? "Estimate only — not guaranteed"
    }

    static func defaultSteps(requiresProof: Bool) -> [String] {
        var steps = [
            "Confirm you may be in the class (dates, product, or account)",
            "Open the official claim site from this listing",
            "Read eligibility and award tiers carefully",
            "Submit the claim before the deadline",
            "Save your confirmation number in Notes"
        ]
        if requiresProof {
            steps.insert("Gather receipts or proof if you want a higher tier", at: 3)
        }
        return steps
    }
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
    /// Indices of completed eligibility checklist steps.
    var completedSteps: [Int]

    init(
        breachID: String,
        status: ClaimStatus = .watching,
        notedAt: Date = .now,
        claimedAt: Date? = nil,
        notes: String = "",
        completedSteps: [Int] = []
    ) {
        self.breachID = breachID
        self.status = status
        self.notedAt = notedAt
        self.claimedAt = claimedAt
        self.notes = notes
        self.completedSteps = completedSteps
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        breachID = try c.decode(String.self, forKey: .breachID)
        status = try c.decode(ClaimStatus.self, forKey: .status)
        notedAt = try c.decode(Date.self, forKey: .notedAt)
        claimedAt = try c.decodeIfPresent(Date.self, forKey: .claimedAt)
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        completedSteps = try c.decodeIfPresent([Int].self, forKey: .completedSteps) ?? []
    }

    func checklistProgress(total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(Set(completedSteps).count) / Double(total)
    }
}

struct WalletSummary: Equatable, Sendable {
    /// Sum of tracked estimate amounts — guidance only.
    var trackedEstimates: Double
    var claimedCount: Int
    var notifiedCount: Int
    var watchingCount: Int
    var paidCount: Int

    /// Back-compat alias used in older call sites.
    var estimatedPayout: Double { trackedEstimates }
}

/// Snapshot shared with the Home Screen widget / App Intents.
struct DeadlineSnapshot: Codable, Hashable, Sendable {
    var company: String
    var amount: Double
    var deadline: Date
    var statusLabel: String
    var breachID: String
}

struct WalletGlanceSnapshot: Codable, Hashable, Sendable {
    var trackedEstimates: Double
    var watchingCount: Int
    var dueSoonCount: Int
    var next: DeadlineSnapshot?
    var updatedAt: Date
}
