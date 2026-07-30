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
            .accessibilityHint(page == 2 ? "Finishes onboarding" : "Goes to the next page")
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var pageOne: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)
            WalletSummaryCard(
                summary: WalletSummary(
                    trackedEstimates: 94,
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
                Text("See tracked estimates, deadlines, and claim checklists at a glance — calm clarity to help you finish, not hype.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private var pageTwo: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 40)
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.pulse, options: .repeating)
                .accessibilityHidden(true)

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
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accentAlt)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text("Never miss a deadline")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                Text("We’ll ask for notification permission next so watched claims can remind you gently. Free includes a 3-day ping; Pro adds a 7/3/1-day ladder.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
    }

    private func advance() {
        Haptics.light()
        if page < 2 {
            withAnimation { page += 1 }
        } else {
            onContinue()
        }
    }
}
