"""Build README assets from the real Tazk artwork (no invented imagery).

Sources: assets/logo/tazk-logo.png, assets/mascot/otter-with-sprout.png.
Palette: DESIGN.md light theme (canvas #F4F1EA, surface #FBF9F4, primary #4A5A44,
primary-soft #DDE3D6, honey #F2C765, ink #26251F, ink-muted #6A6659, clay #C97B5A).
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "assets"
OUT.mkdir(parents=True, exist_ok=True)

CANVAS = (244, 241, 234)
SURFACE = (251, 249, 244)
PRIMARY = (74, 90, 68)
PRIMARY_SOFT = (221, 227, 214)
HONEY = (242, 199, 101)
INK = (38, 37, 31)
CLAY = (201, 123, 90)

BANNER_W, BANNER_H = 1280, 400


def _rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    from PIL import ImageDraw

    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255
    )
    return mask


def _circle(img, diameter):
    """Circular crop using a centre square of the SOURCE aspect (never squashes)."""
    img = img.convert("RGB")
    side = min(img.size)
    left = (img.size[0] - side) // 2
    top = (img.size[1] - side) // 2
    square = img.crop((left, top, left + side, top + side)).resize(
        (diameter, diameter), Image.LANCZOS
    )
    square.putalpha(_rounded_mask(square.size, diameter // 2))
    return square


def _logo_on_canvas(path):
    """Logo ships as RGBA with real alpha; composite it onto the canvas colour."""
    logo = Image.open(path).convert("RGBA")
    flat = Image.new("RGB", logo.size, CANVAS)
    flat.paste(logo, mask=logo.split()[-1])
    return flat


def build_banner():
    logo = _logo_on_canvas(ROOT / "assets" / "logo" / "tazk-logo.png")
    otter = Image.open(ROOT / "assets" / "mascot" / "otter-with-sprout.png")

    banner = Image.new("RGB", (BANNER_W, BANNER_H), CANVAS)

    # Soft sage band behind the mascot, echoing the landing hero card.
    from PIL import ImageDraw

    draw = ImageDraw.Draw(banner)
    draw.rounded_rectangle(
        (BANNER_W - 430, 40, BANNER_W - 40, BANNER_H - 40),
        radius=48,
        fill=PRIMARY_SOFT,
    )
    draw.ellipse(
        (BANNER_W - 300, 250, BANNER_W - 170, BANNER_H - 40), fill=HONEY
    )

    mascot = _circle(otter, 260)
    banner.paste(
        mascot,
        (BANNER_W - 340, (BANNER_H - mascot.size[1]) // 2),
        mascot,
    )

    # Logo lockup, scaled to fit the left column.
    target_w = 560
    scale = target_w / logo.size[0]
    lockup = logo.resize(
        (target_w, round(logo.size[1] * scale)), Image.LANCZOS
    )
    banner.paste(lockup, (72, (BANNER_H - lockup.size[1]) // 2 - 24))

    # Rule under the lockup: primary bar + clay dot, the app's own accent pair.
    y = (BANNER_H - lockup.size[1]) // 2 + lockup.size[1] + 12
    draw.rounded_rectangle((72, y, 72 + 190, y + 8), radius=4, fill=PRIMARY)
    draw.ellipse((72 + 200, y - 2, 72 + 212, y + 10), fill=CLAY)

    banner.save(OUT / "tazk-banner.png", optimize=True)
    return banner.size


def build_motion_frames():
    """Four-frame wave: the mascot tilts and a honey dot lifts, no fake UI."""
    otter = Image.open(ROOT / "assets" / "mascot" / "otter-with-sprout.png")
    base = _circle(otter, 200)
    frames = []
    for index, angle in enumerate((-6, 0, 6, 0)):
        canvas = Image.new("RGBA", (240, 240), (0, 0, 0, 0))
        tilted = base.rotate(angle, resample=Image.BICUBIC, expand=False)
        canvas.paste(tilted, (20, 20), tilted)

        from PIL import ImageDraw

        draw = ImageDraw.Draw(canvas)
        lift = (0, 4, 8, 4)[index]
        draw.ellipse((186, 26 - lift, 206, 46 - lift), fill=HONEY)

        path = OUT / f"otter-wave-{index}.png"
        canvas.save(path, optimize=True)
        frames.append(path)
    return frames


def build_motion_gif():
    """Loop the wave frames into one GIF (GitHub animates GIF, not animated WebP)."""
    frames = [Image.open(OUT / f"otter-wave-{i}.png").convert("RGBA") for i in range(4)]
    flat = []
    for frame in frames:
        backdrop = Image.new("RGBA", frame.size, (255, 255, 255, 0))
        backdrop.alpha_composite(frame)
        flat.append(backdrop.convert("P", palette=Image.ADAPTIVE, colors=64))

    gif = OUT / "otter-wave.gif"
    flat[0].save(
        gif,
        save_all=True,
        append_images=flat[1:],
        duration=[320, 240, 320, 240],
        loop=0,
        optimize=True,
        disposal=2,
    )
    return gif


if __name__ == "__main__":
    print("banner", build_banner())
    for frame in build_motion_frames():
        print("frame", frame.name, frame.stat().st_size // 1024, "KB")
    gif = build_motion_gif()
    print("gif", gif.name, gif.stat().st_size // 1024, "KB")
