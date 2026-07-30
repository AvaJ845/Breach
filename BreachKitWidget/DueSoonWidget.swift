import WidgetKit
import SwiftUI

struct DueSoonEntry: TimelineEntry {
    let date: Date
    let glance: WalletGlanceSnapshot?
}

struct DueSoonProvider: TimelineProvider {
    func placeholder(in context: Context) -> DueSoonEntry {
        DueSoonEntry(
            date: .now,
            glance: WalletGlanceSnapshot(
                trackedEstimates: 94,
                watchingCount: 3,
                dueSoonCount: 1,
                next: DeadlineSnapshot(
                    company: "Equifax",
                    amount: 125,
                    deadline: Calendar.current.date(byAdding: .day, value: 3, to: .now) ?? .now,
                    statusLabel: "Watching",
                    breachID: "demo"
                ),
                updatedAt: .now,
                catalogSyncedAt: .now,
                catalogTrustSummary: "Live catalog"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DueSoonEntry) -> Void) {
        completion(DueSoonEntry(date: .now, glance: SharedStorage.loadGlance()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DueSoonEntry>) -> Void) {
        let entry = DueSoonEntry(date: .now, glance: SharedStorage.loadGlance())
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct DueSoonWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BreachKitDueSoon", provider: DueSoonProvider()) { entry in
            DueSoonWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Due soon")
        .description("Next watched settlement deadline. Estimates only — verify on the official site.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DueSoonWidgetView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let entry: DueSoonEntry

    var body: some View {
        if let glance = entry.glance, let next = glance.next {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Due soon")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "shield.checkered")
                        .foregroundStyle(Color(red: 0.11, green: 0.42, blue: 0.78))
                        .accessibilityHidden(true)
                }
                Text(next.company)
                    .font(.headline)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(0.8)
                Text(Formatters.dueLabel(until: next.deadline))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline) {
                    Text("~\(Formatters.money(next.amount))")
                        .font(.title3.weight(.semibold).monospacedDigit())
                        .minimumScaleFactor(0.7)
                    Text("est.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(glance.dueSoonCount) this week")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text("Not guaranteed")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .accessibilityElement(children: .combine)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "checklist")
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.11, green: 0.42, blue: 0.78))
                Text("Watch a settlement in Breach Kit to see deadlines here")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
