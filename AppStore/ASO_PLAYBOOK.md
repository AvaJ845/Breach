# Breach Kit — ASO Playbook (applied from the $50K/mo organic PDF)

The Habit Kit / Focus Kit developer drives ~$50K/mo with **≈98% organic App Store
search and $0 ads.** Method = three engines feeding a flywheel:
**Discovery → Conversion → Momentum.** Applied to Breach Kit below.

---

## Naming decision (Indie Battlefield)

Fight high-volume keywords, not ghost-town niches. Pattern: **`[Primary keyword] - [Brand Kit]`**.

| Candidate | Why |
|---|---|
| **Breach Tracker - Breach Kit** ✅ | Mirrors `Habit Tracker - Habit Kit`. Primary keyword first, Kit brand second. Home Screen = `Breach Kit`. |
| Claim Kit | Strong payout intent, weaker privacy / North Star signal |
| Privacy Kit | Soft — low claim intent |

| Field | Value | Rules |
|---|---|---|
| **App Store Name (≤30)** | `Breach Tracker - Breach Kit` *(26)* | Keyword first · brand second |
| **Home Screen** | `Breach Kit` | `CFBundleDisplayName` — short Kit brand |
| **Subtitle (≤30)** | `Settlements & class actions` *(28)* | **No word repeated** from the Name |
| **Keywords (≤100)** | see `METADATA.md` | commas, **no spaces**, no Name/Subtitle repeats, singulars, no competitors |

Apple indexes **Name + Subtitle + Keywords as one string**, so unique terms combine into:
`breach tracker`, `class action claims`, `settlement alert`, `data breach monitor`,
`identity leak scan`, `payout lawsuit`, `privacy scan`.

---

## ① Discovery (keywords) — *get found*
Full strings live in **`METADATA.md`**. Maximize the hidden 100-char array. Never burn
characters repeating `breach`, `tracker`, `kit`, `settlements`, `class`, or `actions`.

---

## ② Conversion (screenshots) — *get downloaded*
**3–5 seconds.** Authentic functional UI beats polished abstraction. Never lead with onboarding.

Recommended order (v2.1 North Star — claims-first, humble estimates):

| # | File | Caption | Why |
|---|---|---|---|
| 1 | `01_wallet.png` | Finish claims, calmly. | Best feature first — Wallet / claims in progress |
| 2 | `02_detail.png` | Checklists that finish claims. | Deadline + trust + estimate **range** |
| 3 | `03_scan.png` | Scan privately on-device. | Privacy differentiator |
| 4 | `04_settlements.png` | Browse the live catalog. | Trust tags + live feed |
| 5 | `05_privacy.png` | Privacy as a feature. | No account / no tracking |

Size: **6.9″ = 1320×2868**. Icon: `AppIcon-1024.png` (no alpha).

---

## ③ Momentum (reviews) — *dominate rankings*
Happy-moment prompt ships in `ReviewPrompt`: fires after the **2nd successful
claim/scan milestone**, once per version — never at launch or after an error.

---

## The flywheel
`keywords → impressions → authentic screenshots → happy moments → 5★ reviews →
algorithm rank-boost → win harder keywords → repeat.`

ASO is a **multi-year compounding asset.** Commit to the marathon.

---

## Fellow status (v2.1)
| Engine | Applied? |
|---|---|
| Discovery — keyword-first name + clean subtitle + maximized keywords | ✅ |
| Conversion — five 6.9″ shots, claims-first, humble ranges | ✅ regenerate via `scripts/generate_screenshots.py` |
| Momentum — happy-moment review gate | ✅ |
| North Star honesty — estimates not balances; official sites win | ✅ |
