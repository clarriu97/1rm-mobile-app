"""Generates the exercise icon set with one shared visual language.

Side-view pictograms on a 48x48 grid:
- the iron (plate disc with a hub hole) is solid, full opacity;
- the lifter is a heavy stroke figure at 55 % opacity;
- motion arrows (explosive lifts) and the floor share the lifter's opacity.
Icons use currentColor so the app can tint them with a ColorFilter; the
onboarding illustrations bake in the palette colors and are not tinted.
"""
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
OUT = os.path.join(ROOT, 'assets', 'icons')
BODY_OPACITY = 0.55
STROKE = 3.5


def plate(cx, cy, r=7, hub=2):
    # Donut via even-odd fill: outer disc minus hub.
    return (
        f'<path fill-rule="evenodd" d="M{cx - r} {cy}a{r} {r} 0 1 0 {2 * r} 0a{r} {r} 0 1 0 {-2 * r} 0Z'
        f'M{cx - hub} {cy}a{hub} {hub} 0 1 1 {2 * hub} 0a{hub} {hub} 0 1 1 {-2 * hub} 0Z"/>'
    )


def head(cx, cy, r=3.5):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" stroke="none"/>'


def limb(*points):
    d = 'M' + 'L'.join(f'{x} {y}' for x, y in points)
    return f'<path d="{d}"/>'


def floor(y=45, x1=5, x2=43):
    return f'<path d="M{x1} {y}H{x2}" stroke-width="2.5"/>'


def arrow_up(x, y_from, y_to):
    return (
        f'<path d="M{x} {y_from}V{y_to}M{x - 3} {y_to + 3}L{x} {y_to}L{x + 3} {y_to + 3}" '
        f'stroke-width="2.5"/>'
    )


def svg(body, iron):
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="currentColor" '
        f'stroke="currentColor" stroke-width="{STROKE}" stroke-linecap="round" stroke-linejoin="round">\n'
        f'  <g opacity="{BODY_OPACITY}" fill="none">\n    '
        + '\n    '.join(b for b in body if 'stroke="none"' not in b)
        + '\n  </g>\n'
        f'  <g opacity="{BODY_OPACITY}" fill="currentColor">\n    '
        + '\n    '.join(b for b in body if 'stroke="none"' in b)
        + '\n  </g>\n'
        '  <g stroke="none">\n    ' + '\n    '.join(iron) + '\n  </g>\n'
        '</svg>\n'
    )


ICONS = {
    # Deep squat, bar on the upper back.
    'back_squat': (
        [head(31, 9), limb((23, 15), (13, 29), (27, 31), (23, 42), (30, 42)), floor()],
        [plate(21, 14)],
    ),
    # Upright torso, bar racked in front of the neck.
    'front_squat': (
        [head(18, 8), limb((20, 15), (15, 29), (30, 31), (25, 42), (32, 42)), floor()],
        [plate(29, 15)],
    ),
    # Lying on the bench, arms locked out over the chest.
    'bench_press': (
        [
            head(9, 27),
            limb((14, 28), (30, 28), (38, 31), (38, 41)),
            limb((16, 28), (16, 17)),
            '<path d="M6 33H34M10 33V41M31 33V41" stroke-width="2.5"/>',
            floor(),
        ],
        [plate(16, 12)],
    ),
    # Start position: hips hinged, bar on the floor against the shins.
    'deadlift': (
        [head(35, 12), limb((30, 17), (14, 22), (23, 31), (20, 44)), limb((30, 17), (27, 35)), floor(46)],
        [plate(26, 38)],
    ),
    # Catch in the front rack, with the bar path arcing up from the floor.
    'power_clean': (
        [
            head(18, 8),
            limb((20, 15), (18, 29), (25, 35), (21, 43), (28, 43)),
            '<path d="M40 42C44 34 43 26 38 22M38.8 25.9L38 22L42 21.9" stroke-width="2.5"/>',
            floor(46),
        ],
        [plate(29, 15)],
    ),
    # Overhead squat catch: deep squat, arms locked overhead.
    'snatch': (
        [head(29, 18, 3.2), limb((23, 21), (15, 33), (28, 34), (24, 44), (31, 44)), limb((23, 21), (25, 11)), floor(46)],
        [plate(26, 8, 6)],
    ),
    # Standing tall, bar locked out overhead.
    'overhead_press': (
        [head(19, 16), limb((23, 21), (23, 33), (24, 38), (23, 44), (30, 44)), limb((23, 21), (24, 12)), floor(46)],
        [plate(24, 7, 6)],
    ),
    # Bent over, pulling the bar to the belly.
    'barbell_row': (
        [head(37, 14), limb((32, 18), (14, 22), (20, 33), (16, 44), (23, 44)), limb((32, 18), (25, 23), (25, 29)), floor(46)],
        [plate(25, 33)],
    ),
    # Jerk in the split, bar overhead.
    'clean_and_jerk': (
        [
            head(19, 15),
            limb((23, 20), (23, 31), (32, 35), (33, 44), (39, 44)),
            limb((23, 31), (16, 38), (9, 44)),
            limb((23, 20), (24, 12)),
            floor(46),
        ],
        [plate(24, 7, 6)],
    ),
    # Dip and drive from the front rack: straight-up arrow.
    'push_press': (
        [head(18, 9), limb((20, 16), (19, 29), (25, 35), (21, 43), (28, 43)), arrow_up(41, 26, 6), floor(46)],
        [plate(29, 17)],
    ),
}

