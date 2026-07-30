import Foundation
import UserNotifications

enum NotificationService {
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
        // Clear prior Breach Kit deadline requests.
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix("deadline.") }
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
                content.body = "\(pair.breach.company) — \(Formatters.dueLabel(until: pair.breach.deadline)). Estimated \(Formatters.money(pair.breach.estimatedPayout))."
                content.sound = .default
                content.categoryIdentifier = "DEADLINE"

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
}
