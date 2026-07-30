# Breach Kit

A native SwiftUI iOS app for **tracking data-breach settlements and class-action claims** — the calm, privacy-first counterpart to loud “payout” apps.


**https://avaj845.github.io/Breach/**

> Breach Kit organizes public settlement information. It is **not** a law firm, claims administrator, or guarantee of payment.

## Features

- **Wallet** — claims-first counts; estimate ranges secondary (“not guaranteed”)
- **Settlements** — live public catalog with trust tags, deadlines, checklists, search
- **Scan** — on-device email check against the catalog (no upload, no account)
- **Reminders** — Free: 3-day local ping · Pro: 7/3/1-day ladder
- **System craft** — due-soon widget, Live Activities, Siri “What’s due…?”
- **Happy-moment reviews** — `requestReview` only after successful claim/scan milestones
- **Breach Kit Pro** — StoreKit 2, **$3.99/month** (primary, 7-day trial) or **$24.99/year**; reminder ladder, custom settlements, Wallet share, weekly digest
- **Private by design** — privacy manifest, bundled + hosted Privacy/Terms, no analytics, no login

## Project layout

- `BreachKit/` — app (Models, Services, Support, Views, Monetization, Legal, PrivacyInfo)
- `BreachKitTests/` — unit + compliance + pricing + catalog tests
- `Products.storekit` — local StoreKit configuration for Sandbox QA
- `AppStore/` — 6.9″ screenshots, icon, `METADATA.md`, `ASO_PLAYBOOK.md`
- `docs/` — marketing site + privacy + terms + `catalog.json`
- `scripts/generate_screenshots.py` — regenerate App Store + site shots

Bundle id `com.avaresearch.breachkit` · iOS 17+ · version **2.1.0**.

## Build & run

```bash
xcodegen generate
open BreachKit.xcodeproj
```

For device/release signing, copy `Config/Signing.xcconfig.example` → `Config/Signing.xcconfig` and set your team.

```bash
python3 scripts/generate_screenshots.py   # refresh AppStore/ + docs/img shots
xcodebuild test -project BreachKit.xcodeproj -scheme BreachKit \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```
