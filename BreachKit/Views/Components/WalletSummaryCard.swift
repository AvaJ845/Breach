import SwiftUI

struct WalletSummaryCard: View {
    let summary: WalletSummary
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tracked estimates")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(Formatters.money(summary.trackedEstimates))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                    Text("Not guaranteed · verify on official sites")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
                Spacer()
                Image(systemName: "shield.checkered")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
            }

            HStack(spacing: 0) {
                metric("Claimed", value: "\(summary.claimedCount)")
                Divider().background(.white.opacity(0.25)).frame(height: 28)
                metric("Notified", value: "\(summary.notifiedCount)")
                Divider().background(.white.opacity(0.25)).frame(height: 28)
                metric("Watching", value: "\(summary.watchingCount)")
            }
        }
        .padding(22)
        .background(Theme.heroGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.accent.opacity(0.28), radius: 18, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Tracked estimates \(Formatters.money(summary.trackedEstimates)), not guaranteed. Claimed \(summary.claimedCount), notified \(summary.notifiedCount), watching \(summary.watchingCount)."
        )
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
    }
}

struct CatalogHonestyBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)
            Text("Curated public listings. Amounts are estimates — always confirm eligibility and awards on the official claim site.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct ClaimChecklistCard: View {
    let breach: Breach
    let claim: Claim?
    var onToggle: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Claim checklist")
                    .font(.headline)
                Spacer()
                if let claim {
                    Text("\(completedCount)/\(breach.eligibilitySteps.count)")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("\(completedCount) of \(breach.eligibilitySteps.count) steps done")
                }
            }

            Text("Guided steps to help you finish — Breach Kit never files for you.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let claim {
                ProgressView(value: claim.checklistProgress(total: breach.eligibilitySteps.count))
                    .tint(Theme.claimed)
                    .accessibilityHidden(true)
            }

            ForEach(Array(breach.eligibilitySteps.enumerated()), id: \.offset) { index, step in
                let done = claim?.completedSteps.contains(index) == true
                Button {
                    onToggle(index)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: done ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(done ? Theme.claimed : .secondary)
                            .font(.title3)
                        Text(step)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .strikethrough(done, color: .secondary)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(step)
                .accessibilityValue(done ? "Completed" : "Not completed")
                .accessibilityHint("Double tap to toggle")
                .disabled(claim == nil)
            }

            if claim == nil {
                Text("Tap Watch to start tracking and check off steps.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.softSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var completedCount: Int {
        Set(claim?.completedSteps ?? []).count
    }
}
