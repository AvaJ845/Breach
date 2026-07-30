#!/usr/bin/env python3
"""Generate 6.9\" App Store screenshots (1320×2868) matching Breach Kit v2.1 UI."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "AppStore"
DOCS_IMG = ROOT / "docs" / "img"
W, H = 1320, 2868
CARD_W, CARD_H = 980, 1780
CARD_X = (W - CARD_W) // 2
CARD_Y = 720

BG = (11, 42, 82)
CARD = (248, 250, 252)
INK = (15, 23, 36)
MUTED = (90, 106, 125)
ACCENT = (28, 107, 199)
CLAIMED = (46, 173, 115)
SOFT = (232, 238, 246)
WHITE = (255, 255, 255)
LINE = (216, 224, 234)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/SFNS.ttf",
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ]
    if bold:
        candidates = [
            "/System/Library/Fonts/Supplemental/SFNS.ttf",
            "/System/Library/Fonts/SFCompact.ttf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/Library/Fonts/Arial Bold.ttf",
        ] + candidates
    for path in candidates:
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def rounded(draw: ImageDraw.ImageDraw, box, radius: int, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def mark(draw, x, y, initials, color, size=72):
    rounded(draw, (x, y, x + size, y + size), 18, color)
    f = font(26, bold=True)
    bbox = draw.textbbox((0, 0), initials, font=f)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text((x + (size - tw) / 2, y + (size - th) / 2 - 2), initials, fill=WHITE, font=f)


def badge(draw, x, y, text, fg, bg):
    f = font(18, bold=True)
    bbox = draw.textbbox((0, 0), text, font=f)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    pad_x, pad_y = 14, 8
    rounded(draw, (x, y, x + tw + pad_x * 2, y + th + pad_y * 2), 999, bg)
    draw.text((x + pad_x, y + pad_y - 1), text, fill=fg, font=f)
    return tw + pad_x * 2


def header(draw, title: str, subtitle: str):
    draw.text((80, 180), title, fill=WHITE, font=font(64, bold=True))
    draw.text((80, 280), subtitle, fill=(210, 226, 245), font=font(34))


def phone_shell(base: Image.Image) -> Image.Image:
    draw = ImageDraw.Draw(base)
    rounded(draw, (CARD_X, CARD_Y, CARD_X + CARD_W, CARD_Y + CARD_H), 56, CARD)
    # status bar
    draw.text((CARD_X + 48, CARD_Y + 36), "9:41", fill=INK, font=font(28, bold=True))
    draw.text((CARD_X + CARD_W - 120, CARD_Y + 36), "■■■", fill=INK, font=font(22))
    return base


def shot_wallet() -> Image.Image:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    header(draw, "Finish claims, calmly.", "Claims first. Estimates stay secondary.")
    phone_shell(img)
    draw = ImageDraw.Draw(img)
    x0, y0 = CARD_X + 48, CARD_Y + 100
    draw.text((x0, y0), "Wallet", fill=INK, font=font(48, bold=True))

    # hero summary — claims-first
    rounded(draw, (x0, y0 + 80, x0 + CARD_W - 96, y0 + 340), 28, ACCENT)
    draw.text((x0 + 28, y0 + 104), "Claims in progress", fill=(220, 235, 255), font=font(26))
    draw.text((x0 + 28, y0 + 148), "3", fill=WHITE, font=font(72, bold=True))
    draw.text((x0 + 28, y0 + 234), "Checklists & deadlines — not a balance", fill=(200, 220, 245), font=font(22))
    for i, (label, val) in enumerate([("Watching", "2"), ("Notified", "1"), ("Claimed", "0")]):
        cx = x0 + 40 + i * 280
        draw.text((cx, y0 + 280), val, fill=WHITE, font=font(30, bold=True))
        draw.text((cx + 40, y0 + 286), label, fill=(190, 215, 240), font=font(22))
    draw.text((x0 + 28, y0 + 360), "Tracked estimate  ~$94  ·  Not guaranteed", fill=(185, 210, 235), font=font(22))

    # honesty banner
    rounded(draw, (x0, y0 + 390, x0 + CARD_W - 96, y0 + 470), 18, (230, 240, 250))
    draw.text((x0 + 20, y0 + 412), "Live feed · 13 listings  ·  Amounts are estimates", fill=ACCENT, font=font(22, bold=True))

    draw.text((x0, y0 + 510), "IN PROGRESS", fill=MUTED, font=font(22, bold=True))
    rows = [
        ("EQ", (28, 107, 199), "Equifax", "Due in 1 day", "~$25–$125", "Watching"),
        ("GO", (20, 140, 120), "Google", "Due in 44 days", "~$10–$22", "Notified"),
        ("ME", (110, 80, 180), "Meta", "Due in 21 days", "~$20–$41", "Watching"),
    ]
    yy = y0 + 560
    for initials, color, company, due, est, status in rows:
        rounded(draw, (x0, yy, x0 + CARD_W - 96, yy + 130), 22, SOFT)
        mark(draw, x0 + 18, yy + 28, initials, color, 74)
        draw.text((x0 + 110, yy + 28), company, fill=INK, font=font(30, bold=True))
        draw.text((x0 + 110, yy + 72), due, fill=MUTED, font=font(24))
        draw.text((x0 + CARD_W - 280, yy + 28), status, fill=ACCENT, font=font(22, bold=True))
        draw.text((x0 + CARD_W - 280, yy + 68), est, fill=MUTED, font=font(26, bold=True))
        draw.text((x0 + CARD_W - 280, yy + 100), "est. only", fill=(150, 160, 175), font=font(18))
        yy += 150

    # tab bar
    bar_y = CARD_Y + CARD_H - 110
    rounded(draw, (CARD_X + 24, bar_y, CARD_X + CARD_W - 24, CARD_Y + CARD_H - 28), 28, WHITE)
    for i, (label, active) in enumerate([("Wallet", True), ("Settlements", False), ("Scan", False)]):
        cx = CARD_X + 140 + i * 280
        draw.text((cx, bar_y + 36), label, fill=ACCENT if active else MUTED, font=font(24, bold=active))
    return img


def shot_detail() -> Image.Image:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    header(draw, "Checklists that finish claims.", "Trust tags. Ranges. Official sites win.")
    phone_shell(img)
    draw = ImageDraw.Draw(img)
    x0, y0 = CARD_X + 48, CARD_Y + 100
    draw.text((x0, y0), "Equifax", fill=INK, font=font(42, bold=True))
    draw.text((x0, y0 + 60), "Credit monitoring follow-on fund", fill=MUTED, font=font(26))
    badge(draw, x0, y0 + 110, "Admin-linked", CLAIMED, (220, 245, 232))
    badge(draw, x0 + 210, y0 + 110, "No proof needed", CLAIMED, (220, 245, 232))

    rounded(draw, (x0, y0 + 180, x0 + CARD_W - 96, y0 + 360), 22, SOFT)
    draw.text((x0 + 24, y0 + 204), "Estimate range", fill=MUTED, font=font(22))
    draw.text((x0 + 24, y0 + 240), "~$25–$125", fill=INK, font=font(44, bold=True))
    draw.text((x0 + 24, y0 + 310), "Estimate only — not guaranteed. Official site wins.", fill=MUTED, font=font(20))
    draw.text((x0 + 520, y0 + 204), "Deadline", fill=MUTED, font=font(22))
    draw.text((x0 + 520, y0 + 240), "Jul 31, 2026", fill=INK, font=font(28, bold=True))
    draw.text((x0 + 520, y0 + 286), "Due in 1 day", fill=ACCENT, font=font(22))

    rounded(draw, (x0, y0 + 390, x0 + CARD_W - 96, y0 + 780), 22, SOFT)
    draw.text((x0 + 24, y0 + 414), "Claim checklist", fill=INK, font=font(30, bold=True))
    draw.text((x0 + CARD_W - 180, y0 + 420), "2/5", fill=MUTED, font=font(24, bold=True))
    steps = [
        (True, "Confirm you may be in the class"),
        (True, "Open the official claim site"),
        (False, "Read eligibility and award tiers"),
        (False, "Submit before the deadline"),
        (False, "Save confirmation in Notes"),
    ]
    sy = y0 + 470
    for done, text in steps:
        mark_char = "●" if done else "○"
        color = CLAIMED if done else MUTED
        draw.text((x0 + 24, sy), mark_char, fill=color, font=font(28, bold=True))
        draw.text((x0 + 70, sy), text, fill=INK if not done else MUTED, font=font(24))
        sy += 52

    rounded(draw, (x0, y0 + 820, x0 + CARD_W - 96, y0 + 920), 22, ACCENT)
    draw.text((x0 + 180, y0 + 852), "Open official claim site", fill=WHITE, font=font(28, bold=True))
    return img


def shot_scan() -> Image.Image:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    header(draw, "Scan privately on-device.", "Your email never leaves the phone.")
    phone_shell(img)
    draw = ImageDraw.Draw(img)
    x0, y0 = CARD_X + 48, CARD_Y + 100
    draw.text((x0, y0), "Scan", fill=INK, font=font(48, bold=True))
    draw.text((x0, y0 + 70), "Match your email against the catalog locally.", fill=MUTED, font=font(26))

    rounded(draw, (x0, y0 + 140, x0 + CARD_W - 96, y0 + 240), 18, SOFT)
    draw.text((x0 + 28, y0 + 172), "ava@example.com", fill=INK, font=font(28))

    rounded(draw, (x0, y0 + 270, x0 + CARD_W - 96, y0 + 370), 22, ACCENT)
    draw.text((x0 + 280, y0 + 302), "Scan on this device", fill=WHITE, font=font(28, bold=True))

    draw.text((x0, y0 + 420), "POSSIBLE MATCHES", fill=MUTED, font=font(22, bold=True))
    rows = [
        ("CH", (28, 107, 199), "Change Healthcare", "~$50–$100", "Admin-linked"),
        ("AP", (90, 90, 100), "Apple", "~$5–$35", "Curated public"),
        ("TG", (20, 140, 120), "T-Mobile", "~$25–$100", "Curated public"),
    ]
    yy = y0 + 470
    for initials, color, company, est, trust in rows:
        rounded(draw, (x0, yy, x0 + CARD_W - 96, yy + 130), 22, SOFT)
        mark(draw, x0 + 18, yy + 28, initials, color, 74)
        draw.text((x0 + 110, yy + 28), company, fill=INK, font=font(28, bold=True))
        draw.text((x0 + 110, yy + 72), trust, fill=ACCENT, font=font(22))
        draw.text((x0 + CARD_W - 300, yy + 48), est, fill=MUTED, font=font(26, bold=True))
        yy += 150

    rounded(draw, (x0, yy + 20, x0 + CARD_W - 96, yy + 120), 18, (230, 245, 238))
    draw.text((x0 + 24, yy + 52), "On-device only · No account · No upload", fill=CLAIMED, font=font(24, bold=True))
    return img


def shot_settlements() -> Image.Image:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    header(draw, "Browse the live catalog.", "Trust tags. Pull to refresh.")
    phone_shell(img)
    draw = ImageDraw.Draw(img)
    x0, y0 = CARD_X + 48, CARD_Y + 100
    draw.text((x0, y0), "Settlements", fill=INK, font=font(48, bold=True))
    rounded(draw, (x0, y0 + 80, x0 + CARD_W - 96, y0 + 160), 18, SOFT)
    draw.text((x0 + 28, y0 + 108), "Search company or settlement", fill=MUTED, font=font(24))

    chips = ["All", "Finance", "Healthcare", "Tech"]
    cx = x0
    for i, chip in enumerate(chips):
        w = badge(draw, cx, y0 + 190, chip, WHITE if i == 0 else INK, ACCENT if i == 0 else SOFT)
        cx += w + 12

    rounded(draw, (x0, y0 + 270, x0 + CARD_W - 96, y0 + 360), 18, (230, 240, 250))
    draw.text((x0 + 20, y0 + 298), "Live feed · Admin-linked & curated public listings", fill=ACCENT, font=font(22, bold=True))

    rows = [
        ("EQ", (28, 107, 199), "Equifax", "Admin-linked", "~$25–$125"),
        ("CH", (180, 70, 70), "Change Healthcare", "Admin-linked", "~$50–$100"),
        ("AP", (90, 90, 100), "Apple", "Curated public", "~$5–$35"),
        ("AT", (20, 140, 120), "AT&T", "Curated public", "~$15–$50"),
    ]
    yy = y0 + 390
    for initials, color, company, trust, est in rows:
        rounded(draw, (x0, yy, x0 + CARD_W - 96, yy + 140), 22, SOFT)
        mark(draw, x0 + 18, yy + 32, initials, color, 74)
        draw.text((x0 + 110, yy + 28), company, fill=INK, font=font(28, bold=True))
        badge(draw, x0 + 110, yy + 78, trust, ACCENT if "Admin" in trust else MUTED, (220, 235, 250))
        draw.text((x0 + CARD_W - 300, yy + 48), est, fill=MUTED, font=font(26, bold=True))
        draw.text((x0 + CARD_W - 300, yy + 90), "est. only", fill=(150, 160, 175), font=font(18))
        yy += 160
    return img


def shot_privacy() -> Image.Image:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    header(draw, "Privacy as a feature.", "No account. No tracking. Ever.")
    phone_shell(img)
    draw = ImageDraw.Draw(img)
    x0, y0 = CARD_X + 48, CARD_Y + 100
    draw.text((x0, y0), "Settings", fill=INK, font=font(48, bold=True))

    blocks = [
        ("Account", "None"),
        ("Tracking", "Off"),
        ("Email scans", "On-device"),
        ("Catalog feed", "Public listings only"),
        ("Widget data", "On-device App Group"),
        ("Live Activities", "On-device deadlines"),
    ]
    yy = y0 + 100
    for label, value in blocks:
        rounded(draw, (x0, yy, x0 + CARD_W - 96, yy + 110), 22, SOFT)
        draw.text((x0 + 28, yy + 36), label, fill=INK, font=font(28, bold=True))
        draw.text((x0 + CARD_W - 420, yy + 38), value, fill=MUTED, font=font(26))
        yy += 130

    rounded(draw, (x0, yy + 20, x0 + CARD_W - 96, yy + 160), 22, (230, 245, 238))
    draw.text((x0 + 28, yy + 55), "Notes, watches, and scans stay on this iPhone.", fill=CLAIMED, font=font(24, bold=True))
    draw.text((x0 + 28, yy + 100), "Catalog refresh never sends your claim status.", fill=MUTED, font=font(22))
    return img


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    DOCS_IMG.mkdir(parents=True, exist_ok=True)
    shots = [
        ("01_wallet.png", shot_wallet),
        ("02_detail.png", shot_detail),
        ("03_scan.png", shot_scan),
        ("04_settlements.png", shot_settlements),
        ("05_privacy.png", shot_privacy),
    ]
    for name, fn in shots:
        img = fn()
        path = OUT / name
        img.save(path, "PNG", optimize=True)
        print(f"wrote {path} {img.size}")

    # Marketing site crops (first three, JPEG)
    mapping = [
        ("01_wallet.png", "shot1.jpg"),
        ("03_scan.png", "shot2.jpg"),
        ("05_privacy.png", "shot3.jpg"),
    ]
    for src, dst in mapping:
        im = Image.open(OUT / src).convert("RGB")
        # Crop phone card area for cleaner web tiles
        card = im.crop((CARD_X - 20, CARD_Y - 40, CARD_X + CARD_W + 20, CARD_Y + CARD_H + 40))
        card = card.resize((720, int(720 * card.height / card.width)), Image.Resampling.LANCZOS)
        card.save(DOCS_IMG / dst, "JPEG", quality=88, optimize=True)
        print(f"wrote {DOCS_IMG / dst}")

    # Keep icon in docs in sync if present
    icon = OUT / "AppIcon-1024.png"
    if icon.exists():
        Image.open(icon).resize((256, 256), Image.Resampling.LANCZOS).save(DOCS_IMG / "icon.png", "PNG")
        print(f"wrote {DOCS_IMG / 'icon.png'}")


if __name__ == "__main__":
    main()
