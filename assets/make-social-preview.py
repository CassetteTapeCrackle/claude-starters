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
BRACKET, STEM_G, SOIL = "#D97757", "#2E7044", "#B8875F"
SPARK_C = "#B9B2A6"

# ---- mark geometry -------------------------------------------------------
UW, UH, GAP = 14, 11, 1         # sized so the mark matches the copy block's height
COLS, ROWS = 28, 34
X0 = 74
Y0 = (H - ROWS * UH) // 2

SPINE_L, SPINE_R = (0, 1), (26, 27)
ARM_L, ARM_R = (2, 6), (21, 25)
ARM_ROWS = ((0, 2), (32, 2))     # (start_row, thickness)

# (row, col_start, col_end, density) — density carries depth: d25 sits back,
# d75 comes forward, so overlapping leaves separate without outlines.
# Two opposite leaf pairs plus a terminal bud: reads as a sprout, not a conifer.
BUD     = [(3, 13, 14, "d50"), (4, 12, 15, "d75"), (5, 12, 15, "d75")]

UPPER_R = [(6, 19, 22, "d25"), (7, 17, 22, "d50"), (8, 15, 21, "d75"), (9, 15, 18, "d50")]
UPPER_L = [(7, 5, 8, "d25"), (8, 5, 10, "d50"), (9, 6, 12, "d75"), (10, 9, 12, "d50")]

LOWER_R = [(17, 17, 21, "d25"), (18, 15, 22, "d50"), (19, 15, 20, "d50"), (20, 15, 17, "d25")]
LOWER_L = [(19, 6, 11, "d25"), (20, 5, 12, "d50"), (21, 6, 12, "d50"), (22, 9, 12, "d25")]

LEAVES = BUD + UPPER_R + UPPER_L + LOWER_R + LOWER_L

STEM = [(5, 13, 13, 12),                       # (row, c0, c1, rows) solid
        (17, 13, 14, 11)]                      # tapers wider toward the soil
SOIL_ROWS = [(28, 10, 17), (29, 9, 18), (30, 8, 19)]

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

body = [
    block(0, *SPINE_L, ROWS, "url(#brace)"),
    block(0, *SPINE_R, ROWS, "url(#brace)"),
]
for r0, th in ARM_ROWS:
    body.append(block(r0, *ARM_L, th, "url(#brace)"))
    body.append(block(r0, *ARM_R, th, "url(#brace)"))

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
    {dither("brace", "#D97757", "#EBA98F", 3)}
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
