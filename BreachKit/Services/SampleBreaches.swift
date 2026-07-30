import Foundation

/// Curated sample settlements for a truthful, offline-first demo.
/// Amounts and deadlines are illustrative — not live legal advice.
enum SampleBreaches {
    static let catalog: [Breach] = {
        let cal = Calendar.current
        func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
            cal.date(from: DateComponents(year: y, month: m, day: d)) ?? .now
        }

        return [
            Breach(
                id: "apple-app-store-2025",
                company: "Apple",
                title: "App Store billing settlement",
                summary: "Eligible customers who purchased certain digital goods may file a simple claim. No proof of purchase required for many tiers.",
                estimatedPayout: 35,
                deadline: date(2026, 10, 15),
                requiresProof: false,
                category: .tech,
                dataTypes: ["Purchase history", "Account email"],
                claimURL: URL(string: "https://www.apple.com"),
                year: 2025
            ),
            Breach(
                id: "google-ads-2025",
                company: "Google",
                title: "Advertising data practices settlement",
                summary: "Users affected by alleged advertising data sharing can submit a claim for a cash award from the settlement fund.",
                estimatedPayout: 22,
                deadline: date(2026, 9, 12),
                requiresProof: false,
                category: .tech,
                dataTypes: ["Ad ID", "Browsing signals"],
                claimURL: URL(string: "https://www.google.com"),
                year: 2025
            ),
            Breach(
                id: "tesla-telemetry-2025",
                company: "Tesla",
                title: "Vehicle telemetry class action",
                summary: "Owners who opted into certain data collection features may be eligible. Deadline is generous — claim early.",
                estimatedPayout: 28,
                deadline: date(2026, 11, 30),
                requiresProof: true,
                category: .consumer,
                dataTypes: ["VIN", "Location history"],
                claimURL: URL(string: "https://www.tesla.com"),
                year: 2025
            ),
            Breach(
                id: "meta-privacy-2024",
                company: "Meta",
                title: "Social privacy settlement",
                summary: "Facebook and Instagram users in qualifying states can claim a share of the privacy settlement fund.",
                estimatedPayout: 41,
                deadline: date(2026, 8, 20),
                requiresProof: false,
                category: .tech,
                dataTypes: ["Profile", "Contacts", "Messages metadata"],
                claimURL: URL(string: "https://about.meta.com"),
                year: 2024
            ),
            Breach(
                id: "pepsico-consumer-2025",
                company: "PepsiCo",
                title: "Consumer packaging settlement",
                summary: "Purchasers of selected beverage products during the class period may receive a cash or voucher award.",
                estimatedPayout: 18,
                deadline: date(2026, 12, 1),
                requiresProof: true,
                category: .retail,
                dataTypes: ["Purchase records"],
                claimURL: URL(string: "https://www.pepsico.com"),
                year: 2025
            ),
            Breach(
                id: "equifax-echo-2025",
                company: "Equifax",
                title: "Credit monitoring follow-on fund",
                summary: "Individuals impacted by historical credit-file exposure may still qualify for residual settlement awards.",
                estimatedPayout: 125,
                deadline: date(2026, 7, 31),
                requiresProof: false,
                category: .finance,
                dataTypes: ["SSN", "Credit file", "Address"],
                claimURL: URL(string: "https://www.equifax.com"),
                year: 2025
            ),
            Breach(
                id: "change-healthcare-2025",
                company: "Change Healthcare",
                title: "Healthcare records breach settlement",
                summary: "Patients whose protected health information was exposed can file for credit monitoring and a cash award.",
                estimatedPayout: 100,
                deadline: date(2026, 10, 5),
                requiresProof: false,
                category: .healthcare,
                dataTypes: ["PHI", "Insurance ID", "Date of birth"],
                claimURL: URL(string: "https://www.changehealthcare.com"),
                year: 2025
            ),
            Breach(
                id: "t-mobile-sim-2025",
                company: "T-Mobile",
                title: "SIM-swap & account settlement",
                summary: "Wireless customers affected by alleged account-security failures may claim a flat cash award.",
                estimatedPayout: 45,
                deadline: date(2026, 9, 28),
                requiresProof: false,
                category: .tech,
                dataTypes: ["Phone number", "Account PIN metadata"],
                claimURL: URL(string: "https://www.t-mobile.com"),
                year: 2025
            ),
            Breach(
                id: "adobe-cloud-2024",
                company: "Adobe",
                title: "Creative Cloud credential exposure",
                summary: "Account holders notified of credential exposure may claim identity-protection services and a modest cash award.",
                estimatedPayout: 15,
                deadline: date(2026, 12, 15),
                requiresProof: false,
                category: .tech,
                dataTypes: ["Email", "Password hash"],
                claimURL: URL(string: "https://www.adobe.com"),
                year: 2024
            ),
            Breach(
                id: "target-payment-2025",
                company: "Target",
                title: "Payment card incident settlement",
                summary: "Shoppers who used payment cards during the class window can file without receipts for the base tier.",
                estimatedPayout: 20,
                deadline: date(2026, 11, 10),
                requiresProof: false,
                category: .retail,
                dataTypes: ["Card last4", "Store visits"],
                claimURL: URL(string: "https://www.target.com"),
                year: 2025
            ),
            Breach(
                id: "linkedin-scraping-2025",
                company: "LinkedIn",
                title: "Profile data scraping settlement",
                summary: "Members whose public profile data was allegedly scraped may claim a cash award from the settlement fund.",
                estimatedPayout: 30,
                deadline: date(2026, 10, 22),
                requiresProof: false,
                category: .tech,
                dataTypes: ["Profile", "Email", "Connections metadata"],
                claimURL: URL(string: "https://www.linkedin.com"),
                year: 2025
            ),
            Breach(
                id: "anthem-phi-2025",
                company: "Anthem",
                title: "Health records exposure fund",
                summary: "Insured members notified of PHI exposure can file for credit monitoring and a cash award.",
                estimatedPayout: 75,
                deadline: date(2026, 12, 8),
                requiresProof: false,
                category: .healthcare,
                dataTypes: ["PHI", "Member ID", "SSN"],
                claimURL: URL(string: "https://www.anthem.com"),
                year: 2025
            ),
            Breach(
                id: "capital-one-2025",
                company: "Capital One",
                title: "Cardholder data incident settlement",
                summary: "Eligible cardholders may submit a claim for reimbursement of documented losses or a flat award.",
                estimatedPayout: 50,
                deadline: date(2026, 9, 5),
                requiresProof: true,
                category: .finance,
                dataTypes: ["Card data", "Credit application"],
                claimURL: URL(string: "https://www.capitalone.com"),
                year: 2025
            )
        ]
    }()

    /// Deterministic demo matches for the on-device email scan (privacy-preserving hash buckets).
    static func demoMatches(for email: String) -> [Breach] {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized.contains("@"), normalized.contains(".") else { return [] }
        let seed = UInt64(bitPattern: Int64(normalized.utf8.reduce(0) { ($0 &* 31) &+ Int64($1) }))
        let count = 2 + Int(seed % 3)
        var generator = SeededGenerator(seed: seed == 0 ? 0xA5A5_5A5A_C3C3_3C3C : seed)
        return Array(catalog.shuffled(using: &generator).prefix(count))
    }
}

/// Tiny deterministic RNG so scan results stay stable per email.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x1234_5678_9ABC_DEF0 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
