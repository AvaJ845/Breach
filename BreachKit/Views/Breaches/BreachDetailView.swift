import SwiftUI
import StoreKit

struct BreachDetailView: View {
    @Bindable var store: BreachStore
    let breach: Breach
    @Environment(\.requestReview) private var requestReview
    @Environment(\.openURL) private var openURL
    @State private var notes: String = ""

    private var claim: Claim? { store.claim(for: breach.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                facts
                dataTypes
                notesCard
                actions
                disclaimer
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(breach.company)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notes = claim?.notes ?? ""
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                CompanyMark(company: breach.company, size: 56)
                VStack(alignment: .leading, spacing: 6) {
                    Text(breach.title)
                        .font(.title3.weight(.semibold))
                    HStack(spacing: 8) {
                        ProofBadge(requiresProof: breach.requiresProof)
                        Label(breach.category.label, systemImage: breach.category.symbol)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Text(breach.summary)
                .font(.body)
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Estimated award")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Formatters.money(breach.estimatedPayout))
                        .font(.title.weight(.bold).monospacedDigit())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Deadline")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Formatters.mediumDate.string(from: breach.deadline))
                        .font(.subheadline.weight(.semibold))
                    Text(Formatters.dueLabel(until: breach.deadline))
                        .font(.caption)
                        .foregroundStyle(breach.isOpen ? Theme.accent : Theme.expired)
                }
            }
            .padding(16)
            .background(Theme.softSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            if let claim {
                StatusBadge(status: claim.status)
            }
        }
    }

    private var facts: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("At a glance")
                .font(.headline)
            LabeledContent("Settlement year", value: "\(breach.year)")
            LabeledContent("Proof of purchase", value: breach.requiresProof ? "May increase award" : "Not required for base tier")
            LabeledContent("Status window", value: breach.isOpen ? "Open for claims" : "Closed")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.softSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var dataTypes: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Data typically involved")
                .font(.headline)
            FlowLayout(spacing: 8) {
                ForEach(breach.dataTypes, id: \.self) { type in
                    Text(type)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.accent.opacity(0.10), in: Capsule())
                        .foregroundStyle(Theme.accent)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.softSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Private notes")
                .font(.headline)
            TextField("Claim confirmation #, mailing date…", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onChange(of: notes) { _, value in
                    guard claim != nil || !value.isEmpty else { return }
                    if claim == nil { store.watch(breach) }
                    store.setNotes(breach.id, notes: value)
                }
            Text("Notes stay on this device.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.softSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var actions: some View {
        VStack(spacing: 10) {
            if claim == nil {
                Button {
                    store.watch(breach)
                    store.markNotified(breach.id)
                    Task {
                        await NotificationService.scheduleDeadlineReminders(
                            for: store.activeClaims,
                            enabled: store.notifyDeadlines
                        )
                    }
                } label: {
                    labelButton("Watch & remind me", systemImage: "bell.badge")
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
            } else if claim?.status == .watching || claim?.status == .notified {
                Button {
                    let happy = store.markClaimed(breach.id)
                    if happy, ReviewPrompt.registerSuccessAndShouldRequest() {
                        requestReview()
                    }
                } label: {
                    labelButton("Mark as claimed", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.claimed)

                Button {
                    store.markPaid(breach.id)
                } label: {
                    labelButton("Mark as paid", systemImage: "banknote")
                }
                .buttonStyle(.bordered)
            } else if claim?.status == .claimed {
                Button {
                    store.markPaid(breach.id)
                } label: {
                    labelButton("Mark as paid", systemImage: "banknote.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.claimed)
            }

            if let url = breach.claimURL {
                Button {
                    if claim == nil { store.watch(breach) }
                    openURL(url)
                } label: {
                    labelButton("Open claim site", systemImage: "safari")
                }
                .buttonStyle(.bordered)
            }

            if claim != nil {
                Button(role: .destructive) {
                    store.removeClaim(breach.id)
                    notes = ""
                } label: {
                    labelButton("Remove from wallet", systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
        .controlSize(.large)
    }

    private var disclaimer: some View {
        Text("Breach Kit helps you organize public settlement information. It is not a law firm, claims administrator, or guarantee of payment. Always verify eligibility on the official claim site.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 4)
    }

    private func labelButton(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity)
    }
}

/// Simple wrapping layout for data-type chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth.isFinite ? maxWidth : x, height: y + rowHeight), frames)
    }
}
