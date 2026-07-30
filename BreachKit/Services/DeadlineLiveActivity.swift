import ActivityKit
import Foundation

@MainActor
enum DeadlineLiveActivity {
    static func sync(with pairs: [(breach: Breach, claim: Claim)]) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let soon = pairs.filter { pair in
            guard pair.breach.isOpen, pair.claim.status.isActive else { return false }
            let days = Calendar.current.dateComponents([.day], from: .now, to: pair.breach.deadline).day ?? 99
            return days <= 7
        }

        let wanted = Set(soon.map(\.breach.id))

        for activity in Activity<DeadlineActivityAttributes>.activities {
            if !wanted.contains(activity.attributes.breachID) {
                Task { await activity.end(nil, dismissalPolicy: .immediate) }
            }
        }

        for pair in soon.prefix(3) {
            let state = DeadlineActivityAttributes.ContentState(
                company: pair.breach.company,
                dueLabel: Formatters.dueLabel(until: pair.breach.deadline),
                estimateLabel: pair.breach.displayEstimate,
                checklistProgress: pair.claim.checklistProgress(total: pair.breach.eligibilitySteps.count),
                breachID: pair.breach.id
            )
            if let existing = Activity<DeadlineActivityAttributes>.activities.first(where: {
                $0.attributes.breachID == pair.breach.id
            }) {
                Task { await existing.update(ActivityContent(state: state, staleDate: pair.breach.deadline)) }
            } else {
                let attrs = DeadlineActivityAttributes(breachID: pair.breach.id)
                let content = ActivityContent(state: state, staleDate: pair.breach.deadline)
                _ = try? Activity.request(attributes: attrs, content: content, pushType: nil)
            }
        }
    }
}
