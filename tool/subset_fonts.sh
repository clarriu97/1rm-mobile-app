#!/usr/bin/env bash
# Writes the fonts the app bundles (assets/fonts/) from the full fonts in
# tool/fonts/: Big Shoulders Display pinned to the only weight the app uses
# (800), and every font cut down to Latin, Latin-1, Latin Extended-A, General
# Punctuation and every character the app's texts use (ARB files and string
# literals under lib/). Fails if a font lacks any of those characters.
#
#   tool/subset_fonts.sh
set -euo pipefail

cd "$(dirname "$0")/.."

FONTTOOLS=4.60.2
VENV=.dart_tool/fonttools-venv

if ! "$VENV/bin/python" -c "import fontTools, sys; sys.exit(fontTools.version != '$FONTTOOLS')" 2>/dev/null; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --quiet --disable-pip-version-check "fonttools==$FONTTOOLS"
fi

"$VENV/bin/python" -I - <<'PY'
import json
import pathlib
import re
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

SOURCE = pathlib.Path('tool/fonts')
BUNDLED = pathlib.Path('assets/fonts')

FONTS = [
    ('BigShouldersDisplay-Variable.ttf', 'BigShouldersDisplay-ExtraBold.ttf', {'wght': 800}),
    ('Barlow-Regular.ttf', 'Barlow-Regular.ttf', None),
    ('Barlow-Medium.ttf', 'Barlow-Medium.ttf', None),
    ('Barlow-SemiBold.ttf', 'Barlow-SemiBold.ttf', None),
    ('Barlow-Bold.ttf', 'Barlow-Bold.ttf', None),
]

RANGES = [(0x20, 0x7E), (0xA0, 0xFF), (0x100, 0x17F), (0x2000, 0x206F)]

LITERAL = re.compile(r"'(?:[^'\\\n]|\\.)*'|\"(?:[^\"\\\n]|\\.)*\"")
ESCAPE = re.compile(r'\\u\{([0-9a-fA-F]+)\}|\\u([0-9a-fA-F]{4})')


def characters(text):
    found = {c for c in text if ord(c) > 0x7E}
    for braced, plain in ESCAPE.findall(text):
        found.add(chr(int(braced or plain, 16)))
    return found


def used_characters():
    used = set()
    for arb in sorted(pathlib.Path('lib/l10n').glob('*.arb')):
        for key, value in json.loads(arb.read_text()).items():
            if not key.startswith('@') and isinstance(value, str):
                used |= characters(value)
    for dart in sorted(pathlib.Path('lib').rglob('*.dart')):
        if dart.name.startswith('app_localizations'):
            continue
        for line in dart.read_text().splitlines():
            if line.lstrip().startswith('//'):
                continue
            for literal in LITERAL.findall(line):
                used |= characters(literal)
    return {c for c in used if c.isprintable()}


used = used_characters()
unicodes = {ord(c) for c in used}
for first, last in RANGES:
    unicodes.update(range(first, last + 1))

options = subset.Options()
options.layout_features.append('tnum')
options.notdef_outline = True

missing = []
for source, bundled, location in FONTS:
    font = TTFont(SOURCE / source, recalcTimestamp=False)
    if location:
        font = instancer.instantiateVariableFont(font, location)
    subsetter = subset.Subsetter(options)
    subsetter.populate(unicodes=unicodes)
    subsetter.subset(font)
    font.save(BUNDLED / bundled)
    lacking = sorted(used - {chr(u) for u in font.getBestCmap()})
    if lacking:
        missing.append(f'{bundled}: ' + ' '.join(f'{c} (U+{ord(c):04X})' for c in lacking))
    print(f'{bundled}: {(SOURCE / source).stat().st_size} → {(BUNDLED / bundled).stat().st_size} bytes')

print('Characters used besides ASCII: ' + ''.join(sorted(used)))
if missing:
    sys.exit('Fonts without glyphs for characters the app uses:\n' + '\n'.join(missing))
PY
