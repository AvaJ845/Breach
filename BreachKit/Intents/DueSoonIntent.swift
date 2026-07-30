import AppIntents
import WidgetKit

struct DueSoonIntent: AppIntent {
    static var title: LocalizedStringResource = "What’s due soon in Breach Kit"
    static var description = IntentDescription("Lists watched settlements due within a week. Estimates only — not legal advice.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let glance = SharedStorage.loadGlance() else {
            return .result(dialog: "Open Breach Kit and watch a settlement to see what’s due.")
        }
        if let next = glance.next {
            let due = Formatters.dueLabel(until: next.deadline)
            return .result(
                dialog: "Next: \(next.company), \(Formatters.money(next.amount)) estimate, \(due). \(glance.dueSoonCount) due this week. Verify on the official claim site."
            )
        }
        return .result(dialog: "Nothing due soon. You’re watching \(glance.watchingCount) settlement\(glance.watchingCount == 1 ? "" : "s").")
    }
}

struct BreachKitShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DueSoonIntent(),
            phrases: [
                "What’s due in \(.applicationName)",
                "Check \(.applicationName) deadlines",
                "Due soon in \(.applicationName)"
            ],
            shortTitle: "Due soon",
            systemImageName: "calendar.badge.clock"
        )
    }
}
