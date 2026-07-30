import Foundation
import Observation

/// Local-first claim tracker. Persists to UserDefaults — no account, no cloud.
@Observable
@MainActor
final class BreachStore {
    private static let claimsKey = "breachkit.claims.v1"
    private static let watchedEmailsKey = "breachkit.watchedEmails.v1"
    private static let notifyDeadlinesKey = "breachkit.notifyDeadlines"

    private let defaults: UserDefaults

    private(set) var breaches: [Breach]
    private(set) var claims: [String: Claim] = [:]
    var watchedEmails: [String] = []
    var notifyDeadlines: Bool = true

    init(defaults: UserDefaults = .standard, breaches: [Breach] = SampleBreaches.catalog) {
        self.defaults = defaults
        self.breaches = breaches.sorted { $0.deadline < $1.deadline }
        load()
    }

    var openBreaches: [Breach] {
        breaches.filter(\.isOpen)
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

    private var pairedClaims: [(breach: Breach, claim: Claim)] {
        claims.values.compactMap { claim in
            guard let breach = breach(id: claim.breachID) else { return nil }
            return (breach, claim)
        }
    }

    @discardableResult
    func watch(_ breach: Breach) -> Claim {
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

    func markNotified(_ breachID: String) {
        update(breachID) { claim in
            if claim.status == .watching {
                claim.status = .notified
            }
        }
    }

    /// Happy-moment signal: returns true when this transition should invite a review.
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
            if let claim = claims[breach.id], claim.status.isActive, claim.status != .claimed, claim.status != .paid {
                markExpired(breach.id)
            }
        }
    }

    // MARK: - Persistence

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

    private func persistEmails() {
        defaults.set(watchedEmails, forKey: Self.watchedEmailsKey)
    }

    func persistSettings() {
        defaults.set(notifyDeadlines, forKey: Self.notifyDeadlinesKey)
    }

    /// Seeds a small authentic wallet after onboarding so the first session
    /// shows real functional value (ASO conversion), not an empty tray.
    func seedDemoWalletIfNeeded() {
        let key = "breachkit.didSeedDemo"
        guard !defaults.bool(forKey: key) else { return }
        guard claims.isEmpty else {
            defaults.set(true, forKey: key)
            return
        }
        let picks = openBreaches.prefix(3)
        for (index, breach) in picks.enumerated() {
            watch(breach)
            if index == 0 {
                markNotified(breach.id)
            }
        }
        defaults.set(true, forKey: key)
    }
}
