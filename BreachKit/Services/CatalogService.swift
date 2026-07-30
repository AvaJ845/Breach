import Foundation

/// Remote / bundled catalog envelope hosted on GitHub Pages.
struct CatalogFeed: Codable, Sendable {
    var version: Int
    var generatedAt: Date
    var feedURL: String
    var methodology: String
    var listings: [CatalogListingDTO]
}

/// Wire format using ISO-8601 / date-only strings for the public JSON feed.
struct CatalogListingDTO: Codable, Sendable {
    var id: String
    var company: String
    var title: String
    var summary: String
    var estimatedPayout: Double
    var awardMin: Double?
    var awardMax: Double?
    var deadline: String
    var requiresProof: Bool
    var category: String
    var dataTypes: [String]
    var claimURL: String?
    var citationURL: String?
    var year: Int
    var trust: String
    var eligibilitySteps: [String]?
    var payoutCaveat: String?
    var lastReviewed: String?

    func asBreach(source: Breach.Source = .remote) -> Breach? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoBasic = ISO8601DateFormatter()
        guard let deadlineDate = iso.date(from: deadline) ?? isoBasic.date(from: deadline)
                ?? dateOnly(deadline) else { return nil }
        let reviewed = lastReviewed.flatMap { iso.date(from: $0) ?? isoBasic.date(from: $0) ?? dateOnly($0) }
        let trust = Breach.Trust(rawValue: trust) ?? .curatedPublic
        let category = Breach.Category(rawValue: category) ?? .consumer
        return Breach(
            id: id,
            company: company,
            title: title,
            summary: summary,
            estimatedPayout: estimatedPayout,
            awardMin: awardMin,
            awardMax: awardMax,
            deadline: deadlineDate,
            requiresProof: requiresProof,
            category: category,
            dataTypes: dataTypes,
            claimURL: claimURL.flatMap(URL.init(string:)),
            citationURL: citationURL.flatMap(URL.init(string:)),
            year: year,
            source: source,
            trust: trust,
            eligibilitySteps: eligibilitySteps,
            payoutCaveat: payoutCaveat ?? "Estimate only — not guaranteed",
            lastReviewed: reviewed
        )
    }

    private func dateOnly(_ raw: String) -> Date? {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: String(raw.prefix(10)))
    }
}

enum AppNetwork {
    static let userAgent = "BreachKit/2.1 (iOS; settlement-organizer)"
    static let catalogURL = URL(string: "https://avaj845.github.io/Breach/catalog.json")!
}

enum CatalogService {
    enum Outcome: Sendable {
        case remote([Breach], CatalogFeed)
        case bundled([Breach], reason: String)
    }

    static func offlineCatalog() -> [Breach] {
        let bundled = loadBundled()
        return bundled.isEmpty ? minimalFallback : bundled
    }

    static func loadBundled() -> [Breach] {
        if let url = Bundle.main.url(forResource: "catalog", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let feed = try? decodeFeed(data) {
            let items = feed.listings.compactMap { $0.asBreach(source: .curated) }
            if !items.isEmpty { return items }
        }
        return []
    }

    static func refresh(session: URLSession = .shared) async -> Outcome {
        var request = URLRequest(url: AppNetwork.catalogURL)
        request.setValue(AppNetwork.userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20
        do {
            let (data, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return .bundled(offlineCatalog(), reason: "Feed HTTP \(http.statusCode) — using bundled catalog")
            }
            let feed = try decodeFeed(data)
            let breaches = feed.listings.compactMap { $0.asBreach(source: .remote) }
            guard !breaches.isEmpty else {
                return .bundled(offlineCatalog(), reason: "Empty feed — using bundled catalog")
            }
            AppGroup.defaults.set(data, forKey: "breachkit.catalog.cache.v1")
            AppGroup.defaults.set(Date().timeIntervalSince1970, forKey: "breachkit.catalog.syncedAt")
            return .remote(breaches, feed)
        } catch {
            if let cached = AppGroup.defaults.data(forKey: "breachkit.catalog.cache.v1"),
               let feed = try? decodeFeed(cached) {
                let breaches = feed.listings.compactMap { $0.asBreach(source: .remote) }
                if !breaches.isEmpty {
                    return .remote(breaches, feed)
                }
            }
            return .bundled(offlineCatalog(), reason: "Offline — bundled catalog")
        }
    }

    private static func decodeFeed(_ data: Data) throws -> CatalogFeed {
        struct Envelope: Codable {
            var version: Int
            var generatedAt: String
            var feedURL: String
            var methodology: String
            var listings: [CatalogListingDTO]
        }
        let env = try JSONDecoder().decode(Envelope.self, from: data)
        let iso = ISO8601DateFormatter()
        let generated = iso.date(from: env.generatedAt) ?? Date()
        return CatalogFeed(
            version: env.version,
            generatedAt: generated,
            feedURL: env.feedURL,
            methodology: env.methodology,
            listings: env.listings
        )
    }

    private static var minimalFallback: [Breach] {
        let deadline = Calendar.current.date(byAdding: .month, value: 2, to: .now) ?? .now
        return [
            Breach(
                id: "offline-placeholder",
                company: "Catalog offline",
                title: "Reconnect to refresh the live settlement feed",
                summary: "Breach Kit could not load its public catalog. Pull to refresh when online. Official claim sites remain the source of truth.",
                estimatedPayout: 0,
                awardMin: 0,
                awardMax: 0,
                deadline: deadline,
                requiresProof: false,
                category: .consumer,
                dataTypes: [],
                claimURL: AppNetwork.catalogURL,
                year: Calendar.current.component(.year, from: .now),
                source: .curated,
                trust: .samplePreview,
                payoutCaveat: "No estimate — catalog offline"
            )
        ]
    }
}
