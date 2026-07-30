import XCTest
@testable import BreachKit

final class PricingTests: XCTestCase {
    func testYearlySavingsPercent() {
        let pct = EntitlementStore.savingsPercent(monthly: Decimal(string: "3.99")!, yearly: Decimal(string: "24.99")!)
        XCTAssertEqual(pct, 48)
    }

    func testNoSavingsWhenYearlyNotCheaper() {
        XCTAssertNil(EntitlementStore.savingsPercent(monthly: 1, yearly: 20))
    }

    func testProductIDs() {
        XCTAssertEqual(EntitlementStore.monthlyProductID, "com.avaresearch.breachkit.pro.monthly")
        XCTAssertEqual(EntitlementStore.yearlyProductID, "com.avaresearch.breachkit.pro.yearly")
        XCTAssertEqual(AppPricing.monthlyUSD, "3.99")
        XCTAssertEqual(AppPricing.yearlyUSD, "24.99")
    }

    func testFreeTierLimits() {
        XCTAssertEqual(FreeTierLimits.freeReminderDaysBefore, [3])
        XCTAssertEqual(FreeTierLimits.proReminderDaysBefore, [7, 3, 1])
        XCTAssertEqual(
            Set(ProFeature.allCases.map(\.rawValue)),
            Set(["reminderLadder", "customSettlements", "walletShare", "weeklyDigest"])
        )
    }
}

@MainActor
final class EntitlementGateTests: XCTestCase {
    func testWatchingIsAlwaysFree() {
        let entitlements = EntitlementStore()
        entitlements.setDebugUnlocked(false)
        XCTAssertTrue(entitlements.canWatchMore(currentWatchCount: 0))
        XCTAssertTrue(entitlements.canWatchMore(currentWatchCount: 99))
        XCTAssertEqual(entitlements.reminderOffsets, FreeTierLimits.freeReminderDaysBefore)

        entitlements.setDebugUnlocked(true)
        XCTAssertEqual(entitlements.reminderOffsets, FreeTierLimits.proReminderDaysBefore)
        XCTAssertTrue(entitlements.unlocks(.weeklyDigest))
    }
}

@MainActor
final class ChecklistTests: XCTestCase {
    func testChecklistToggleAndProgress() {
        let defaults = UserDefaults(suiteName: "ChecklistTests.\(UUID().uuidString)")!
        let store = BreachStore(defaults: defaults)
        let breach = store.openBreaches[0]
        store.watch(breach)
        XCTAssertEqual(store.claim(for: breach.id)?.completedSteps ?? [-1], [])

        store.toggleChecklistStep(breach.id, step: 0)
        store.toggleChecklistStep(breach.id, step: 1)
        let claim = store.claim(for: breach.id)!
        XCTAssertEqual(Set(claim.completedSteps), [0, 1])
        XCTAssertGreaterThan(claim.checklistProgress(total: breach.eligibilitySteps.count), 0)

        store.toggleChecklistStep(breach.id, step: 0)
        XCTAssertEqual(Set(store.claim(for: breach.id)!.completedSteps), [1])
    }

    func testHonestyFieldsPresentOnCatalog() {
        let breach = SampleBreaches.catalog[0]
        XCTAssertEqual(breach.source, .curated)
        XCTAssertFalse(breach.eligibilitySteps.isEmpty)
        XCTAssertTrue(breach.payoutCaveat.lowercased().contains("estimate") || breach.payoutCaveat.lowercased().contains("not"))
    }
}
