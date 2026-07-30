import ActivityKit
import Foundation

/// Shared with the widget extension — Lock Screen / Dynamic Island deadline activity.
struct DeadlineActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var company: String
        var dueLabel: String
        var estimateLabel: String
        var checklistProgress: Double
        var breachID: String
    }

    var breachID: String
}
