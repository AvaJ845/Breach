import XCTest
@testable import BreachKit

@MainActor
final class BreachStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: BreachStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "BreachKitTests.\(UUID().uuidString)")
        store = BreachStore(defaults: defaults)
    }

    override func tearDown() {
        store = nil
        defaults = nil
        super.tearDown()
    }

    func testWatchAddsToActiveClaimsAndSummary() {
        let breach = store.openBreaches[0]
        store.watch(breach)

        XCTAssertEqual(store.activeClaims.count, 1)
        XCTAssertEqual(store.summary.watchingCount, 1)
        XCTAssertEqual(store.summary.estimatedPayout, breach.estimatedPayout)
    }

    func testMarkClaimedMovesStatusAndSignalsHappyMoment() {
        let breach = store.openBreaches[0]
        store.watch(breach)
        let happy = store.markClaimed(breach.id)

        XCTAssertTrue(happy)
        XCTAssertEqual(store.status(for: breach.id), .claimed)
        XCTAssertEqual(store.summary.claimedCount, 1)
    }

    func testScanRequiresValidEmail() {
        XCTAssertTrue(store.scan(email: "not-an-email").isEmpty)
        XCTAssertFalse(store.scan(email: "ava@example.com").isEmpty)
    }

    func testScanIsDeterministicPerEmail() {
        let a = store.scan(email: "same@example.com").map(\.id)
        let b = store.scan(email: "same@example.com").map(\.id)
        XCTAssertEqual(a, b)
    }
}

final class ReviewPromptTests: XCTestCase {
    func testPromptsOnlyAfterThresholdOncePerVersion() {
        let defaults = UserDefaults(suiteName: "ReviewPromptTests.\(UUID().uuidString)")!

        XCTAssertFalse(ReviewPrompt.registerSuccessAndShouldRequest(defaults: defaults, version: "1.0 (1)"))
        XCTAssertTrue(ReviewPrompt.registerSuccessAndShouldRequest(defaults: defaults, version: "1.0 (1)"))
        XCTAssertFalse(ReviewPrompt.registerSuccessAndShouldRequest(defaults: defaults, version: "1.0 (1)"))
        XCTAssertFalse(ReviewPrompt.registerSuccessAndShouldRequest(defaults: defaults, version: "1.0 (1)"))

        // New version resets the once-per-version gate after threshold again.
        defaults.set(0, forKey: "breachkit.review.successCount")
        XCTAssertFalse(ReviewPrompt.registerSuccessAndShouldRequest(defaults: defaults, version: "1.1 (2)"))
        XCTAssertTrue(ReviewPrompt.registerSuccessAndShouldRequest(defaults: defaults, version: "1.1 (2)"))
    }
}

final class FormatterTests: XCTestCase {
    func testDueLabel() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
        let later = cal.date(byAdding: .day, value: 10, to: today)!

        XCTAssertEqual(Formatters.dueLabel(until: tomorrow, now: today), "Due tomorrow")
        XCTAssertEqual(Formatters.dueLabel(until: later, now: today), "Due in 10 days")
    }
}
