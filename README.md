# Breach Kit

A native SwiftUI iOS app for **tracking data-breach settlements and class-action claims** — the calm, privacy-first counterpart to loud “payout” apps.

Named per the ASO playbook: **Home Screen `Breach Kit`**, App Store listing **`Breach Tracker - Breach Kit`** (keyword first, Kit brand second — same pattern as Habit Kit).

> Breach Kit organizes public settlement information. It is **not** a law firm, claims administrator, or guarantee of payment.

## Features

- **Wallet** — estimated recovery, claimed / notified / watching counts, In Progress & Finished lists
- **Settlements** — curated catalog with deadlines, estimated awards, proof badges, categories, search
- **Scan** — on-device email check against the catalog (no upload, no account)
- **Reminders** — local notifications 3 days before watched deadlines
- **Happy-moment reviews** — `requestReview` only after successful claim/scan milestones
- **Private by design** — UserDefaults persistence, no analytics, no login

## Project layout

- `BreachKit/` — app (Models, Services, Support, Views)
- `BreachKitTests/` — unit tests
- `AppStore/` — ASO playbook + listing metadata
- `docs/` — privacy page for GitHub Pages

Bundle id `com.avaresearch.breachkit` · iOS 17+.

## Build & run

```bash
xcodegen generate
open BreachKit.xcodeproj
```

Simulator build/test without a signing team:

```bash
xcodebuild test -project BreachKit.xcodeproj -scheme BreachKit \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO
```

## ASO (one look)

| Field | Value |
|---|---|
| App Store Name | `Breach Tracker - Breach Kit` |
| Home Screen | `Breach Kit` |
| Subtitle | `Settlements & class actions` |
| Keywords | `claim,payout,privacy,identity,leak,hack,monitor,scan,exposed,compensation,alert,lawsuit` |

See [`AppStore/ASO_PLAYBOOK.md`](AppStore/ASO_PLAYBOOK.md) and [`AppStore/METADATA.md`](AppStore/METADATA.md).
