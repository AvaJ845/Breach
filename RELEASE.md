# Breach Kit — Release Checklist

Everything to take Breach Kit from "ready" to "live on the App Store."

**Key facts**
- Bundle ID: `com.avaresearch.breachkit`
- Home Screen: **Breach Kit** · Listing: **Breach Tracker - Breach Kit**
- Version: **2.1.0**
- Subscriptions (group `Breach Kit Pro`):
  - Monthly (primary): `com.avaresearch.breachkit.pro.monthly` — **$3.99/mo**, 7-day free trial
  - Yearly: `com.avaresearch.breachkit.pro.yearly` — **$24.99/yr**, 7-day free trial
- Signing: `Config/Signing.xcconfig` (gitignored; copy from example)
- Assets: `AppStore/` · Legal: `https://avaj845.github.io/Breach/`
- Live catalog: `https://avaj845.github.io/Breach/catalog.json`

---

## 0 · Account clock
- [ ] Apple Developer Program (Organization) + D-U-N-S if needed

## 1 · Legal pages HTTP 200
- [ ] Pages: branch `main` / folder `/docs`
- [ ] `https://avaj845.github.io/Breach/privacy.html`
- [ ] `https://avaj845.github.io/Breach/terms.html`
- [ ] `https://avaj845.github.io/Breach/catalog.json` (live settlement feed)

## 2 · Agreements, Tax & Banking
- [ ] Paid Apps agreement + bank/tax (required for subscriptions)

## 3 · App record
- [ ] Bundle ID `com.avaresearch.breachkit`
- [ ] Listing name / subtitle / keywords from `AppStore/METADATA.md`
- [ ] Privacy Policy URL + Support URL
- [ ] Nutrition label: **Data Not Collected**
- [ ] 6.9″ screenshots + 1024 icon

## 4 · Subscriptions
Apps → Breach Kit → **Subscriptions** → group **Breach Kit Pro**:
- [ ] Monthly `com.avaresearch.breachkit.pro.monthly` · $3.99 · 1 Month · **7-day free trial**
- [ ] Yearly `com.avaresearch.breachkit.pro.yearly` · $24.99 · 1 Year · **7-day free trial**
- [ ] Both **Ready to Submit** · review screenshot · localization from METADATA
- [ ] EULA: Apple Standard or Terms URL

## 5 · Archive & upload
```bash
xcodegen generate
# set DEVELOPMENT_TEAM in Config/Signing.xcconfig
```
Xcode → Any iOS Device → Archive → Distribute → App Store Connect.

Attach `Products.storekit` for local Sandbox testing (scheme already wired).

## 6 · Submit
- [ ] Attach build + subscriptions
- [ ] Paste Review notes from `METADATA.md`
- [ ] Submit

## Sanity checks (in repo)
- [x] StoreKit 2 + monthly-first paywall
- [x] Free unlimited watches + checklists + Live Activity
- [x] Live catalog feed + trust tags + humble estimates
- [x] Privacy manifest · bundled + hosted legal
- [x] Happy-moment review prompt
- [x] DEBUG Pro unlock omitted from Release logic path
