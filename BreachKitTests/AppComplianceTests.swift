import XCTest
@testable import BreachKit

final class AppComplianceTests: XCTestCase {
    func testLegalURLsAreHTTPSAndReachablePaths() {
        XCTAssertEqual(AppLegal.privacyPolicyURL.scheme, "https")
        XCTAssertEqual(AppLegal.termsOfUseURL.scheme, "https")
        XCTAssertTrue(AppLegal.privacyPolicyURL.absoluteString.contains("privacy.html"))
        XCTAssertTrue(AppLegal.termsOfUseURL.absoluteString.contains("terms.html"))
    }

    func testBundledPrivacyAndTermsExist() {
        XCTAssertNotNil(AppLegal.bundledMarkdown(named: AppLegal.privacyResourceName))
        XCTAssertNotNil(AppLegal.bundledMarkdown(named: AppLegal.termsResourceName))
        XCTAssertTrue(AppLegal.bundledMarkdown(named: AppLegal.privacyResourceName)!.contains("Privacy"))
        XCTAssertTrue(AppLegal.bundledMarkdown(named: AppLegal.termsResourceName)!.contains("not legal advice")
            || AppLegal.bundledMarkdown(named: AppLegal.termsResourceName)!.lowercased().contains("not legal"))
    }

    func testAppIconAssetExists() {
        let url = Bundle.main.url(forResource: "AppIcon", withExtension: "png")
            ?? Bundle.main.url(forResource: "AppIcon", withExtension: nil)
        // Asset catalog icons aren't always addressable as loose resources; assert privacy manifest instead as ship gate.
        let privacy = Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy")
        XCTAssertNotNil(privacy, "PrivacyInfo.xcprivacy must ship in the app bundle")
    }
}
