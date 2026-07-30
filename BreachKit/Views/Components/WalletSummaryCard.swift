import SwiftUI

struct WalletSummaryCard: View {
    let summary: WalletSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estimated recovery")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(Formatters.money(summary.estimatedPayout))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
                Spacer()
                Image(systemName: "shield.checkered")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolRenderingMode(.hierarchical)
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
            "Estimated recovery \(Formatters.money(summary.estimatedPayout)). Claimed \(summary.claimedCount), notified \(summary.notifiedCount), watching \(summary.watchingCount)."
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
