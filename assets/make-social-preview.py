#!/usr/bin/env python3
"""Regenerate assets/social-preview.svg.

Claude Code welcome-screen idiom: wide horizontal slabs with a Bayer-dithered
fill, solid clay accents, scattered * sparkles, terminal-style copy, on cream.

The mark is a sprout inside code brackets. Depth comes from dither density —
d25 reads as furthest back, d75 as nearest front — so overlapping leaves
separate without outlines.

    python3 assets/make-social-preview.py && \
      rsvg-convert assets/social-preview.svg -w 1280 -h 640 -o assets/social-preview.png
"""
import pathlib

W, H = 1280, 640
BG, CLAY, INK, MUTED, RULE = "#F0EEE6", "#C9603C", "#1F1E1D", "#6B6862", "#CFC9BE"
BRACKET, STEM_G, SOIL = "#D97757", "#35784A", "#B8875F"
SPARK_C = "#B9B2A6"

# ---- mark geometry -------------------------------------------------------
UW, UH, GAP = 14, 11, 1         # sized so the mark matches the copy block's height
COLS, ROWS = 28, 34
X0 = 74
Y0 = (H - ROWS * UH) // 2

SPINE_L, SPINE_R = (0, 1), (26, 27)
ARM_L, ARM_R = (2, 6), (21, 25)
ARM_ROWS = ((0, 2), (32, 2))     # (start_row, thickness)

# One density per leaf, never per row: grading rows inside a leaf puts a hard
# dark line through its middle, which reads as a plank with a drop shadow.
# Depth comes from giving whole leaves different densities.
#
# Each leaf is a diagonal blade stepping outward and upward from the stem, two
# rows per step so it has body — one row per step reads as a thin ribbon.
# d25 is unused for leaves: at this size it renders as a ghost.
#
# Stem is one cell (col 13); left leaves attach at col 12, right at col 14.

def blade(base_row, going_right, density, steps=3):
    """Diagonal blade: `steps` steps of 2 rows, sweeping out and up from the
    stem. Fewer steps for newer growth near the tip."""
    spans = [(14, 17), (16, 20), (19, 22)] if going_right else [(9, 12), (6, 10), (5, 7)]
    out = []
    for i, (a, b) in enumerate(spans[:steps]):
        top = base_row - 2 * i
        out += [(top, a, b, density), (top - 1, a, b, density)]
    return out

# growing tip: just the stem carried up. Anything wider than the stem here
# reads as a cap or a crossbar, whatever size it is.
BUD = [(3, 13, 13, "d50"), (4, 13, 13, "d75")]

LEAF_L1 = blade(10, False, "d50", steps=2)   # newest growth, shorter
LEAF_R1 = blade(15, True,  "d75")
LEAF_L2 = blade(21, False, "d75")
LEAF_R2 = blade(26, True,  "d50")

LEAVES = BUD + LEAF_L1 + LEAF_R1 + LEAF_L2 + LEAF_R2

STEM = [(5, 13, 13, 24)]                       # (row, c0, c1, rows) one cell wide
SOIL_ROWS = [(29, 10, 16), (30, 9, 17)]

# ---- copy ----------------------------------------------------------------
TX, CX, DX = 560, 596, 716
Y_TITLE, Y_RULE1 = 170, 192
Y_CMD = 250
Y_R1, Y_R2, Y_R3 = 302, 340, 378
Y_RULE2 = 420
Y_F1, Y_F2 = 458, 494
RULE_W = 624

SPARK = [(62, 112), (250, 104), (470, 168), (498, 300), (46, 300),
         (472, 508), (196, 586), (648, 588), (1000, 602), (1170, 96), (316, 602)]

DSC = 2
BRACE_RAMP = [16, 15, 13, 12, 10, 9, 8, 7]   # dots per 16-cell Bayer block;
                                             # floor stays high or the spine
                                             # goes translucent mid-bracket

def dither(name, light_bg, dot, on):
    order = [0,8,2,10, 12,4,14,6, 3,11,1,9, 15,7,13,5]     # Bayer 4x4
    n = 4 * DSC
    cells = "".join(
        f'<rect x="{(i%4)*DSC}" y="{(i//4)*DSC}" width="{DSC}" height="{DSC}" fill="{dot}"/>'
        for i, t in enumerate(order) if t < on)
    return (f'<pattern id="{name}" width="{n}" height="{n}" patternUnits="userSpaceOnUse">'
            f'<rect width="{n}" height="{n}" fill="{light_bg}"/>{cells}</pattern>')

def block(row, c0, c1, rows, fill):
    return (f'<rect x="{X0 + c0*UW}" y="{Y0 + row*UH}" '
            f'width="{(c1-c0+1)*UW - GAP}" height="{rows*UH - GAP}" fill="{fill}"/>')

BRACE_STEPS = len(BRACE_RAMP)   # dither ramp: 0 = solid, last = lightest

def brace_density(row):
    """Solid at the base, dissolving upward — the frame reads as growing with
    the plant rather than draining into the ground."""
    up = (ROWS - 1 - row) / (ROWS - 1)
    return min(BRACE_STEPS - 1, int(up * BRACE_STEPS))

def spine(c0, c1):
    """One continuous spine, banded by density. No GAP between bands, or the
    ramp would read as a stack of separate slabs."""
    out = []
    for r in range(ROWS):
        out.append(f'<rect x="{X0 + c0*UW}" y="{Y0 + r*UH}" '
                   f'width="{(c1-c0+1)*UW - GAP}" height="{UH}" '
                   f'fill="url(#brace{brace_density(r)})"/>')
    return out

