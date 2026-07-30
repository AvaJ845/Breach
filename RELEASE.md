# Breach Kit — Release Checklist

Everything to take Breach Kit from "ready" to "live on the App Store." Legal pages,
icons, screenshots, and listing copy are in the repo — the rest is account/config work
(~3–5 focused hours + short waits). Do the steps in order.

**Key facts**
- Bundle ID: `com.avaresearch.breachkit`
- Home Screen name: **Breach Kit** · App Store name: **Breach Tracker - Breach Kit**
- Signing: your **paid** Apple Developer Program team. Set it locally in `Config/Signing.xcconfig` — gitignored; copy from `Config/Signing.xcconfig.example`.
- Assets: `AppStore/` (five 1320×2868 screenshots, `AppIcon-1024.png`, `METADATA.md`)
- Legal / marketing: `docs/` via GitHub Pages → `https://avaj845.github.io/Breach/{privacy,terms}.html`

---

## 0 · Before anything (Apple / D&B clock — start early)
- [ ] **Apple Developer Program — Organization**, $99/yr.
- [ ] **D-U-N-S** for the LLC if enrolling as Organization.
- [ ] Watch for Apple’s verification call.

## 1 · Legal pages must return HTTP 200 before submit
GitHub Pages on this repo (`/docs`):
- [ ] `https://avaj845.github.io/Breach/`
- [ ] `https://avaj845.github.io/Breach/privacy.html`
- [ ] `https://avaj845.github.io/Breach/terms.html`

Enable: GitHub → **Settings → Pages → Deploy from branch `main` / folder `/docs`**.

## 2 · App Store Connect — account
- [ ] **Agreements, Tax & Banking** complete (even for a free app — needed if you add IAP later).

## 3 · Create the app record
[App Store Connect](https://appstoreconnect.apple.com) → **Apps → +**
- [ ] Platform iOS · Name **Breach Kit** · Primary language English · Bundle ID `com.avaresearch.breachkit` · SKU e.g. `breachkit-001`
- [ ] **App Store Name (listing):** `Breach Tracker - Breach Kit`
- [ ] **Subtitle:** `Settlements & class actions`
- [ ] **Category:** Utilities (primary), Finance (secondary) · **Age:** 4+
- [ ] Description / promo / keywords → paste from `AppStore/METADATA.md`
- [ ] **Privacy Policy URL:** `https://avaj845.github.io/Breach/privacy.html`
- [ ] **Support URL:** `https://avaj845.github.io/Breach/`
- [ ] **App Privacy** nutrition label: **Data Not Collected**
- [ ] Upload **5 screenshots** from `AppStore/` to the **6.9″** slot + 1024 icon (`AppIcon-1024.png`)
- [ ] EULA: Apple Standard, or `https://avaj845.github.io/Breach/terms.html`

## 4 · Build & upload (Release)
```bash
cd /path/to/BreachKit
xcodegen generate
# set Config/Signing.xcconfig DEVELOPMENT_TEAM
```
Xcode → **Any iOS Device (arm64)** → **Product → Archive** → **Distribute App → App Store Connect → Upload**.

## 5 · Submit for review
- [ ] Attach the processed build.
- [ ] **App Review notes:** paste the block from `AppStore/METADATA.md`
      (personal organizer, sample/curated catalog, not a law firm, no claims filing).
- [ ] **Submit.** Typical review ~24–48h.

---

## Sanity checks (shipped in repo)
- [x] Privacy manifest (`PrivacyInfo.xcprivacy`) — no tracking, UserDefaults CA92.1
- [x] Bundled + hosted Privacy / Terms
- [x] Happy-moment review prompt (never at launch)
- [x] Dark + tinted App Icon variants
- [x] 6.9″ screenshot set (1320×2868)
- [x] ASO metadata (keyword-first name, deduped keyword array)

## Optional after launch
- [ ] Capture live Simulator screenshots to replace marketing composites (A/B via Product Page Optimization).
- [ ] App Preview video (15–30s) of Wallet → Claimed.
- [ ] Optional Breach Kit Pro for richer alerts / unlimited watches.
