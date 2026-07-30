import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var store: BreachStore?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let info = response.notification.request.content.userInfo
        let breachID = info["breachID"] as? String

        switch response.actionIdentifier {
        case NotificationService.claimedAction:
            if let breachID, let store {
                await MainActor.run {
                    _ = store.markClaimed(breachID)
                    store.publishGlance()
                }
            }
        case NotificationService.openAction, UNNotificationDefaultActionIdentifier:
            if let breachID {
                NotificationCenter.default.post(
                    name: .breachKitOpenBreach,
                    object: nil,
                    userInfo: ["breachID": breachID]
                )
            }
        default:
            break
        }
    }
}

extension Notification.Name {
    static let breachKitOpenBreach = Notification.Name("breachkit.openBreach")
}
