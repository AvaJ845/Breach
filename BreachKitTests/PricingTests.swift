import XCTest
@testable import BreachKit

final class PricingTests: XCTestCase {
    func testYearlySavingsPercent() {
        // $3.99/mo → $47.88/yr vs $24.99 ≈ 48% savings
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
        XCTAssertEqual(FreeTierLimits.maxWatches, 3)
        XCTAssertEqual(FreeTierLimits.freeReminderDaysBefore, [3])
        XCTAssertEqual(FreeTierLimits.proReminderDaysBefore, [7, 3, 1])
    }
}

@MainActor
final class EntitlementGateTests: XCTestCase {
    func testWatchGateRespectsFreeCap() {
        let entitlements = EntitlementStore()
        entitlements.setDebugUnlocked(false)
        XCTAssertTrue(entitlements.canWatchMore(currentWatchCount: 0))
        XCTAssertTrue(entitlements.canWatchMore(currentWatchCount: 2))
        XCTAssertFalse(entitlements.canWatchMore(currentWatchCount: 3))

        entitlements.setDebugUnlocked(true)
        XCTAssertTrue(entitlements.canWatchMore(currentWatchCount: 99))
        XCTAssertEqual(entitlements.reminderOffsets, FreeTierLimits.proReminderDaysBefore)
    }
}
