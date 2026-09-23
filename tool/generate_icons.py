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


def arrow_down(x, y_from, y_to):
    return (
        f'<path d="M{x} {y_from}V{y_to}M{x - 3} {y_to - 3}L{x} {y_to}L{x + 3} {y_to - 3}" '
        f'stroke-width="2.5"/>'
    )


def path(d, width=2.5):
    return f'<path d="{d}" stroke-width="{width}"/>'


# Bar paths (motion cues), all ending with an arrowhead that follows the
# curve's tangent. "Floor" = the lift starts on the floor; "hang" = it starts
# at the hips, so the arc is shorter.
CLEAN_FROM_FLOOR = path('M40 42C44 34 43 26 38 22M38.8 25.9L38 22L42 21.9')
CLEAN_FROM_HANG = path('M40 33C42.5 29 41.5 25 38 22M38.8 25.9L38 22L42 21.9')
SNATCH_FROM_FLOOR = path('M41 43C46 30 44 17 36 10M36.6 13.9L36 10L40 10.1')
SNATCH_FROM_HANG = path('M42 33C45 24 42 15 36 10M36.6 13.9L36 10L40 10.1')
# Clean & jerk: the clean's path on the back side, behind the split.
CLEAN_BEHIND = path('M6 43C2 32 5 19 14 10M10 10.4L14 10L13.7 14')


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


# Reusable poses (facing right). Each is (body parts, iron parts).
def front_rack_deep():
    """Deep front squat, bar racked on the shoulders."""
    return [head(18, 8), limb((20, 15), (15, 29), (30, 31), (25, 42), (32, 42))], [plate(29, 15)]


def front_rack_dip():
    """Quarter squat (power receive / dip), bar racked on the shoulders."""
    return [head(18, 8), limb((20, 15), (18, 29), (25, 35), (21, 43), (28, 43))], [plate(29, 15)]


def overhead_deep():
    """Deep squat with the bar locked out overhead."""
    return (
        [head(29, 18, 3.2), limb((23, 21), (15, 33), (28, 34), (24, 44), (31, 44)), limb((23, 21), (25, 11))],
        [plate(26, 8, 6)],
    )


def overhead_dip():
    """Partial squat with the bar locked out overhead."""
    return (
        [head(29, 17, 3.2), limb((23, 21), (21, 32), (28, 37), (24, 44), (31, 44)), limb((23, 21), (24, 11))],
        [plate(25, 7, 6)],
    )


def overhead_split():
    """Split stance with the bar locked out overhead."""
    return (
        [
            head(19, 15),
            limb((23, 20), (23, 31), (32, 35), (33, 44), (39, 44)),
            limb((23, 31), (16, 38), (9, 44)),
            limb((23, 20), (24, 12)),
        ],
        [plate(24, 7, 6)],
    )


def with_parts(pose, *extra_body, floor_y=46):
    body, iron = pose
    return [*body, *extra_body, floor(floor_y)], iron


def sumo_legs(hip_y, knee_y, spread=10):
    return [
        limb((24, hip_y), (24 - spread, knee_y), (12, 44), (8, 44)),
        limb((24, hip_y), (24 + spread, knee_y), (36, 44), (40, 44)),
    ]


BENCH = path('M6 33H34M10 33V41M31 33V41')


