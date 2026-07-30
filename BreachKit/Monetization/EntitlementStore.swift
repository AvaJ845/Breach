import Foundation
import Observation
import StoreKit

/// StoreKit 2 entitlement surface. Products load from App Store Connect /
/// Products.storekit; Debug builds can unlock Pro locally for QA.
@MainActor
@Observable
final class EntitlementStore {
    /// Primary plan — monthly with trial (Fellow pricing decision).
    static let monthlyProductID = "com.avaresearch.breachkit.pro.monthly"
    static let yearlyProductID = "com.avaresearch.breachkit.pro.yearly"
    nonisolated static var allProductIDs: [String] { [monthlyProductID, yearlyProductID] }

    #if DEBUG
    private static let debugUnlockKey = "breachkit.debug.proUnlocked"
    #endif

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var lastError: String?
    private(set) var debugUnlocked: Bool = false

    var isPro: Bool {
        #if DEBUG
        debugUnlocked || !purchasedProductIDs.isEmpty
        #else
        !purchasedProductIDs.isEmpty
        #endif
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyProductID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyProductID }
    }

    var yearlySavingsPercent: Int? {
        guard let monthly = monthlyProduct, let yearly = yearlyProduct else { return nil }
        return Self.savingsPercent(monthly: monthly.price, yearly: yearly.price)
    }

    nonisolated static func savingsPercent(monthly: Decimal, yearly: Decimal) -> Int? {
        let annualizedMonthly = monthly * 12
        guard annualizedMonthly > 0, yearly < annualizedMonthly else { return nil }
        let fraction = (annualizedMonthly - yearly) / annualizedMonthly
        return Int((fraction as NSDecimalNumber).doubleValue * 100 + 0.5)
    }

    init() {
        #if DEBUG
        debugUnlocked = UserDefaults.standard.bool(forKey: Self.debugUnlockKey)
        #endif
        Task { [weak self] in
            await self?.listenForTransactions()
        }
    }

    func unlocks(_ feature: ProFeature) -> Bool {
        isPro
    }

    func canWatchMore(currentWatchCount: Int) -> Bool {
        isPro || currentWatchCount < FreeTierLimits.maxWatches
    }

    var reminderOffsets: [Int] {
        isPro ? FreeTierLimits.proReminderDaysBefore : FreeTierLimits.freeReminderDaysBefore
    }

    func loadProducts() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Self.allProductIDs)
                .sorted { lhs, rhs in
                    // Monthly first — primary plan.
                    if lhs.id == Self.monthlyProductID { return true }
                    if rhs.id == Self.monthlyProductID { return false }
                    return lhs.id < rhs.id
                }
            await refreshPurchases()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async -> Bool {
        lastError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshPurchases()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func restore() async {
        lastError = nil
        do {
            try await AppStore.sync()
            await refreshPurchases()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func setDebugUnlocked(_ unlocked: Bool) {
        #if DEBUG
        debugUnlocked = unlocked
        UserDefaults.standard.set(unlocked, forKey: Self.debugUnlockKey)
        #else
        _ = unlocked
        #endif
    }

    private func refreshPurchases() async {
        var owned: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                owned.insert(transaction.productID)
            }
        }
        purchasedProductIDs = owned
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await transaction.finish()
                await refreshPurchases()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "Purchase could not be verified."
    }
}
