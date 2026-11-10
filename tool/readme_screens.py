"""Build README screenshot assets from real device captures.

Sources live in docs/artifacts/ (Galaxy A52, 1080x2400). Each shot is cropped to
drop the status bar and the gesture bar so the gallery reads as product UI
instead of a phone dump, then downscaled to keep the README light.

Run: python tool/readme_screens.py
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "docs" / "artifacts"
OUT = ROOT / "docs" / "assets" / "screens"

# Status bar ~72px and gesture bar ~96px at 1080x2400.
CROP_TOP = 78
CROP_BOTTOM = 100
TARGET_WIDTH = 460

SHOTS = {
    "home": "hp-01-home-migrasi-v4.png",
    "stats": "hp-07-statistik-tahun-data-nyata-id.png",
    "pomodoro": "hp-05-pomodoro-caption-status.png",
}


def build() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, filename in SHOTS.items():
        source = SRC / filename
        if not source.exists():
            raise SystemExit(f"missing source: {source}")

        image = Image.open(source).convert("RGB")
        width, height = image.size
        cropped = image.crop((0, CROP_TOP, width, height - CROP_BOTTOM))

        scale = TARGET_WIDTH / cropped.size[0]
        resized = cropped.resize(
            (TARGET_WIDTH, round(cropped.size[1] * scale)), Image.LANCZOS
        )

        target = OUT / f"{name}.webp"
        resized.save(target, format="WEBP", quality=82, method=6)
        print(
            f"{target.name}: {source.name} {image.size} -> "
            f"{resized.size} {target.stat().st_size // 1024} KB"
        )


if __name__ == "__main__":
    build()
