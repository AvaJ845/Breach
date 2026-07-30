import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                pageOne.tag(0)
                pageTwo.tag(1)
                pageThree.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut(duration: 0.35), value: page)

            Button(action: advance) {
                Text(page == 2 ? "Open Wallet" : "Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var pageOne: some View {
        // Lead with authentic functional value — not a generic welcome form.
        VStack(spacing: 24) {
            Spacer(minLength: 12)
            WalletSummaryCard(
                summary: WalletSummary(
                    estimatedPayout: 94,
                    claimedCount: 3,
                    notifiedCount: 2,
                    watchingCount: 4,
                    paidCount: 1
                )
            )
            .padding(.horizontal, 24)
            .scaleEffect(0.98)

            VStack(spacing: 8) {
                Text("Claim cash, calmly")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                Text("See estimated recovery, deadlines, and claim status at a glance — the same clarity as your iOS Wallet, for settlements.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
    }

    private var pageTwo: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 40)
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.pulse, options: .repeating)

            VStack(spacing: 10) {
                Text("Private by design")
                    .font(.largeTitle.weight(.bold))
                Text("No account. Email scans stay on your device. Notes never leave the phone. Built the Apple way — privacy as a feature.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
    }

    private var pageThree: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 40)
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accentAlt)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 10) {
                Text("Happy moments, not hype")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                Text("Watch settlements, mark claims, and get gentle deadline reminders. We’ll only ask for a rating after you’ve actually claimed something.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
    }

    private func advance() {
        if page < 2 {
            withAnimation { page += 1 }
        } else {
            onContinue()
        }
    }
}
