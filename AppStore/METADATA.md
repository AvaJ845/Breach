# App Store — Breach Kit

## Identity — Discovery (keyword-first, per the ASO playbook)
- **App Store Name (≤30):** `Breach Tracker - Breach Kit`  *(26 chars — primary keyword FIRST, brand second)*
  - Home Screen name stays `Breach Kit` (`CFBundleDisplayName`).
- **Subtitle (≤30):** `Settlements & class actions`  *(28 chars — all new words, none repeated from the Name)*
- **Bundle ID:** com.avaresearch.breachkit
- **Primary category:** Utilities  ·  **Secondary:** Finance
- **Age rating:** 4+ (no objectionable content)
- **Price:** Free + optional **Breach Kit Pro** auto-renewable subscription:
  - **Monthly (primary):** `com.avaresearch.breachkit.pro.monthly` — **$3.99/month**, **7-day free trial**
  - **Yearly (best value):** `com.avaresearch.breachkit.pro.yearly` — **$24.99/year**, **7-day free trial** (~48% vs 12× monthly)
  - Group: `Breach Kit Pro`

## Promotional text (≤170)
Track data-breach settlements in a calm Wallet — private, on-device. Free includes 3 watches. Pro: unlimited watches, smarter reminders, custom settlements. 7-day free trial.

## Keywords (≤100)
`claim,payout,privacy,identity,leak,hack,monitor,scan,exposed,compensation,alert,lawsuit`  *(90 chars)*

## Description
Breach Kit helps you **find, watch, and claim** class-action and data-breach settlements — with the clarity of a Wallet, not the noise of a payday ad.

**Wallet-first**
• Estimated recovery for everything you’re watching or claimed.
• Due-this-week focus, in-progress and finished lists.
• Gentle local reminders before a deadline.

**Private by design**
• No account. No tracking.
• Email scans run on-device against a curated catalog.
• Notes stay on your iPhone.

**Breach Kit Pro (optional)**
• Unlimited settlement watches (Free includes 3).
• Reminder ladder at 7, 3, and 1 day before a deadline.
• Add custom settlements not yet in the catalog.
• Share your Wallet summary.
• Same private design — Pro is convenience, not legal advice.

**Built for trust**
• Clear “no proof needed” vs “proof may help” badges.
• Official claim-site links when available.
• Honest framing: we organize public settlement info — we don’t file claims or guarantee payment.

## What's New (1.1)
Breach Kit Pro ($3.99/mo or $24.99/yr, 7-day trial): unlimited watches, 7/3/1-day reminders, custom settlements, Wallet share. Plus due-this-week, haptics, richer empty states, and a deeper catalog.

## URLs
- **Support / Marketing:** https://avaj845.github.io/Breach/
- **Privacy Policy:** https://avaj845.github.io/Breach/privacy.html
- **Terms of Use (EULA):** https://avaj845.github.io/Breach/terms.html (or Apple standard EULA)

## Screenshots (6.9" — 1320×2868, in this folder)
1. `01_wallet.png` — "Claim cash, calmly."
2. `02_detail.png` — "Deadlines you can trust."
3. `03_scan.png` — "Private by design."
4. `04_settlements.png` — "Every open window."
5. `05_privacy.png` — "No account. No tracking."

App icon: `AppIcon-1024.png` (1024×1024, no alpha, full-bleed square).

## App Privacy (nutrition label)
- **Data collected:** None. No account, no analytics/tracking SDKs.
- Optional local notifications for deadlines you watch.
- Email addresses used for scans are stored only on-device if you save them.
- Subscriptions handled by Apple (StoreKit); Breach Kit only learns whether Pro is active.

## Review notes (paste into App Review)
Breach Kit is a **personal organizer** for publicly described settlement opportunities. The catalog may include curated/illustrative listings for demo and review. The app does not file claims, provide legal advice, or guarantee payment.

**Subscriptions:** Breach Kit Pro — Monthly `$3.99` (`com.avaresearch.breachkit.pro.monthly`) with 7-day free trial, and Yearly `$24.99` (`com.avaresearch.breachkit.pro.yearly`) with 7-day free trial. Group `Breach Kit Pro`. Use Sandbox / StoreKit Configuration `Products.storekit` for review. DEBUG builds include a local Pro unlock for QA only (omitted from Release).

Privacy Policy: https://avaj845.github.io/Breach/privacy.html
Terms: https://avaj845.github.io/Breach/terms.html
