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

    static func scheduleDeadlineReminders(for pairs: [(breach: Breach, claim: Claim)], enabled: Bool) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: pairs.map { "deadline.\($0.breach.id)" })

        guard enabled else { return }
        let allowed = await requestAuthorizationIfNeeded()
        guard allowed else { return }

        for pair in pairs where pair.claim.status.isActive && pair.breach.isOpen {
            let daysLeft = Calendar.current.dateComponents([.day], from: .now, to: pair.breach.deadline).day ?? 0
            guard daysLeft > 3 else { continue }

            guard let fireDate = Calendar.current.date(byAdding: .day, value: -3, to: pair.breach.deadline) else { continue }
            guard fireDate > .now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Claim deadline approaching"
            content.body = "\(pair.breach.company) — \(Formatters.dueLabel(until: pair.breach.deadline)). Estimated \(Formatters.money(pair.breach.estimatedPayout))."
            content.sound = .default

            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: "deadline.\(pair.breach.id)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }
}
