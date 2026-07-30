import SwiftUI

struct ClaimRowView: View {
    let breach: Breach
    let claim: Claim
    @ScaledMetric(relativeTo: .title3) private var estimateSize: CGFloat = 17

    var body: some View {
        HStack(spacing: 14) {
            CompanyMark(company: breach.company)

            VStack(alignment: .leading, spacing: 4) {
                Text(breach.company)
                    .font(.headline)
                Text(Formatters.dueLabel(until: breach.deadline))
                    .font(.subheadline)
                    .foregroundStyle(dueColor)
                let total = breach.eligibilitySteps.count
                if total > 0 {
                    Text("Checklist \(Set(claim.completedSteps).count)/\(total)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                StatusBadge(status: claim.status)
                Text(breach.displayEstimate)
                    .font(.system(size: estimateSize, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.secondary)
                Text("est. only")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let total = breach.eligibilitySteps.count
        let done = Set(claim.completedSteps).count
        return "\(breach.company), \(breach.displayEstimate) estimate only, \(Formatters.dueLabel(until: breach.deadline)), \(claim.status.label), checklist \(done) of \(total)"
    }

    private var dueColor: Color {
        let days = Calendar.current.dateComponents([.day], from: .now, to: breach.deadline).day ?? 0
        if days < 0 { return Theme.expired }
        if days <= 14 { return Theme.dueSoon }
        return .secondary
    }
}

struct BreachRowView: View {
    let breach: Breach
    var status: ClaimStatus?
    @ScaledMetric(relativeTo: .title3) private var estimateSize: CGFloat = 17

    var body: some View {
        HStack(spacing: 14) {
            CompanyMark(company: breach.company)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(breach.company)
                        .font(.headline)
                    TrustBadge(trust: breach.trust)
                }
                Text(breach.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    ProofBadge(requiresProof: breach.requiresProof)
                    Text(Formatters.dueLabel(until: breach.deadline))
                        .font(.caption)
                        .foregroundStyle(breach.isOpen ? Theme.accent : Theme.expired)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                if let status {
                    StatusBadge(status: status)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                Text(breach.displayEstimate)
                    .font(.system(size: estimateSize, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.secondary)
                Text("est. only")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(breach.company), \(breach.trust.label), \(breach.displayEstimate) estimate only, \(Formatters.dueLabel(until: breach.deadline))")
    }
}
