from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/widget_icons/source"
OUTPUT = ROOT / "assets/widget_icons"
ANDROID = ROOT / "android/app/src/main/res/drawable-nodpi"
SIZE = 1024


def _polygon_mask(points: list[tuple[int, int]]) -> Image.Image:
    scale = 2
    mask = Image.new("L", (SIZE * scale, SIZE * scale), 0)
    ImageDraw.Draw(mask).polygon(
        [(x * scale, y * scale) for x, y in points], fill=255
    )
    return mask.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def _liquid_glass(source: Image.Image, mask: Image.Image) -> Image.Image:
    source = source.convert("RGB").resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    mask = mask.filter(ImageFilter.GaussianBlur(0.9))
    gray = source.convert("L")
    fill = Image.new("RGBA", (SIZE, SIZE))
    source_pixels = source.load()
    gray_pixels = gray.load()
    mask_pixels = mask.load()
    fill_pixels = fill.load()

    for y in range(SIZE):
        for x in range(SIZE):
            alpha = mask_pixels[x, y]
            if not alpha:
                continue
            red, green, blue = source_pixels[x, y]
            luminance = gray_pixels[x, y]
            line = max(0.0, min(1.0, (158 - luminance) / 132))
            light = max(0.0, min(1.0, 1 - abs(y / SIZE - 0.44) * 1.6))
            glass = (
                int(77 + 75 * light),
                int(159 + 70 * light),
                int(208 + 43 * light),
            )
            ink = (12, 31, 49)
            color = tuple(
                int(channel * (1 - line * 0.88) + ink_channel * line * 0.88)
                for channel, ink_channel in zip(glass, ink)
            )
            fill_pixels[x, y] = (*color, int(alpha * (0.62 + line * 0.28)))

    # A soft edge glint gives the cutout a glass finish while retaining the
    # source drawing's finger contours and folds.
    inner = mask.filter(ImageFilter.MinFilter(13))
    rim = ImageChops.subtract(mask, inner).filter(ImageFilter.GaussianBlur(1.1))
    highlight = Image.new("RGBA", (SIZE, SIZE), (220, 246, 255, 0))
    highlight.putalpha(rim.point(lambda value: int(value * 0.78)))
    return Image.alpha_composite(fill, highlight)


def sukuna_mask(source: Image.Image) -> Image.Image:
    source = source.convert("RGB").resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    half = [
        (256, 24), (224, 62), (201, 103), (176, 145), (145, 188),
        (123, 226), (108, 263), (94, 296), (77, 326), (51, 348),
        (20, 365), (0, 371), (0, 414), (68, 414), (111, 397),
        (145, 374), (171, 350), (190, 325), (210, 301), (227, 275),
        (243, 248), (255, 222),
    ]
    half = [(x * 2, y * 2) for x, y in half]
    polygon = half + [(SIZE - x, y) for x, y in reversed(half[:-1])]
    bounds = _polygon_mask(polygon)
    pixels = source.load()
    allowed = bounds.load()
    mask = Image.new("L", (SIZE, SIZE), 0)
    output = mask.load()
    for y in range(415 * 2):
        for x in range(SIZE):
            red, green, blue = pixels[x, y]
            if (
                allowed[x, y]
                and red > 124
                and red - green > 32
                and green - blue > 14
            ):
                output[x, y] = 255
    return mask.filter(ImageFilter.MaxFilter(7)).filter(ImageFilter.MinFilter(5))


def gojo_mask() -> Image.Image:
    # Hand-only silhouette traced to the source frame; this excludes the black
    # background while preserving the original crossed-finger drawing.
    points = [
        (90, 512), (109, 446), (113, 402), (103, 350), (92, 312),
        (94, 275), (110, 231), (134, 192), (143, 140), (141, 2),
        (162, 2), (165, 72), (179, 69), (194, 53), (202, 39),
        (214, 45), (210, 77), (196, 110), (191, 177), (180, 230),
        (202, 235), (213, 216), (225, 210), (228, 230), (218, 263),
        (202, 289), (189, 305), (180, 350), (174, 406), (165, 461),
        (154, 512),
    ]
    points = [(x * 2, y * 2) for x, y in points]
    return _polygon_mask(points)


def save_icon(name: str, source: Image.Image, mask: Image.Image) -> None:
    icon = _liquid_glass(source, mask)
    icon.save(OUTPUT / f"{name}.png")
    icon.resize((512, 512), Image.Resampling.LANCZOS).save(
        ANDROID / f"ic_hand_{name}_crop.png"
    )

    # App Store icons cannot contain transparency, so composite the same hand
    # onto a dark jewel-like background for the native alternate icon set.
    background = Image.new("RGBA", icon.size, (9, 16, 27, 255))
    halo = Image.new("RGBA", icon.size, (54, 111, 157, 0))
    halo.putalpha(mask.filter(ImageFilter.GaussianBlur(72)).point(lambda a: a // 3))
    background = Image.alpha_composite(background, halo)
    background = Image.alpha_composite(background, icon)
    background.convert("RGB").save(
        ROOT / f"ios/Runner/Assets.xcassets/AppIcon{name.title()}.appiconset/{name.title()}.png"
    )


def main() -> None:
    sukuna_source = Image.open(SOURCE / "sukuna_frame_crop.png")
    gojo_source = Image.open(SOURCE / "gojo_hand_crop.png")
    save_icon("sukuna", sukuna_source, sukuna_mask(sukuna_source))
    save_icon("gojo", gojo_source, gojo_mask())


if __name__ == "__main__":
    main()
