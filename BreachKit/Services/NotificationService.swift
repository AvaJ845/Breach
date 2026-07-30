import Foundation
import UserNotifications

enum NotificationService {
    static let deadlineCategory = "DEADLINE"
    static let openAction = "OPEN_CLAIM"
    static let claimedAction = "MARK_CLAIMED"

    static func registerCategories() {
        let open = UNNotificationAction(
            identifier: openAction,
            title: "Open in Breach Kit",
            options: [.foreground]
        )
        let claimed = UNNotificationAction(
            identifier: claimedAction,
            title: "Mark claimed",
            options: [.authenticationRequired]
        )
        let category = UNNotificationCategory(
            identifier: deadlineCategory,
            actions: [open, claimed],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    static func scheduleDeadlineReminders(
        for pairs: [(breach: Breach, claim: Claim)],
        enabled: Bool,
        offsets: [Int] = FreeTierLimits.freeReminderDaysBefore
    ) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter {
            $0.hasPrefix("deadline.") || $0.hasPrefix("digest.")
        }
        center.removePendingNotificationRequests(withIdentifiers: ours)

        guard enabled else { return }
        let allowed = await requestAuthorizationIfNeeded()
        guard allowed else { return }

        for pair in pairs where pair.claim.status.isActive && pair.breach.isOpen {
            for daysBefore in offsets {
                guard let fireDate = Calendar.current.date(
                    byAdding: .day,
                    value: -daysBefore,
                    to: pair.breach.deadline
                ) else { continue }
                guard fireDate > .now else { continue }

                let content = UNMutableNotificationContent()
                content.title = daysBefore == 1 ? "Claim due tomorrow" : "Claim deadline approaching"
                content.body = "\(pair.breach.company) — \(Formatters.dueLabel(until: pair.breach.deadline)). Tracked estimate \(Formatters.money(pair.breach.estimatedPayout)) (not guaranteed)."
                content.sound = .default
                content.categoryIdentifier = deadlineCategory
                content.userInfo = ["breachID": pair.breach.id]

                let comps = Calendar.current.dateComponents([.year, .month, .day, .hour], from: fireDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "deadline.\(pair.breach.id).\(daysBefore)",
                    content: content,
                    trigger: trigger
                )
                try? await center.add(request)
            }
        }
    }

    /// Pro weekly digest — Sundays 10:00 local.
    static func scheduleWeeklyDigest(
        dueSoon: [(breach: Breach, claim: Claim)],
        enabled: Bool
    ) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["digest.weekly"])
        guard enabled, !dueSoon.isEmpty else { return }
        let allowed = await requestAuthorizationIfNeeded()
        guard allowed else { return }

        let names = dueSoon.prefix(4).map(\.breach.company).joined(separator: ", ")
        let content = UNMutableNotificationContent()
        content.title = "Due soon this week"
        content.body = "\(dueSoon.count) watched settlement\(dueSoon.count == 1 ? "" : "s"): \(names). Open Breach Kit to finish checklists."
        content.sound = .default

        var comps = DateComponents()
        comps.weekday = 1 // Sunday
        comps.hour = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: "digest.weekly", content: content, trigger: trigger)
        try? await center.add(request)
    }
}
