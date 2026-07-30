import SwiftUI

struct StatusBadge: View {
    let status: ClaimStatus

    var body: some View {
        Label(status.label, systemImage: status.symbol)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(foreground)
            .background(foreground.opacity(0.14), in: Capsule())
            .accessibilityLabel(status.label)
    }

    private var foreground: Color {
        switch status {
        case .watching: return Theme.accent
        case .notified: return Theme.dueSoon
        case .claimed, .paid: return Theme.claimed
        case .expired: return Theme.expired
        }
    }
}

struct ProofBadge: View {
    let requiresProof: Bool

    var body: some View {
        Text(requiresProof ? "Proof may help" : "No proof needed")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(requiresProof ? Theme.dueSoon : Theme.claimed)
            .background(
                (requiresProof ? Theme.dueSoon : Theme.claimed).opacity(0.12),
                in: Capsule()
            )
    }
}

struct TrustBadge: View {
    let trust: Breach.Trust

    var body: some View {
        Label(trust.label, systemImage: trust.symbol)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(foreground)
            .background(foreground.opacity(0.12), in: Capsule())
            .accessibilityLabel("Trust: \(trust.label)")
            .accessibilityHint(trust.detail)
    }

    private var foreground: Color {
        switch trust {
        case .administratorLinked: return Theme.claimed
        case .curatedPublic: return Theme.accent
        case .samplePreview: return Theme.dueSoon
        case .userProvided: return .secondary
        }
    }
}

struct CompanyMark: View {
    let company: String
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(tint.opacity(0.16))
            Text(initials)
                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var initials: String {
        let parts = company.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(company.prefix(2)).uppercased()
    }

    private var tint: Color {
        let palette: [Color] = [
            Theme.accent,
            Theme.accentAlt,
            Color(red: 0.45, green: 0.35, blue: 0.75),
            Color(red: 0.85, green: 0.40, blue: 0.35),
            Color(red: 0.20, green: 0.55, blue: 0.50)
        ]
        let idx = abs(company.hashValue) % palette.count
        return palette[idx]
    }
}
