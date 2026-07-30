import Foundation
import Observation

/// Local-first claim tracker. Persists to UserDefaults — no account, no cloud.
@Observable
@MainActor
final class BreachStore {
    private static let claimsKey = "breachkit.claims.v1"
    private static let customBreachesKey = "breachkit.customBreaches.v1"
    private static let watchedEmailsKey = "breachkit.watchedEmails.v1"
    private static let notifyDeadlinesKey = "breachkit.notifyDeadlines"

    private let defaults: UserDefaults
    private let catalogBreaches: [Breach]

    private(set) var customBreaches: [Breach] = []
    private(set) var claims: [String: Claim] = [:]
    var watchedEmails: [String] = []
    var notifyDeadlines: Bool = true

    init(defaults: UserDefaults = .standard, breaches: [Breach] = SampleBreaches.catalog) {
        self.defaults = defaults
        self.catalogBreaches = breaches
        load()
    }

    var breaches: [Breach] {
        (catalogBreaches + customBreaches).sorted { $0.deadline < $1.deadline }
    }

    var openBreaches: [Breach] {
        breaches.filter(\.isOpen)
    }

    /// Active watches that count toward the Free tier cap.
    var watchCount: Int {
        claims.values.filter { $0.status.isActive }.count
    }

    var summary: WalletSummary {
        var estimated = 0.0
        var claimed = 0
        var notified = 0
        var watching = 0
        var paid = 0

        for claim in claims.values {
            guard let breach = breach(id: claim.breachID) else { continue }
            switch claim.status {
            case .watching:
                watching += 1
                if breach.isOpen { estimated += breach.estimatedPayout }
            case .notified:
                notified += 1
                if breach.isOpen { estimated += breach.estimatedPayout }
            case .claimed:
                claimed += 1
                estimated += breach.estimatedPayout
            case .paid:
                paid += 1
                estimated += breach.estimatedPayout
            case .expired:
                break
            }
        }

        return WalletSummary(
            estimatedPayout: estimated,
            claimedCount: claimed,
            notifiedCount: notified,
            watchingCount: watching,
            paidCount: paid
        )
    }

    func breach(id: String) -> Breach? {
        breaches.first { $0.id == id }
    }

    func claim(for breachID: String) -> Claim? {
        claims[breachID]
    }

    func status(for breachID: String) -> ClaimStatus? {
        claims[breachID]?.status
    }

    var activeClaims: [(breach: Breach, claim: Claim)] {
        pairedClaims.filter { $0.claim.status.isActive }
            .sorted { $0.breach.deadline < $1.breach.deadline }
    }

    var finishedClaims: [(breach: Breach, claim: Claim)] {
        pairedClaims.filter { $0.claim.status.isFinished }
            .sorted { ($0.claim.claimedAt ?? $0.claim.notedAt) > ($1.claim.claimedAt ?? $1.claim.notedAt) }
    }

    var dueThisWeek: [(breach: Breach, claim: Claim)] {
        let week = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
        return activeClaims.filter { $0.breach.deadline <= week && $0.breach.isOpen }
    }

    private var pairedClaims: [(breach: Breach, claim: Claim)] {
        claims.values.compactMap { claim in
            guard let breach = breach(id: claim.breachID) else { return nil }
            return (breach, claim)
        }
    }

    /// Returns nil if already watching; returns the new claim otherwise.
    @discardableResult
    func watch(_ breach: Breach) -> Claim {
        ensureBreachKnown(breach)
        if var existing = claims[breach.id] {
            if existing.status == .expired {
                existing.status = .watching
                existing.notedAt = .now
                claims[breach.id] = existing
                persist()
            }
            return claims[breach.id]!
        }
        let claim = Claim(breachID: breach.id, status: .watching)
        claims[breach.id] = claim
        persist()
        return claim
    }

    func wouldCountAsNewWatch(for breachID: String) -> Bool {
        guard let existing = claims[breachID] else { return true }
        return existing.status == .expired
    }

    func addCustomBreach(
        company: String,
        title: String,
        estimatedPayout: Double,
        deadline: Date,
        requiresProof: Bool,
        category: Breach.Category
    ) -> Breach {
        let id = "custom-\(UUID().uuidString)"
        let breach = Breach(
            id: id,
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            summary: "Custom settlement you added. Verify details on the official claim site.",
            estimatedPayout: estimatedPayout,
            deadline: deadline,
            requiresProof: requiresProof,
            category: category,
            dataTypes: ["User-provided"],
            claimURL: nil,
            year: Calendar.current.component(.year, from: .now)
        )
        customBreaches.append(breach)
        persistCustom()
        return breach
    }

    func markNotified(_ breachID: String) {
        update(breachID) { claim in
            if claim.status == .watching {
                claim.status = .notified
            }
        }
    }

