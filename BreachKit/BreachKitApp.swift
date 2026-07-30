import SwiftUI
import UserNotifications

@main
struct BreachKitApp: App {
    private let notificationDelegate = NotificationDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView(notificationDelegate: notificationDelegate)
                .tint(Theme.accent)
                .onAppear {
                    NotificationService.registerCategories()
                    UNUserNotificationCenter.current().delegate = notificationDelegate
                }
        }
    }
}
