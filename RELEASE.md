# Breach Kit — Release Checklist

Everything to take Breach Kit from "ready" to "live on the App Store."

**Key facts**
- Bundle ID: `com.avaresearch.breachkit`
- Home Screen: **Breach Kit** · Listing: **Breach Tracker - Breach Kit**
- Subtitle: **Settlements & class actions**
- Version: **2.1.0** (build 4)
- Subscriptions (group `Breach Kit Pro`):
  - Monthly (primary): `com.avaresearch.breachkit.pro.monthly` — **$3.99/mo**, 7-day free trial
  - Yearly: `com.avaresearch.breachkit.pro.yearly` — **$24.99/yr**, 7-day free trial
- Signing: `Config/Signing.xcconfig` (gitignored; copy from example)
- Assets: `AppStore/` · Legal: `https://avaj845.github.io/Breach/`
- Live catalog: `https://avaj845.github.io/Breach/catalog.json`
- ASO: `AppStore/ASO_PLAYBOOK.md` + `METADATA.md`

---

## 0 · Account clock
- [ ] Apple Developer Program (Organization) + D-U-N-S if needed

## 1 · Legal / Pages (HTTP 200) — **DONE in repo + live**
- [x] Pages: branch `main` / folder `/docs`
- [x] `https://avaj845.github.io/Breach/`
- [x] `https://avaj845.github.io/Breach/privacy.html`
- [x] `https://avaj845.github.io/Breach/terms.html`
- [x] `https://avaj845.github.io/Breach/catalog.json` (live settlement feed)

## 2 · Agreements, Tax & Banking
- [ ] Paid Apps agreement + bank/tax (required for subscriptions)

## 3 · App record + ASO listing copy — **READY TO PASTE**
- [ ] Create app record: Bundle ID `com.avaresearch.breachkit`
- [x] Listing name / subtitle / keywords drafted in `AppStore/METADATA.md` (playbook rules applied)
- [x] Privacy / Support / catalog URLs documented
- [x] Nutrition label framing: **Data Not Collected** (catalog = public listings only)
- [x] **6.9″ screenshots (v2.1)** + **1024 icon** in `AppStore/`
- [ ] Paste METADATA into App Store Connect + upload the five screenshots

## 4 · Subscriptions
Apps → Breach Kit → **Subscriptions** → group **Breach Kit Pro**:
- [ ] Monthly `com.avaresearch.breachkit.pro.monthly` · $3.99 · 1 Month · **7-day free trial**
- [ ] Yearly `com.avaresearch.breachkit.pro.yearly` · $24.99 · 1 Year · **7-day free trial**
- [ ] Both **Ready to Submit** · review screenshot · localization from METADATA
- [ ] EULA: Apple Standard or Terms URL

## 5 · Archive & TestFlight
```bash
cp Config/Signing.xcconfig.example Config/Signing.xcconfig   # set DEVELOPMENT_TEAM
xcodegen generate
# Xcode → Any iOS Device → Archive → Distribute → App Store Connect → TestFlight
```
- [ ] Set `DEVELOPMENT_TEAM` in `Config/Signing.xcconfig`
- [ ] Archive + upload build **2.1.0 (4)**
- [ ] Internal TestFlight smoke (see below)
- [ ] External TestFlight (optional)

## 6 · Submit for App Review
- [ ] Attach build + subscriptions
- [ ] Paste Review notes from `METADATA.md`
- [ ] Submit

---

## Sanity checks (in repo) — **COMPLETED & TESTED**
- [x] StoreKit 2 + monthly-first paywall (`Products.storekit`)
- [x] Free unlimited watches + checklists + Live Activity
- [x] Live catalog feed + trust tags + humble estimates
- [x] Privacy manifest · bundled + hosted legal
- [x] Happy-moment review prompt (Momentum engine)
- [x] DEBUG Pro unlock omitted from Release logic path
- [x] ASO playbook recalled: Discovery / Conversion / Momentum
- [x] App Store 6.9″ screenshots regenerated for v2.1 claims-first UI
- [x] Marketing site shots + honesty copy refreshed
- [x] Unit tests green (**22** passing on iPhone 17 simulator)

### Device / TestFlight smoke (run after first upload)
- [ ] Launch → catalog status shows Live feed (or honest offline fallback)
- [ ] Pull-to-refresh Settlements / Wallet
- [ ] Watch a due-soon claim → checklist + reminder permission
- [ ] Scan with a fake email → on-device matches
- [ ] Settings → Privacy rows + open Privacy Policy
- [ ] Paywall loads monthly/yearly (Sandbox)
