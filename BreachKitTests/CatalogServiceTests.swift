import XCTest
@testable import BreachKit

final class CatalogServiceTests: XCTestCase {
    func testBundledCatalogLoadsWithTrustAndRanges() throws {
        let url = try XCTUnwrap(
            Bundle.main.url(forResource: "catalog", withExtension: "json"),
            "catalog.json must ship in the app bundle"
        )
        let data = try Data(contentsOf: url)
        let listings = try decodeListings(data)
        XCTAssertFalse(listings.isEmpty)

        let breaches = listings.compactMap { $0.asBreach(source: .curated) }
        XCTAssertEqual(breaches.count, listings.count)

        XCTAssertTrue(breaches.contains { $0.trust == .administratorLinked })
        XCTAssertTrue(breaches.contains { $0.awardMin != nil && $0.awardMax != nil })
        XCTAssertTrue(breaches.allSatisfy { !$0.displayEstimate.isEmpty })
    }

    func testListingDTOMapsTrustRawValues() throws {
        let json = """
        {
          "id": "demo-admin",
          "company": "Demo",
          "title": "Demo settlement",
          "summary": "For tests",
          "estimatedPayout": 50,
          "awardMin": 10,
          "awardMax": 50,
          "deadline": "2026-12-01T00:00:00Z",
          "requiresProof": false,
          "category": "tech",
          "dataTypes": ["Email"],
          "claimURL": "https://example.com",
          "year": 2026,
          "trust": "administrator_linked",
          "lastReviewed": "2026-07-30",
          "payoutCaveat": "Estimate only"
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(CatalogListingDTO.self, from: json)
        let breach = try XCTUnwrap(dto.asBreach(source: .remote))
        XCTAssertEqual(breach.trust, .administratorLinked)
        XCTAssertEqual(breach.awardMin, 10)
        XCTAssertEqual(breach.awardMax, 50)
        XCTAssertTrue(breach.displayEstimate.contains("–") || breach.displayEstimate.contains("-"))
        XCTAssertEqual(breach.source, .remote)
    }

    func testOfflineCatalogNeverEmpty() {
        XCTAssertFalse(CatalogService.offlineCatalog().isEmpty)
    }

    func testCatalogURLIsPublicHTTPS() {
        XCTAssertEqual(AppNetwork.catalogURL.scheme, "https")
        XCTAssertTrue(AppNetwork.catalogURL.absoluteString.hasSuffix("catalog.json"))
    }

    private func decodeListings(_ data: Data) throws -> [CatalogListingDTO] {
        struct Envelope: Codable {
            var listings: [CatalogListingDTO]
        }
        return try JSONDecoder().decode(Envelope.self, from: data).listings
    }
}

@MainActor
final class CatalogStoreTests: XCTestCase {
    func testApplyRemoteCatalogUpdatesStatus() {
        let defaults = UserDefaults(suiteName: "CatalogStoreTests.\(UUID().uuidString)")!
        let store = BreachStore(defaults: defaults, breaches: [])
        let feed = CatalogFeed(
            version: 1,
            generatedAt: .now,
            feedURL: AppNetwork.catalogURL.absoluteString,
            methodology: "Test methodology",
            listings: []
        )
        let sample = Breach(
            id: "apply-test",
            company: "Acme",
            title: "Test",
            summary: "Summary",
            estimatedPayout: 20,
            awardMin: 5,
            awardMax: 20,
            deadline: Calendar.current.date(byAdding: .month, value: 1, to: .now)!,
            requiresProof: false,
            category: .tech,
            dataTypes: [],
            claimURL: nil,
            year: 2026,
            source: .remote,
            trust: .curatedPublic
        )
        store.applyCatalog(.remote([sample], feed))
        XCTAssertEqual(store.catalogBreaches.count, 1)
        XCTAssertTrue(store.catalogStatusMessage.contains("Live feed"))
        XCTAssertEqual(store.catalogMethodology, "Test methodology")
        XCTAssertEqual(store.breach(id: "apply-test")?.displayEstimate.contains("5"), true)
    }

    func testCustomSettlementIsUserProvidedTrust() {
        let defaults = UserDefaults(suiteName: "CatalogStoreTests.custom.\(UUID().uuidString)")!
        let store = BreachStore(defaults: defaults, breaches: [])
        let breach = store.addCustomBreach(
            company: "YouCo",
            title: "My claim",
            estimatedPayout: 40,
            deadline: .now.addingTimeInterval(86400 * 30),
            requiresProof: false,
            category: .consumer
        )
        XCTAssertEqual(breach.trust, .userProvided)
        XCTAssertEqual(breach.source, .custom)
    }
}