ICONS = {
    # ---- Squat ----
    # Deep squat, bar on the upper back.
    'back_squat': (
        [head(31, 9), limb((23, 15), (13, 29), (27, 31), (23, 42), (30, 42)), floor()],
        [plate(21, 14)],
    ),
    # Upright torso, bar racked in front of the neck.
    'front_squat': with_parts(front_rack_deep(), floor_y=45),
    # Deep squat, arms locked overhead, no bar path.
    'overhead_squat': with_parts(overhead_deep()),
    # Back squat sitting back onto a box.
    'box_squat': (
        [
            head(31, 9),
            limb((23, 15), (13, 29), (27, 31), (23, 42), (30, 42)),
            path('M4 45V32H15V45'),
            floor(),
        ],
        [plate(21, 14)],
    ),
    # Reclined, pushing a plate-loaded sled up the rail.
    'leg_press': (
        [
            head(8, 21),
            limb((11, 27), (18, 40), (27, 30), (33, 26)),
            path('M28 21L38 31'),
            path('M4 45H24'),
            path('M10 44L5 30'),
        ],
        [plate(39, 19, 6)],
    ),
    # ---- Hinge ----
    # Start position: hips hinged, bar on the floor against the shins.
    'deadlift': (
        [head(35, 12), limb((30, 17), (14, 22), (23, 31), (20, 44)), limb((30, 17), (27, 35)), floor(46)],
        [plate(26, 38)],
    ),
    # Wide stance, upright torso, bar between the legs.
    'sumo_deadlift': (
        [head(24, 9), limb((24, 15), (24, 27)), *sumo_legs(27, 34), floor(46)],
        [plate(24, 37)],
    ),
    # Straight legs, flat back, bar at the knees.
    'romanian_deadlift': (
        [head(37, 16), limb((32, 21), (14, 20), (17, 32), (16, 44), (23, 44)), limb((32, 21), (26, 29)), floor(46)],
        [plate(24, 33)],
    ),
    # Bar on the back, legs straight, torso folded forward.
    'good_morning': (
        [head(38, 21), limb((33, 23), (14, 22), (15, 33), (15, 44), (22, 44)), floor(46)],
        [plate(28, 16, 6)],
    ),
    # Shoulders on a bench, hips driven up under the bar.
    'hip_thrust': (
        [
            head(7, 26, 3.2),
            limb((11, 30), (25, 22), (35, 23), (35, 43), (41, 43)),
            path('M3 33H14V45'),
            floor(46),
        ],
        [plate(25, 15, 6)],
    ),
    # ---- Bench ----
    # Lying on the bench, arms locked out over the chest.
    'bench_press': (
        [head(9, 27), limb((14, 28), (30, 28), (38, 31), (38, 41)), limb((16, 28), (16, 17)), BENCH, floor()],
        [plate(16, 12)],
    ),
    # Same press on a reclined bench.
    'incline_bench_press': (
        [
            head(10, 19),
            limb((14, 24), (26, 34), (34, 33), (35, 43)),
            limb((15, 24), (15, 15)),
            path('M8 29L25 39H33M14 32V45M30 39V45'),
            floor(46),
        ],
        [plate(15, 9, 6)],
    ),
    # Bench press with the hands brought in (arrows toward the bar centre).
    'close_grip_bench_press': (
        [
            head(9, 27),
            limb((14, 28), (30, 28), (38, 31), (38, 41)),
            limb((16, 28), (16, 17)),
            BENCH,
            path('M1 12H6M4 9.5L6 12L4 14.5', 2),
            path('M31 12H26M28 9.5L26 12L28 14.5', 2),
            floor(),
        ],
        [plate(16, 12)],
    ),
    # Locked out on parallel bars, plate hanging from a belt.
    'weighted_dip': (
        [
            head(21, 7),
            limb((19, 13), (18, 28), (16, 37), (10, 39)),
            limb((19, 13), (19, 22)),
            path('M8 22H30M11 22V46M27 22V46'),
            path('M19 29L24 33', 2),
            floor(46),
        ],
        [plate(25, 38, 5, 1.6)],
    ),
    # ---- Overhead ----
    # Standing tall, bar locked out overhead.
    'overhead_press': (
        [head(19, 16), limb((23, 21), (23, 33), (24, 38), (23, 44), (30, 44)), limb((23, 21), (24, 12)), floor(46)],
        [plate(24, 7, 6)],
    ),
    # Dip and drive from the front rack: straight-up arrow.
    'push_press': (
        [head(18, 9), limb((20, 16), (19, 29), (25, 35), (21, 43), (28, 43)), arrow_up(41, 26, 6), floor(46)],
        [plate(29, 17)],
    ),
    # Catch overhead in a dip (knees bent, feet parallel).
    'push_jerk': (
        [head(19, 16), limb((23, 21), (21, 32), (28, 37), (24, 44), (31, 44)), limb((23, 21), (24, 12)), floor(46)],
        [plate(24, 7, 6)],
    ),
    # Catch overhead in a split.
    'split_jerk': with_parts(overhead_split()),
    # ---- Pulls ----
    # Bent over, pulling the bar to the belly.
    'barbell_row': (
        [head(37, 14), limb((32, 18), (14, 22), (20, 33), (16, 44), (23, 44)), limb((32, 18), (25, 23), (25, 29)), floor(46)],
        [plate(25, 33)],
    ),
    # Torso parallel to the floor, each rep starts from the floor.
    'pendlay_row': (
        [
            head(38, 17),
            limb((33, 20), (14, 20), (21, 31), (17, 44), (24, 44)),
            limb((33, 20), (28, 32)),
            arrow_up(43, 40, 24),
            floor(46),
        ],
        [plate(27, 38)],
    ),
    # Hanging from the bar, plate on a belt (front view).
    'weighted_pull_up': (
        [
            path('M6 5H42', 3),
            head(24, 13),
            limb((20, 5), (21, 19), (24, 19), (27, 19), (28, 5)),
            limb((24, 19), (24, 30)),
            limb((24, 30), (21, 42)),
            limb((24, 30), (27, 42)),
            path('M24 31V35', 2),
        ],
        [plate(24, 39, 5, 1.6)],
    ),
    # ---- Clean ----
    # Catch in a quarter squat, bar path arcing up from the floor.
    'power_clean': with_parts(front_rack_dip(), CLEAN_FROM_FLOOR),
    # Catch in a full front squat, from the floor.
    'squat_clean': with_parts(front_rack_deep(), CLEAN_FROM_FLOOR),
    # Quarter-squat catch, short arc from the hips.
    'hang_power_clean': with_parts(front_rack_dip(), CLEAN_FROM_HANG),
    # Full squat catch, short arc from the hips.
    'hang_squat_clean': with_parts(front_rack_deep(), CLEAN_FROM_HANG),
    # Split jerk, with the clean's path behind the lifter.
    'clean_and_jerk': with_parts(overhead_split(), CLEAN_BEHIND),
    # Front squat straight into a press: up arrow.
    'thruster': with_parts(front_rack_deep(), arrow_up(41, 26, 6)),
    # Squat clean into a thruster: floor arc and up arrow.
    'cluster': with_parts(front_rack_deep(), CLEAN_FROM_FLOOR, arrow_up(6, 30, 8)),
    # Wide stance, elbows high, bar pulled to the chin (front view).
    'sumo_deadlift_high_pull': (
        [
            head(24, 9),
            limb((24, 15), (24, 29)),
            limb((24, 17), (14, 13), (21, 20)),
            limb((24, 17), (34, 13), (27, 20)),
            *sumo_legs(29, 37, 8),
            arrow_up(43, 36, 18),
            floor(46),
        ],
        [plate(24, 23, 5, 1.6)],
    ),
    # ---- Snatch ----
    # Full squat catch overhead, bar path from the floor.
    'snatch': with_parts(overhead_deep(), SNATCH_FROM_FLOOR),
    # Partial squat catch overhead, from the floor.
    'power_snatch': with_parts(overhead_dip(), SNATCH_FROM_FLOOR),
    # Partial squat catch, short arc from the hips.
    'hang_power_snatch': with_parts(overhead_dip(), SNATCH_FROM_HANG),
    # Full squat catch, short arc from the hips.
    'hang_squat_snatch': with_parts(overhead_deep(), SNATCH_FROM_HANG),
    # Dropping under a bar that starts on the back: down arrow.
    'snatch_balance': with_parts(overhead_deep(), arrow_down(42, 12, 34)),
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
