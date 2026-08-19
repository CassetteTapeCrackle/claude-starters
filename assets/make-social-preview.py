#!/usr/bin/env python3
"""Regenerate assets/social-preview.svg — Claude Code welcome-screen aesthetic.

Wide slabs with a Bayer-dithered fill on a dark terminal ground, solid clay
accents, scattered * sparkles, terminal-style copy.

    python3 assets/make-social-preview.py && \
      rsvg-convert assets/social-preview.svg -w 1280 -h 640 -o assets/social-preview.png
"""
import pathlib

W, H = 1280, 640
BG, CLAY, INK, MUTED, RULE = "#F0EEE6", "#C9603C", "#1F1E1D", "#6B6862", "#CFC9BE"
STEM_G = "#3F8F58"
BRACKET = "#D97757"
SPARK_C = "#B9B2A6"

# ---- mark geometry -------------------------------------------------------
# 14 cols x 16 rows. Bracket spines at col 0 / col 13, arms at cols 1-2 / 11-12
# (rows 0 and 15 only). The plant must stay inside cols 2..11 so it never
# touches the frame.
UW, UH, GAP = 24, 17, 2
COLS, ROWS = 14, 16
X0 = 96
Y0 = (H - ROWS * UH) // 2                     # vertically centred

# Both leaves fan from the upper stem; the stem then descends. Keeps the mark
# centred in the frame instead of reading as a diagonal staircase.
LEAF_R = [(3, 9, 10, "d35"), (4, 8, 11, "d50"), (5, 7, 10, "d65"), (6, 7, 8, "d65")]
LEAF_L = [(5, 3, 4, "d35"), (6, 2, 5, "d50"), (7, 3, 5, "d65"), (8, 4, 5, "d65")]

# ---- copy geometry -------------------------------------------------------
TX, CX = 560, 596                              # prompt column, content column
Y_TITLE, Y_RULE1 = 172, 194
Y_CMD1, Y_A1, Y_A2, Y_A3 = 256, 296, 330, 364
Y_CMD2, Y_A4 = 426, 466
Y_RULE2 = 506
RULE_W = 620

# sparkles: clear of the mark (x 90-440, y Y0..Y0+272) and the copy block
SPARK = [(60, 112), (252, 118), (470, 176), (500, 306), (44, 300),
         (474, 512), (196, 588), (640, 590), (996, 604), (1168, 96), (312, 604)]

DSC = 2                                        # dither sub-cell px; raise = coarser

def dither(name, dark, light, on):
    order = [0,8,2,10, 12,4,14,6, 3,11,1,9, 15,7,13,5]   # Bayer 4x4
    n = 4 * DSC
    cells = "".join(
        f'<rect x="{(i%4)*DSC}" y="{(i//4)*DSC}" width="{DSC}" height="{DSC}" fill="{light}"/>'
        for i, t in enumerate(order) if t < on)
    return (f'<pattern id="{name}" width="{n}" height="{n}" patternUnits="userSpaceOnUse">'
            f'<rect width="{n}" height="{n}" fill="{dark}"/>{cells}</pattern>')

FILL = {"d35": "url(#d35)", "d50": "url(#d50)", "d65": "url(#d65)"}

def block(row, c0, c1, rows, fill):
    return (f'<rect x="{X0 + c0*UW}" y="{Y0 + row*UH}" '
            f'width="{(c1-c0+1)*UW - GAP}" height="{rows*UH - GAP}" fill="{fill}"/>')

body = [
    block(0, 0, 0, ROWS, BRACKET),     # left spine, one solid piece
    block(0, 1, 2, 1, BRACKET),
    block(15, 1, 2, 1, BRACKET),
    block(0, 13, 13, ROWS, BRACKET),   # right spine
    block(0, 11, 12, 1, BRACKET),
    block(15, 11, 12, 1, BRACKET),
    block(6, 6, 6, 9, STEM_G),         # stem, centred on the grid
]
for row, c0, c1, st in LEAF_R + LEAF_L:
    body.append(block(row, c0, c1, 1, FILL[st]))

# guard: nothing green may stray onto the frame columns
for row, c0, c1, _ in LEAF_R + LEAF_L:
    assert 2 <= c0 <= c1 <= 11, f"leaf row {row} escapes the frame: {c0}..{c1}"

sparks = "".join(
    f'<text x="{x}" y="{y}" font-family="Menlo, monospace" font-size="19" '
    f'fill="{SPARK_C}" opacity="0.9">*</text>' for x, y in SPARK)

MONO = "Menlo, ui-monospace, monospace"
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" shape-rendering="crispEdges">
  <defs>
    {dither("d35", "#E4F0E4", "#4E9A64", 6)}
    {dither("d50", "#E4F0E4", "#3C8552", 8)}
    {dither("d65", "#E4F0E4", "#2E7044", 11)}
  </defs>
  <rect width="{W}" height="{H}" fill="{BG}"/>
  {sparks}
{chr(10).join("  " + b for b in body)}
  <g font-family="{MONO}">
    <text x="{TX}" y="{Y_TITLE}" font-size="42" font-weight="700" fill="{CLAY}">claude-starters</text>
    <rect x="{TX}" y="{Y_RULE1}" width="{RULE_W}" height="2" fill="{RULE}"/>
    <g font-size="23">
      <text x="{TX}" y="{Y_CMD1}" fill="{CLAY}">&#10095;</text>
      <text x="{CX}" y="{Y_CMD1}" fill="{INK}">/apply-starter rust --framework axum</text>
      <text x="{CX}" y="{Y_A1}" fill="{MUTED}">tailored &#8212; CLAUDE.md for rust, axum pinned</text>
      <text x="{CX}" y="{Y_A2}" fill="{MUTED}">experts  &#8212; 14 rust specialists, not all 76</text>
      <text x="{CX}" y="{Y_A3}" fill="{MUTED}">lean     &#8212; skills idle until you touch .rs</text>
      <text x="{TX}" y="{Y_CMD2}" fill="{CLAY}">&#10095;</text>
      <text x="{CX}" y="{Y_CMD2}" fill="{INK}">git status --short</text>
      <text x="{CX}" y="{Y_A4}" fill="{MUTED}">clean &#8212; <tspan fill="{CLAY}">zero</tspan> files added to your repo</text>
    </g>
    <rect x="{TX}" y="{Y_RULE2}" width="{RULE_W}" height="2" fill="{RULE}"/>
  </g>
</svg>'''
pathlib.Path(__file__).with_name("social-preview.svg").write_text(svg)
print(f"mark: {COLS*UW}x{ROWS*UH} at ({X0},{Y0})  |  {len(body)} shapes")
