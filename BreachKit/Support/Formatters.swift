import Foundation

enum Formatters {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = 0
        return f
    }()

    static let currencyPrecise: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = 2
        return f
    }()

    static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    static func money(_ amount: Double, precise: Bool = false) -> String {
        let formatter = precise ? currencyPrecise : currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }

    static func dueLabel(until deadline: Date, now: Date = .now) -> String {
        let days = Calendar.current.dateComponents([.day], from: now, to: deadline).day ?? 0
        if days < 0 { return "Deadline passed" }
        if days == 0 { return "Due today" }
        if days == 1 { return "Due tomorrow" }
        return "Due in \(days) days"
    }
}
