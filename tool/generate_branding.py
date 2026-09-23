"""Generates the app icon and splash artwork (SVG sources + PNG renders).

Run from the repo root (needs `pip install resvg-py`):
    python3 tool/generate_branding.py
then:
    dart run flutter_launcher_icons
    dart run flutter_native_splash:create

The mark is a safety-yellow bumper plate with a "1" punched through it,
on the charcoal app background with a faint knurl texture.
"""
import os

import resvg_py

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
OUT = os.path.join(ROOT, 'assets', 'branding')

IRON = '#FFC21A'  # AppColors.accent
CHALK = '#F2EFE8'  # AppColors.textPrimary
BG = '#0E0F11'  # AppColors.background
SIZE = 1024


def knurl(spacing=28, opacity=0.05):
    lines = []
    for d in range(-SIZE, 2 * SIZE, spacing):
        lines.append(f'M{d} 0L{d + SIZE} {SIZE}M{d + SIZE} 0L{d} {SIZE}')
    return (
        f'<path d="{"".join(lines)}" stroke="{CHALK}" stroke-opacity="{opacity}" '
        'stroke-width="3" fill="none"/>'
    )


def plate(r, color=IRON, lip=True):
    """Plate centred on the canvas with a "1" cut out through a mask."""
    s = r / 360  # the "1" was drawn for r = 360
    c = SIZE / 2

    def p(x, y):
        return f'{c + (x - 512) * s:.1f} {c + (y - 512) * s:.1f}'

    one = f'M{p(422, 333)}L{p(512, 282)}V{c + (742 - 512) * s:.1f}M{p(422, 742)}H{c + (602 - 512) * s:.1f}'
    lip_ring = (
        f'<circle cx="{c}" cy="{c}" r="{r * 0.83:.1f}" fill="none" stroke="{BG}" '
        f'stroke-opacity="0.18" stroke-width="{10 * s:.1f}"/>'
        if lip
        else ''
    )
    return (
        '<defs><mask id="one">'
        f'<rect width="{SIZE}" height="{SIZE}" fill="white"/>'
        f'<path d="{one}" stroke="black" stroke-width="{62 * s:.1f}" stroke-linecap="butt" '
        'stroke-linejoin="miter" fill="none"/>'
        '</mask></defs>'
        f'<g mask="url(#one)"><circle cx="{c}" cy="{c}" r="{r}" fill="{color}"/>{lip_ring}</g>'
    )


def svg(*parts):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SIZE} {SIZE}" '
        f'width="{SIZE}" height="{SIZE}">' + ''.join(parts) + '</svg>\n'
    )


ARTWORK = {
    # iOS / legacy Android: full-bleed, opaque.
    'app_icon': svg(
        f'<rect width="{SIZE}" height="{SIZE}" fill="{BG}"/>',
        knurl(),
        f'<circle cx="512" cy="512" r="430" fill="none" stroke="{CHALK}" '
        'stroke-opacity="0.35" stroke-width="18"/>',
        plate(360),
    ),
    # Android adaptive foreground: transparent. flutter_launcher_icons adds a
    # 16 % inset, so r = 440 lands at ~58 % of the icon, inside the safe zone.
    'app_icon_foreground': svg(plate(440)),
    # Android 13 themed icon: single colour, the system tints it.
    'app_icon_monochrome': svg(plate(440, color='white', lip=False)),
    # Splash logo (shown centred on the background colour).
    'splash': svg(plate(360)),
    # Android 12+ splash icon: shown inside a circle mask of 2/3 the size.
    'splash_android12': svg(plate(300)),
}

os.makedirs(OUT, exist_ok=True)
for name, content in ARTWORK.items():
    with open(os.path.join(OUT, f'{name}.svg'), 'w') as f:
        f.write(content)
    png = bytes(resvg_py.svg_to_bytes(svg_string=content, width=SIZE, height=SIZE))
    with open(os.path.join(OUT, f'{name}.png'), 'wb') as f:
        f.write(png)
    print('wrote', name)
