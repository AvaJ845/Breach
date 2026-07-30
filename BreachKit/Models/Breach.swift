import Foundation

/// A publicly described settlement opportunity.
/// Amounts are guidance ranges — official claim sites are the source of truth.
struct Breach: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let company: String
    let title: String
    let summary: String
    /// Midpoint / typical estimate — never a guarantee.
    let estimatedPayout: Double
    /// Optional honest range for Apple-grade humility.
    let awardMin: Double?
    let awardMax: Double?
    let deadline: Date
    let requiresProof: Bool
    let category: Category
    let dataTypes: [String]
    let claimURL: URL?
    /// Secondary citation (press release, court docket, admin FAQ).
    let citationURL: URL?
    let year: Int
    let source: Source
    let trust: Trust
    let eligibilitySteps: [String]
    let payoutCaveat: String
    /// When this listing was last human-reviewed (ISO from feed).
    let lastReviewed: Date?

    enum Source: String, Codable, Sendable {
        case curated
        case custom
        case remote

        var label: String {
            switch self {
            case .curated: return "Bundled catalog"
            case .custom: return "Added by you"
            case .remote: return "Live catalog feed"
            }
        }
    }

    /// How much we stand behind the listing — shown prominently.
    enum Trust: String, Codable, Sendable, CaseIterable {
        /// Official administrator / court page linked and reviewed.
        case administratorLinked = "administrator_linked"
        /// Public reporting; admin link may be general.
        case curatedPublic = "curated_public"
        /// Explicitly illustrative for demo / offline.
        case samplePreview = "sample_preview"
        case userProvided = "user_provided"

        var label: String {
            switch self {
            case .administratorLinked: return "Admin-linked"
            case .curatedPublic: return "Curated public"
            case .samplePreview: return "Sample preview"
            case .userProvided: return "You added"
            }
        }

        var detail: String {
            switch self {
            case .administratorLinked:
                return "Reviewed against a linked official claim administrator or court notice. Still verify eligibility yourself."
            case .curatedPublic:
                return "Organized from public reporting. Confirm every detail on the official claim site before filing."
            case .samplePreview:
                return "Illustrative listing for organizing practice — not a live settlement notice."
            case .userProvided:
                return "You entered this. Breach Kit does not verify it."
            }
        }

        var symbol: String {
            switch self {
            case .administratorLinked: return "checkmark.seal.fill"
            case .curatedPublic: return "doc.text.magnifyingglass"
            case .samplePreview: return "eye.slash"
            case .userProvided: return "person.crop.circle.badge.plus"
            }
        }
    }

    enum Category: String, Codable, CaseIterable, Sendable {
        case consumer, healthcare, finance, tech, retail

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

    var displayEstimate: String {
        if let min = awardMin, let max = awardMax, max > min {
            return "~\(Formatters.money(min))–\(Formatters.money(max))"
        }
        return "~\(Formatters.money(estimatedPayout))"
    }

    init(
        id: String,
        company: String,
        title: String,
        summary: String,
        estimatedPayout: Double,
        awardMin: Double? = nil,
        awardMax: Double? = nil,
        deadline: Date,
        requiresProof: Bool,
        category: Category,
        dataTypes: [String],
        claimURL: URL?,
        citationURL: URL? = nil,
        year: Int,
        source: Source = .curated,
        trust: Trust = .samplePreview,
        eligibilitySteps: [String]? = nil,
        payoutCaveat: String = "Estimate only — not guaranteed",
        lastReviewed: Date? = nil
    ) {
        self.id = id
        self.company = company
        self.title = title
        self.summary = summary
        self.estimatedPayout = estimatedPayout
        self.awardMin = awardMin
        self.awardMax = awardMax
        self.deadline = deadline
        self.requiresProof = requiresProof
        self.category = category
        self.dataTypes = dataTypes
        self.claimURL = claimURL
        self.citationURL = citationURL
        self.year = year
        self.source = source
        self.trust = trust
        self.eligibilitySteps = eligibilitySteps ?? Breach.defaultSteps(requiresProof: requiresProof)
        self.payoutCaveat = payoutCaveat
        self.lastReviewed = lastReviewed
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        company = try c.decode(String.self, forKey: .company)
        title = try c.decode(String.self, forKey: .title)
        summary = try c.decode(String.self, forKey: .summary)
        estimatedPayout = try c.decode(Double.self, forKey: .estimatedPayout)
        awardMin = try c.decodeIfPresent(Double.self, forKey: .awardMin)
        awardMax = try c.decodeIfPresent(Double.self, forKey: .awardMax)
        deadline = try c.decode(Date.self, forKey: .deadline)
        requiresProof = try c.decode(Bool.self, forKey: .requiresProof)
        category = try c.decode(Category.self, forKey: .category)
        dataTypes = try c.decode([String].self, forKey: .dataTypes)
        claimURL = try c.decodeIfPresent(URL.self, forKey: .claimURL)
        citationURL = try c.decodeIfPresent(URL.self, forKey: .citationURL)
        year = try c.decode(Int.self, forKey: .year)
        source = try c.decodeIfPresent(Source.self, forKey: .source)
            ?? (id.hasPrefix("custom-") ? .custom : .curated)
        trust = try c.decodeIfPresent(Trust.self, forKey: .trust)
            ?? (id.hasPrefix("custom-") ? .userProvided : .samplePreview)
        let decodedSteps = try c.decodeIfPresent([String].self, forKey: .eligibilitySteps)
        eligibilitySteps = decodedSteps ?? Breach.defaultSteps(requiresProof: requiresProof)
        payoutCaveat = try c.decodeIfPresent(String.self, forKey: .payoutCaveat) ?? "Estimate only — not guaranteed"
        lastReviewed = try c.decodeIfPresent(Date.self, forKey: .lastReviewed)
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
    case watching, notified, claimed, paid, expired

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
        default: return false
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
    var trackedEstimates: Double
    var claimedCount: Int
    var notifiedCount: Int
    var watchingCount: Int
    var paidCount: Int
    var estimatedPayout: Double { trackedEstimates }
}

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
    var catalogSyncedAt: Date?
    var catalogTrustSummary: String?
}
