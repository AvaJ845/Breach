import ActivityKit
import SwiftUI
import WidgetKit

struct DeadlineLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeadlineActivityAttributes.self) { context in
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Claim deadline")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(context.state.company)
                        .font(.headline)
                    Text(context.state.dueLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(context.state.estimateLabel)
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                    Text("est. only")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    ProgressView(value: context.state.checklistProgress)
                        .frame(width: 72)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .activityBackgroundTint(Color(.secondarySystemBackground))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.company)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.dueLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.estimateLabel + " est.")
                        Spacer()
                        Text("Checklist \(Int(context.state.checklistProgress * 100))%")
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
            } compactLeading: {
                Image(systemName: "shield.checkered")
            } compactTrailing: {
                Text(context.state.dueLabel)
                    .font(.caption2)
            } minimal: {
                Image(systemName: "shield.checkered")
            }
        }
    }
}