# Generic barbell for custom exercises (front view, all iron).
BARBELL = (
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none" stroke="currentColor" '
    'stroke-linecap="round" stroke-linejoin="round">\n'
    '  <path d="M4 24H44" stroke-width="3"/>\n'
    '  <path d="M10 13V35M38 13V35" stroke-width="6"/>\n'
    '  <path d="M16 17V31M32 17V31" stroke-width="4"/>\n'
    '</svg>\n'
)

for name, (body, iron) in ICONS.items():
    with open(os.path.join(OUT, f'{name}.svg'), 'w') as f:
        f.write(svg(body, iron))
with open(os.path.join(OUT, 'barbell.svg'), 'w') as f:
    f.write(BARBELL)

# ---- Onboarding illustrations (160x160), same language, more room. ----
ILLU = os.path.join(ROOT, 'assets', 'illustrations')
os.makedirs(ILLU, exist_ok=True)


IRON = '#FFC21A'  # AppColors.accent
CHALK = '#F2EFE8'  # AppColors.textPrimary
BG = '#0E0F11'  # AppColors.background
HEAD = (
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 160" '
    f'fill="{IRON}" stroke="{IRON}" stroke-linecap="round" stroke-linejoin="round">\n'
)
illustrations = {
    # One heavy plate with a "1" stamped on it: the single max rep.
    'onboarding_max': HEAD
    + f'  <g opacity="0.45" fill="none" stroke="{CHALK}" stroke-width="4">\n'
    '    <circle cx="80" cy="80" r="70"/>\n'
    '    <path d="M20 150H140"/>\n'
    '  </g>\n'
    '  <g stroke="none">\n    '
    + f'<circle cx="80" cy="80" r="58"/>'
    + '\n  </g>\n'
    f'  <path d="M68 52L82 44V116M68 116H96" fill="none" stroke="{BG}" stroke-width="9"/>\n'
    '</svg>\n',
    # A logbook page with a bar across it: log weight x reps.
    'onboarding_log': HEAD
    + f'  <g opacity="0.45" fill="none" stroke="{CHALK}" stroke-width="5">\n'
    '    <rect x="36" y="22" width="88" height="120" rx="6"/>\n'
    '    <path d="M54 58H106M54 78H106M54 98H90"/>\n'
    '  </g>\n'
    '  <g fill="none" stroke-width="7">\n'
    '    <path d="M14 122H146"/>\n'
    '    <path d="M30 100V144M130 100V144" stroke-width="14"/>\n'
    '    <path d="M46 108V136M114 108V136" stroke-width="9"/>\n'
    '  </g>\n'
    '</svg>\n',
    # Descending bars: a percentage table at a glance.
    'onboarding_table': HEAD
    + f'  <g opacity="0.45" fill="none" stroke="{CHALK}" stroke-width="4">\n'
    '    <path d="M20 146H140"/>\n'
    '  </g>\n'
    '  <g stroke="none">\n'
    '    <rect x="24" y="22" width="20" height="118" rx="3"/>\n'
    '    <rect x="54" y="42" width="20" height="98" rx="3" opacity="0.8"/>\n'
    '    <rect x="84" y="64" width="20" height="76" rx="3" opacity="0.6"/>\n'
    '    <rect x="114" y="88" width="20" height="52" rx="3" opacity="0.45"/>\n'
    '  </g>\n'
    '</svg>\n',
}
for name, content in illustrations.items():
    with open(os.path.join(ILLU, f'{name}.svg'), 'w') as f:
        f.write(content)

print('icons:', sorted(os.listdir(OUT)))
print('illustrations:', sorted(os.listdir(ILLU)))
