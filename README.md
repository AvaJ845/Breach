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
- **Reminders** — Free: 3-day local ping · Pro: 7/3/1-day ladder
- **Happy-moment reviews** — `requestReview` only after successful claim/scan milestones
- **Breach Kit Pro** — StoreKit 2, **$3.99/month** (primary, 7-day trial) or **$24.99/year** (7-day trial); unlimited watches, reminder ladder, custom settlements, Wallet share
- **Polish** — due-this-week, haptics, empty-state CTAs, accessibility labels, expanded catalog
- **Private by design** — privacy manifest, bundled + hosted Privacy/Terms, no analytics, no login

## Project layout

- `BreachKit/` — app (Models, Services, Support, Views, Monetization, Legal, PrivacyInfo)
- `BreachKitTests/` — unit + compliance + pricing tests
- `Products.storekit` — local StoreKit configuration for Sandbox QA
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