body = spine(*SPINE_L) + spine(*SPINE_R)
for r0, th in ARM_ROWS:
    d = brace_density(r0)          # arms join the ramp, or the corner
                                   # jumps back to solid below a faded spine
    body.append(block(r0, *ARM_L, th, f"url(#brace{d})"))
    body.append(block(r0, *ARM_R, th, f"url(#brace{d})"))

for row, c0, c1, rows in STEM:
    body.append(block(row, c0, c1, rows, STEM_G))
for row, c0, c1, dens in LEAVES:
    body.append(block(row, c0, c1, 1, f"url(#{dens})"))
for row, c0, c1 in SOIL_ROWS:
    body.append(block(row, c0, c1, 1, "url(#soil)"))

# guard: the plant keeps 3 clear cells from the spines and never reaches the
# arm rows, so it can't visually fuse with the frame.
SAFE_C, SAFE_R = (5, 22), (3, 30)
for row, c0, c1, *_ in LEAVES:
    assert SAFE_C[0] <= c0 <= c1 <= SAFE_C[1], f"leaf row {row} crowds the frame: {c0}..{c1}"
    assert SAFE_R[0] <= row <= SAFE_R[1], f"leaf row {row} outside safe rows"
for row, c0, c1 in SOIL_ROWS:
    assert SAFE_C[0] <= c0 <= c1 <= SAFE_C[1], f"soil row {row} crowds the frame: {c0}..{c1}"
    assert row <= SAFE_R[1], f"soil row {row} reaches the arm rows"

# Every leaf slab must reach the stem through its neighbours. Without this a
# slab can sit one cell clear of the stem and silently render as a floating
# object — which is exactly what the one-sided taper used to cause.
_cells = {}
for _row, _c0, _c1, _rows in STEM:
    for _r in range(_row, _row + _rows):
        for _c in range(_c0, _c1 + 1):
            _cells[(_c, _r)] = "stem"
for _row, _c0, _c1, _d in LEAVES:
    for _c in range(_c0, _c1 + 1):
        _cells.setdefault((_c, _row), "leaf")
_seen = {q for q, v in _cells.items() if v == "stem"}
_stack = list(_seen)
while _stack:
    _c, _r = _stack.pop()
    for _n in ((_c+1, _r), (_c-1, _r), (_c, _r+1), (_c, _r-1)):
        if _n in _cells and _n not in _seen:
            _seen.add(_n); _stack.append(_n)
for _row, _c0, _c1, _d in LEAVES:
    assert any((_c, _row) in _seen for _c in range(_c0, _c1 + 1)), \
        f"leaf slab row {_row} cols {_c0}-{_c1} floats free of the stem"

sparks = "".join(
    f'<text x="{x}" y="{y}" font-family="Menlo, monospace" font-size="19" '
    f'fill="{SPARK_C}" opacity="0.9">*</text>' for x, y in SPARK)

MONO = "Menlo, ui-monospace, monospace"
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" shape-rendering="crispEdges">
  <defs>
    {dither("d25", "#E8F1E7", "#5CA574", 4)}
    {dither("d50", "#E8F1E7", "#3C8552", 8)}
    {dither("d75", "#E8F1E7", "#2A6740", 12)}
    {dither("soil", "#EDE3D8", "#B8875F", 9)}
    {"".join(dither(f"brace{i}", "#F0EEE6", "#D97757", d) for i, d in enumerate(BRACE_RAMP))}
  </defs>
  <rect width="{W}" height="{H}" fill="{BG}"/>
  {sparks}
{chr(10).join("  " + b for b in body)}
  <g font-family="{MONO}">
    <text x="{TX}" y="{Y_TITLE}" font-size="42" font-weight="700" fill="{CLAY}">claude-starters</text>
    <rect x="{TX}" y="{Y_RULE1}" width="{RULE_W}" height="2" fill="{RULE}"/>
    <g font-size="23">
      <text x="{TX}" y="{Y_CMD}" fill="{CLAY}">&#10095;</text>
      <text x="{CX}" y="{Y_CMD}" fill="{INK}">/apply-starter &lt;your stack&gt;</text>
      <text x="{CX}" y="{Y_R1}" fill="{CLAY}">tailored</text>
      <text x="{DX}" y="{Y_R1}" fill="{INK}">rules written for your project</text>
      <text x="{CX}" y="{Y_R2}" fill="{CLAY}">experts</text>
      <text x="{DX}" y="{Y_R2}" fill="{INK}">language specialists, per stack</text>
      <text x="{CX}" y="{Y_R3}" fill="{CLAY}">lean</text>
      <text x="{DX}" y="{Y_R3}" fill="{INK}">loads only what the task needs</text>
    </g>
    <rect x="{TX}" y="{Y_RULE2}" width="{RULE_W}" height="2" fill="{RULE}"/>
    <g font-size="21" fill="{MUTED}">
      <text x="{TX}" y="{Y_F1}">23 starters &#183; 76 agents &#183; 9 depth skills</text>
      <text x="{TX}" y="{Y_F2}">nothing committed &#8212; zero files added to your repo</text>
    </g>
  </g>
</svg>'''
pathlib.Path(__file__).with_name("social-preview.svg").write_text(svg)
print(f"mark {COLS*UW}x{ROWS*UH} at ({X0},{Y0}) | {len(body)} shapes, {len(LEAVES)} leaf slabs")