    @discardableResult
    func markClaimed(_ breachID: String) -> Bool {
        var becameClaimed = false
        update(breachID) { claim in
            if claim.status != .claimed && claim.status != .paid {
                claim.status = .claimed
                claim.claimedAt = .now
                becameClaimed = true
            }
        }
        return becameClaimed
    }

    func markPaid(_ breachID: String) {
        update(breachID) { claim in
            claim.status = .paid
            if claim.claimedAt == nil { claim.claimedAt = .now }
        }
    }

    func markExpired(_ breachID: String) {
        update(breachID) { claim in
            claim.status = .expired
        }
    }

    func removeClaim(_ breachID: String) {
        claims.removeValue(forKey: breachID)
        persist()
    }

    func setNotes(_ breachID: String, notes: String) {
        update(breachID) { claim in
            claim.notes = notes
        }
    }

    func addWatchedEmail(_ email: String) {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized.contains("@"), !watchedEmails.contains(normalized) else { return }
        watchedEmails.append(normalized)
        persistEmails()
    }

    func removeWatchedEmail(_ email: String) {
        watchedEmails.removeAll { $0 == email }
        persistEmails()
    }

    func scan(email: String) -> [Breach] {
        SampleBreaches.demoMatches(for: email)
    }

    func refreshExpiredStatuses(now: Date = .now) {
        for breach in breaches where !breach.isOpen {
            if let claim = claims[breach.id],
               claim.status.isActive,
               claim.status != .claimed,
               claim.status != .paid {
                markExpired(breach.id)
            }
        }
    }

    func walletShareText() -> String {
        let s = summary
        var lines = [
            "Breach Kit Wallet",
            "Estimated recovery: \(Formatters.money(s.estimatedPayout))",
            "Claimed: \(s.claimedCount) · Notified: \(s.notifiedCount) · Watching: \(s.watchingCount)"
        ]
        if !activeClaims.isEmpty {
            lines.append("")
            lines.append("In progress:")
            for pair in activeClaims.prefix(8) {
                lines.append("• \(pair.breach.company) — \(Formatters.money(pair.breach.estimatedPayout)) · \(Formatters.dueLabel(until: pair.breach.deadline))")
            }
        }
        lines.append("")
        lines.append("Private organizer — not legal advice. Verify on the official claim site.")
        return lines.joined(separator: "\n")
    }

    // MARK: - Persistence

    private func ensureBreachKnown(_ breach: Breach) {
        if catalogBreaches.contains(where: { $0.id == breach.id }) { return }
        if customBreaches.contains(where: { $0.id == breach.id }) { return }
        customBreaches.append(breach)
        persistCustom()
    }

    private func update(_ breachID: String, mutate: (inout Claim) -> Void) {
        var claim = claims[breachID] ?? Claim(breachID: breachID)
        mutate(&claim)
        claims[breachID] = claim
        persist()
    }

    private func load() {
        if let data = defaults.data(forKey: Self.claimsKey),
           let decoded = try? JSONDecoder().decode([String: Claim].self, from: data) {
            claims = decoded
        }
        if let data = defaults.data(forKey: Self.customBreachesKey),
           let decoded = try? JSONDecoder().decode([Breach].self, from: data) {
            customBreaches = decoded
        }
        watchedEmails = defaults.stringArray(forKey: Self.watchedEmailsKey) ?? []
        if defaults.object(forKey: Self.notifyDeadlinesKey) != nil {
            notifyDeadlines = defaults.bool(forKey: Self.notifyDeadlinesKey)
        }
        refreshExpiredStatuses()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(claims) {
            defaults.set(data, forKey: Self.claimsKey)
        }
        defaults.set(notifyDeadlines, forKey: Self.notifyDeadlinesKey)
    }

    private func persistCustom() {
        if let data = try? JSONEncoder().encode(customBreaches) {
            defaults.set(data, forKey: Self.customBreachesKey)
        }
    }

    private func persistEmails() {
        defaults.set(watchedEmails, forKey: Self.watchedEmailsKey)
    }

    func persistSettings() {
        defaults.set(notifyDeadlines, forKey: Self.notifyDeadlinesKey)
    }

    /// Seeds a small authentic wallet after onboarding (leaves one Free slot free).
    func seedDemoWalletIfNeeded() {
        let key = "breachkit.didSeedDemo"
        guard !defaults.bool(forKey: key) else { return }
        guard claims.isEmpty else {
            defaults.set(true, forKey: key)
            return
        }
        let picks = openBreaches.prefix(2)
        for (index, breach) in picks.enumerated() {
            watch(breach)
            if index == 0 {
                markNotified(breach.id)
            }
        }
        defaults.set(true, forKey: key)
    }
}
