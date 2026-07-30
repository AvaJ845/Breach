import SwiftUI

struct ClaimRowView: View {
    let breach: Breach
    let claim: Claim

    var body: some View {
        HStack(spacing: 14) {
            CompanyMark(company: breach.company)

            VStack(alignment: .leading, spacing: 4) {
                Text(breach.company)
                    .font(.headline)
                Text(Formatters.dueLabel(until: breach.deadline))
                    .font(.subheadline)
                    .foregroundStyle(dueColor)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text(Formatters.money(breach.estimatedPayout))
                    .font(.title3.weight(.bold).monospacedDigit())
                StatusBadge(status: claim.status)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
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

    var body: some View {
        HStack(spacing: 14) {
            CompanyMark(company: breach.company)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(breach.company)
                        .font(.headline)
                    ProofBadge(requiresProof: breach.requiresProof)
                }
                Text(breach.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(Formatters.dueLabel(until: breach.deadline))
                    .font(.caption)
                    .foregroundStyle(breach.isOpen ? Theme.accent : Theme.expired)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text(Formatters.money(breach.estimatedPayout))
                    .font(.title3.weight(.bold).monospacedDigit())
                if let status {
                    StatusBadge(status: status)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
