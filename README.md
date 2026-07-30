# Breach Kit

A native SwiftUI iOS app for **tracking data-breach settlements and class-action claims** — the calm, privacy-first counterpart to loud “payout” apps.

Named per the ASO playbook: **Home Screen `Breach Kit`**, App Store listing **`Breach Tracker - Breach Kit`**.

Marketing / legal (same North Star pattern as [Hummingbird](https://avaj845.github.io/Hummingbirdv1/)):
**https://avaj845.github.io/Breach/**

> Breach Kit organizes public settlement information. It is **not** a law firm, claims administrator, or guarantee of payment.

## Features

- **Wallet** — estimated recovery, claimed / notified / watching counts, In Progress & Finished lists
- **Settlements** — curated catalog with deadlines, estimated awards, proof badges, categories, search
- **Scan** — on-device email check against the catalog (no upload, no account)
- **Reminders** — local notifications 3 days before watched deadlines
- **Happy-moment reviews** — `requestReview` only after successful claim/scan milestones
- **Private by design** — privacy manifest, bundled + hosted Privacy/Terms, no analytics, no login

## App Store package

| Item | Location |
|---|---|
| 6.9″ screenshots (1320×2868) | `AppStore/01_*.png` … `05_*.png` |
| 1024 icon | `AppStore/AppIcon-1024.png` (+ dark/tinted in asset catalog) |
| Listing copy | `AppStore/METADATA.md` |
| ASO playbook | `AppStore/ASO_PLAYBOOK.md` |
| Release checklist | `RELEASE.md` |
| GitHub Pages | `docs/` |

## Project layout

- `BreachKit/` — app (Models, Services, Support, Views, Legal, PrivacyInfo)
- `BreachKitTests/` — unit + compliance tests
- `AppStore/` — screenshots, icon, metadata
- `docs/` — marketing site + privacy + terms

Bundle id `com.avaresearch.breachkit` · iOS 17+.

## Build & run

```bash
xcodegen generate
open BreachKit.xcodeproj
```

For device/release signing, copy `Config/Signing.xcconfig.example` → `Config/Signing.xcconfig` and set your team.

```bash
xcodebuild test -project BreachKit.xcodeproj -scheme BreachKit \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO
```
