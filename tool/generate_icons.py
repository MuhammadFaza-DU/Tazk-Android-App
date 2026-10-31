"""Generate Android launcher + notification icons from one master PNG.

Usage (from repo root):
    python tool/generate_icons.py [path/to/master.png]

Default master: assets/icon/app_icon_master.png  (1024x1024 recommended)

What it writes
--------------
Legacy launcher (full-bleed square, no rounded corners baked in — Android masks):
    android/app/src/main/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png

Adaptive icon (Android 8+) — foreground content is scaled into the safe 66%
zone so launcher masks (circle/squircle/rounded) never crop the face:
    android/app/src/main/res/mipmap-*/ic_launcher_foreground.png
    android/app/src/main/res/mipmap-*/ic_launcher_monochrome.png
    android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
    android/app/src/main/res/values/ic_launcher_background.xml

Notification small icon (monochrome white on transparent, 24dp):
    android/app/src/main/res/drawable-*/ic_notification.png

The background colour matches DESIGN.md `canvas` (#F4F1EA).
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "android" / "app" / "src" / "main" / "res"
DEFAULT_MASTER = ROOT / "assets" / "icon" / "app_icon_master.png"

# DESIGN.md token `canvas` (light) — adaptive icon background layer.
BACKGROUND = (0xF4, 0xF1, 0xEA)

# density -> legacy launcher px, adaptive layer px (108dp), notification px (24dp)
DENSITIES = {
    "mdpi": (48, 108, 24),
    "hdpi": (72, 162, 36),
    "xhdpi": (96, 216, 48),
    "xxhdpi": (144, 324, 72),
    "xxxhdpi": (192, 432, 96),
}

# Android adaptive icons expose a 72dp viewport; only the central 66dp is safe.
SAFE_FRACTION = 66 / 108


def load_master(path: Path) -> Image.Image:
    if not path.exists():
        sys.exit(
            f"master icon not found: {path}\n"
            "Put a 1024x1024 PNG there (prompt I-1 in docs/design/ikon-logo-prompts.md)."
        )
    img = Image.open(path).convert("RGBA")
    side = min(img.size)
    left = (img.width - side) // 2
    top = (img.height - side) // 2
    return img.crop((left, top, left + side, top + side))


def square(img: Image.Image, size: int) -> Image.Image:
    return img.resize((size, size), Image.LANCZOS)


def adaptive_foreground(master: Image.Image, size: int) -> Image.Image:
    """Master content scaled into the safe zone, centred on transparency."""
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    inner = max(1, int(round(size * SAFE_FRACTION)))
    scaled = master.resize((inner, inner), Image.LANCZOS)
    offset = (size - inner) // 2
    canvas.paste(scaled, (offset, offset), scaled)
    return canvas


def notification_icon(master: Image.Image, size: int) -> Image.Image:
    """Monochrome notification glyph: the mascot's sprout.

    Android requires a flat white silhouette on transparency for the status bar,
    and a luminance pass over the cream otter face comes out too faint to read.
    The sprout is Tazk's own mark, survives at 24dp, and reads at any DPI.
    """
    ss = 8  # supersample for clean edges
    big = size * ss
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = big / 2, big / 2
    stem_w = big * 0.085
    stem_h = big * 0.34
    draw.rounded_rectangle(
        [cx - stem_w / 2, cy + big * 0.02, cx + stem_w / 2, cy + big * 0.02 + stem_h],
        radius=stem_w / 2,
        fill=(255, 255, 255, 255),
    )

    leaf_rx, leaf_ry = big * 0.235, big * 0.150
    for sign in (-1, 1):
        leaf = Image.new("RGBA", (int(leaf_rx * 2) + 2, int(leaf_ry * 2) + 2), (0, 0, 0, 0))
        ImageDraw.Draw(leaf).ellipse(
            [0, 0, leaf.width - 1, leaf.height - 1], fill=(255, 255, 255, 255)
        )
        angle = -22 * sign
        leaf = leaf.rotate(angle, resample=Image.BICUBIC, expand=True)
        px = cx + sign * big * 0.185 - leaf.width / 2
        py = cy - big * 0.075 - leaf.height / 2
        img.alpha_composite(leaf, (int(px), int(py)))

    return img.resize((size, size), Image.LANCZOS)


def write_adaptive_xml() -> None:
    anydpi = RES / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />\n'
        "</adaptive-icon>\n",
        encoding="utf-8",
    )

    values = RES / "values"
    values.mkdir(parents=True, exist_ok=True)
    (values / "ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        f'    <color name="ic_launcher_background">#{BACKGROUND[0]:02X}{BACKGROUND[1]:02X}{BACKGROUND[2]:02X}</color>\n'
        "</resources>\n",
        encoding="utf-8",
    )


def main() -> None:
    master_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_MASTER
    master = load_master(master_path)
    print(f"master: {master_path} ({master.width}x{master.height})")

    for density, (legacy_px, adaptive_px, notif_px) in DENSITIES.items():
        folder = RES / f"mipmap-{density}"
        folder.mkdir(parents=True, exist_ok=True)

        square(master, legacy_px).save(folder / "ic_launcher.png", optimize=True)
        adaptive_foreground(master, adaptive_px).save(
            folder / "ic_launcher_foreground.png", optimize=True
        )
        adaptive_foreground(master, adaptive_px).save(
            folder / "ic_launcher_monochrome.png", optimize=True
        )

        drawable = RES / f"drawable-{density}"
        drawable.mkdir(parents=True, exist_ok=True)
        notification_icon(master, notif_px).save(
            drawable / "ic_notification.png", optimize=True
        )

        print(f"  {density}: launcher {legacy_px}px, adaptive {adaptive_px}px, notif {notif_px}px")

    write_adaptive_xml()
    print("adaptive icon xml + background colour written")


if __name__ == "__main__":
    main()
