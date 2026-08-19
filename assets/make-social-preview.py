#!/usr/bin/env python3
"""Regenerate assets/social-preview.svg — Claude Code welcome-screen aesthetic.

Shapes are wide horizontal slabs filled with a fine checkerboard dither, on a
dark terminal ground, with solid clay accents and scattered * sparkles.

    python3 assets/make-social-preview.py && \
      rsvg-convert assets/social-preview.svg -w 1280 -h 640 -o assets/social-preview.png
"""
import pathlib

BG      = "#22211F"
CLAY    = "#D97757"
INK     = "#E8E6E1"
MUTED   = "#8A8681"
RULE    = "#4A4744"

UW, UH   = 26, 16          # slab unit: wide, short
X0, Y0   = 78, 176
GAP      = 2               # visible banding between stacked slabs

# (row, col_start, col_end, style)
LEAF_R = [(3, 8, 9, "d35"), (4, 7, 10, "d50"), (5, 7, 11, "d50"), (6, 7, 10, "d65"), (7, 7, 8, "d65")]
LEAF_L = [(8, 4, 5, "d35"), (9, 2, 5, "d50"), (10, 1, 5, "d50"), (11, 2, 5, "d65"), (12, 4, 5, "d65")]
# Sparkles stay clear of the copy block (x 555-1220, y 150-545).
SPARK  = [(148, 250), (455, 214), (120, 452), (492, 392), (300, 138),
          (505, 560), (92, 336), (398, 592), (250, 108), (46, 168), (523, 300)]

def rect(x, y, w, h, fill):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}"/>'

def solid(row, c0, c1, rows=1):
    """One continuous clay/stem rect — no banding, like the reference's mascot."""
    return rect(X0 + c0 * UW, Y0 + row * UH,
                (c1 - c0 + 1) * UW - GAP, rows * UH - GAP, None)

def slab(row, c0, c1, fill):
    x = X0 + c0 * UW
    w = (c1 - c0 + 1) * UW - GAP
    y = Y0 + row * UH
    return f'<rect x="{x}" y="{y}" width="{w}" height="{UH - GAP}" fill="{fill}"/>'

DSC = 2   # dither sub-cell size in px — raise for coarser, more visible speckle

def dither(name, dark, light, on):
    """4x4 Bayer cell, `on` of 16 sub-cells lit, scaled by DSC."""
    order = [0,8,2,10, 12,4,14,6, 3,11,1,9, 15,7,13,5]
    n = 4 * DSC
    cells = "".join(
        f'<rect x="{(i%4)*DSC}" y="{(i//4)*DSC}" width="{DSC}" height="{DSC}" fill="{light}"/>'
        for i, t in enumerate(order) if t < on)
    return (f'<pattern id="{name}" width="{n}" height="{n}" patternUnits="userSpaceOnUse">'
            f'<rect width="{n}" height="{n}" fill="{dark}"/>{cells}</pattern>')

FILL = {"d35": "url(#d35)", "d50": "url(#d50)", "d65": "url(#d65)",
        "stem": "#3F8F58", "clay": CLAY}

def block(row, c0, c1, rows, fill):
    return rect(X0 + c0 * UW, Y0 + row * UH,
                (c1 - c0 + 1) * UW - GAP, rows * UH - GAP, fill)

body = [
    block(0, 0, 0, 16, CLAY),      # left bracket spine, one solid piece
    block(0, 1, 2, 1, CLAY),       # upper arm
    block(15, 1, 2, 1, CLAY),      # lower arm
    block(0, 13, 13, 16, CLAY),    # right bracket spine
    block(0, 11, 12, 1, CLAY),
    block(15, 11, 12, 1, CLAY),
    block(7, 6, 6, 8, "#3F8F58"),  # stem, one solid piece
]
for row, c0, c1, st in LEAF_R + LEAF_L:
    body.append(slab(row, c0, c1, FILL[st]))

sparks = "".join(
    f'<text x="{x}" y="{y}" font-family="Menlo, monospace" font-size="20" fill="{MUTED}" opacity="0.75">*</text>'
    for x, y in SPARK)

MONO = "Menlo, ui-monospace, monospace"
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1280 640" width="1280" height="640" shape-rendering="crispEdges">
  <defs>
    {dither("d35", "#143A22", "#8FE0A6", 6)}
    {dither("d50", "#143A22", "#A8ECBB", 8)}
    {dither("d65", "#143A22", "#C6F5D2", 11)}
  </defs>
  <rect width="1280" height="640" fill="{BG}"/>
  {sparks}
{chr(10).join("  " + b for b in body)}
  <g font-family="{MONO}">
    <text x="560" y="196" font-size="44" font-weight="700" fill="{CLAY}">claude-starters</text>
    <rect x="560" y="216" width="655" height="2" fill="{RULE}"/>
    <g font-size="23">
      <text x="560" y="278" fill="{CLAY}">&#10095;</text>
      <text x="592" y="278" fill="{INK}">/apply-starter rust --framework axum</text>
      <text x="592" y="320" fill="{MUTED}">tailored &#8212; CLAUDE.md for rust, axum pinned</text>
      <text x="592" y="356" fill="{MUTED}">experts  &#8212; 14 rust specialists, not all 76</text>
      <text x="592" y="392" fill="{MUTED}">lean     &#8212; skills idle until you touch .rs</text>
      <text x="560" y="458" fill="{CLAY}">&#10095;</text>
      <text x="592" y="458" fill="{INK}">git status --short</text>
      <text x="592" y="500" fill="{MUTED}">clean &#8212; <tspan fill="{CLAY}">zero</tspan> files added to your repo</text>
    </g>
    <rect x="560" y="536" width="655" height="2" fill="{RULE}"/>
  </g>
</svg>'''
pathlib.Path(__file__).with_name("social-preview.svg").write_text(svg)
print(f"{len(body)} slabs")
