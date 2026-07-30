# App Store — Breach Kit

## Identity — Discovery (keyword-first, per the ASO playbook)
- **App Store Name (≤30):** `Breach Tracker - Breach Kit`  *(26 chars — primary keyword FIRST, brand second)*
  - Pattern match to `Habit Tracker - Habit Kit`. Home Screen stays **`Breach Kit`** (`CFBundleDisplayName`).
- **Subtitle (≤30):** `Settlements & class actions`  *(28 chars — all new words, none repeated from the Name)*
  - Alts: `Claims, alerts & identity` *(26)* · `Payouts & breach alerts` *(24 — avoid; repeats breach)*
- **Bundle ID:** `com.avaresearch.breachkit`
- **Version:** **2.1.0** (build 4)
- **Primary category:** Utilities  ·  **Secondary:** Finance
- **Age rating:** 4+
- **Price:** Free. Optional **Breach Kit Pro**
  - Monthly (primary): `com.avaresearch.breachkit.pro.monthly` — **$3.99/mo**, 7-day trial
  - Yearly: `com.avaresearch.breachkit.pro.yearly` — **$24.99/yr**, 7-day trial
  - Group: `Breach Kit Pro`

## Promotional text (≤170)
Organize breach settlements with checklists, deadlines, and a calm Wallet. Live catalog with trust tags. Estimates aren’t guarantees. Free unlimited watches. Pro: smarter reminders.

## Keywords (≤100) — the hidden backend array
`claim,payout,privacy,identity,leak,hack,monitor,scan,exposed,compensation,alert,lawsuit,widget`  *(94 chars)*

Rules applied (per the playbook): comma-separated, **no spaces**, **no word repeated** from the Name or Subtitle (`breach`/`tracker`/`kit`/`settlements`/`class`/`actions` stay out), **singulars**, **no competitor names**. Name + Subtitle + Keywords combine into phrases like `breach tracker`, `class action claims`, `settlement alert`, `identity leak scan`, `payout lawsuit`, `privacy widget`.

## Description
Breach Kit helps you **find, watch, and finish** class-action and data-breach settlement claims — with Apple-like clarity, not payday hype.

**Help you act (always free)**
• Claims-first Wallet — counts lead; estimate ranges stay secondary and labeled “not guaranteed”
• Live public catalog with trust tags + pull-to-refresh
• Step-by-step claim checklists
• Unlimited watches, due-this-week, private notes
• On-device email scan against the catalog
• 3-day deadline reminder + Home Screen due-soon widget
• Lock Screen Live Activity when a watched claim is due soon
• Siri: “What’s due in Breach Kit?”

**Private by design**
• No account. No tracking. Notes and scans stay on-device.
• Catalog refresh downloads public listings only — not your notes or email.

**Breach Kit Pro (optional)**
• Reminder ladder at 7, 3, and 1 day
• Custom settlements, Wallet share, weekly digest
• Same private design — convenience, not legal advice

Official claim sites are always the source of truth.

## What's New (2.1)
Live catalog with trust tags, claims-first Wallet, humble estimate ranges, Live Activities, and App Store screenshots refreshed to match.

## URLs
- **Support / Marketing:** https://avaj845.github.io/Breach/
- **Privacy Policy:** https://avaj845.github.io/Breach/privacy.html
- **Terms of Use (EULA):** https://avaj845.github.io/Breach/terms.html (or Apple standard EULA)
- **Live catalog feed:** https://avaj845.github.io/Breach/catalog.json

## Screenshots (6.9″ — 1320×2868, in this folder)
1. `01_wallet.png` — “Finish claims, calmly.” Claims in progress; estimates secondary.
2. `02_detail.png` — “Checklists that finish claims.” Trust tag + estimate range.
3. `03_scan.png` — “Scan privately on-device.”
4. `04_settlements.png` — “Browse the live catalog.”
5. `05_privacy.png` — “Privacy as a feature.”

App icon: `AppIcon-1024.png` (1024×1024, no alpha). Regenerate shots: `python3 scripts/generate_screenshots.py`

## App Privacy (nutrition label)
- **Data collected:** None for advertising/analytics. No account, no tracking SDKs.
- Network: optional public `catalog.json` download (listings only).
- Subscriptions: Apple StoreKit; app only learns whether Pro is active.

## Review notes (paste into App Review)
Personal organizer with claim checklists. Catalog is a public JSON feed with trust tags (admin-linked / curated / sample / user-provided). Amounts are estimate ranges — not guaranteed. Does not file claims or give legal advice. Free: unlimited watches + checklists + widget + Live Activity. Pro: reminder ladder, custom settlements, share, weekly digest. Sandbox: `Products.storekit`. DEBUG Pro unlock is QA-only.

## App Preview notes
Show Wallet leading with claim counts (not a giant dollar balance), Settlements with trust badges and “est. only”, pull-to-refresh syncing the live catalog, and a due-soon Live Activity / widget with “Not guaranteed”.
