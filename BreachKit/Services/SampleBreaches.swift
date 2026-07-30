import Foundation

enum SampleBreaches {
    static var catalog: [Breach] { CatalogService.offlineCatalog() }

    static func demoMatches(for email: String) -> [Breach] {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized.contains("@"), normalized.contains(".") else { return [] }
        let usable = catalog.filter { $0.estimatedPayout > 0 && $0.id != "offline-placeholder" }
        let source = usable.isEmpty ? catalog : usable
        let seed = UInt64(bitPattern: Int64(normalized.utf8.reduce(0) { ($0 &* 31) &+ Int64($1) }))
        let count = 2 + Int(seed % 3)
        var generator = SeededGenerator(seed: seed == 0 ? 0xA5A5_5A5A_C3C3_3C3C : seed)
        return Array(source.shuffled(using: &generator).prefix(count))
    }
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x1234_5678_9ABC_DEF0 : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
