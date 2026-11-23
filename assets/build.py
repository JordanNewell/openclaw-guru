#!/usr/bin/env python3
"""Regenerate openclaw-guru brand assets. Text is outlined to paths, so SVGs
render identically everywhere. Edit VERSION and re-run when the verified window moves.
Needs: pip install fonttools cairosvg"""
import sys, pathlib
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
import cairosvg

VERSION = sys.argv[1] if len(sys.argv) > 1 else "v2026.11.5"
OUT = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else pathlib.Path("out")
OUT.mkdir(parents=True, exist_ok=True)

FONT_DIR = "/usr/share/fonts/truetype/dejavu/"
bold = TTFont(FONT_DIR + "DejaVuSansMono-Bold.ttf")
reg = TTFont(FONT_DIR + "DejaVuSansMono.ttf")

def text_path(font, s, x, y, size):
    """Return (svg path d, advance width) for s with baseline at (x, y)."""
    gs, cmap, hmtx = font.getGlyphSet(), font.getBestCmap(), font["hmtx"]
    scale = size / font["head"].unitsPerEm
    pen = SVGPathPen(gs)
    cx = x
    for ch in s:
        name = cmap[ord(ch)]
        tp = TransformPen(pen, (scale, 0, 0, -scale, cx, y))
        gs[name].draw(tp)
        cx += hmtx[name][0] * scale
    return pen.getCommands(), cx - x

def mark(x, y, s, cls_fg="fg", cls_ac="ac", frame_w=3, slash_w=7):
    k = s / 96
    def L(x1, y1, x2, y2, cls, w):
        return (f'<line x1="{x+x1*k:.1f}" y1="{y+y1*k:.1f}" x2="{x+x2*k:.1f}" y2="{y+y2*k:.1f}" '
                f'class="{cls}s" stroke-width="{w*k:.1f}"/>')
    return (f'<rect x="{x+frame_w*k/2:.1f}" y="{y+frame_w*k/2:.1f}" width="{s-frame_w*k:.1f}" '
            f'height="{s-frame_w*k:.1f}" rx="{2*k:.1f}" fill="none" class="{cls_fg}s" stroke-width="{frame_w*k:.1f}"/>'
            + L(20, 78, 42, 22, cls_fg, slash_w) + L(40, 84, 68, 14, cls_ac, slash_w)
            + L(62, 78, 80, 32, cls_fg, slash_w))

def path(font, s, x, y, size, cls):
    d, w = text_path(font, s, x, y, size)
    return f'<path d="{d}" class="{cls}"/>', w

STYLE_DARK = """.fg{fill:#ECEAE4}.mu{fill:#8A8880}.fgs{stroke:#ECEAE4}.acs{stroke:#EF9F27}
.rd{fill:#E24B4A}.gn{fill:#7DB33A}.rule{stroke:#2A2D33}.mus{stroke:#8A8880}"""

# ---------- social preview 1280x640 ----------
def social():
    parts = []
    parts.append('<rect width="1280" height="640" fill="#0E1013"/>')
    parts.append(mark(1010, 80, 190))
    parts.append('<rect x="80" y="152" width="6" height="40" class="rd"/>')
    p, w = path(reg, "- docs summaries", 108, 184, 36, "mu"); parts.append(p)
    parts.append(f'<line x1="108" y1="173" x2="{108+w:.0f}" y2="173" class="mus" stroke-width="3"/>')
    parts.append('<rect x="80" y="214" width="6" height="40" class="gn"/>')
    p, _ = path(bold, "+ battle scars", 108, 246, 36, "fg"); parts.append(p)
    p, _ = path(bold, "openclaw-guru", 76, 420, 102, "fg"); parts.append(p)
    parts.append('<line x1="80" y1="470" x2="1200" y2="470" class="rule" stroke-width="2"/>')
    p, _ = path(reg, f"Verified against OpenClaw {VERSION} · MIT", 80, 535, 28, "mu"); parts.append(p)
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="640" viewBox="0 0 1280 640" role="img">'
           f'<title>openclaw-guru: battle scars, not docs summaries</title><style>{STYLE_DARK}</style>'
           + "".join(parts) + '</svg>')
    (OUT / "social-preview.svg").write_text(svg)
    cairosvg.svg2png(bytestring=svg.encode(), write_to=str(OUT / "social-preview.png"), output_width=1280, output_height=640)

# ---------- README header 1280x300, light/dark aware, transparent ----------
def header():
    style = (".fg{fill:#1F2328}.mu{fill:#656D76}.fgs{stroke:#1F2328}.acs{stroke:#BA7517}"
             "@media (prefers-color-scheme:dark){.fg{fill:#ECEAE4}.mu{fill:#9A9890}.fgs{stroke:#ECEAE4}.acs{stroke:#EF9F27}}")
    parts = [mark(60, 95, 110)]
    p, _ = path(bold, "openclaw-guru", 208, 152, 72, "fg"); parts.append(p)
    p, _ = path(reg, "Battle scars, not docs summaries", 212, 200, 30, "mu"); parts.append(p)
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="300" viewBox="0 0 1280 300" role="img">'
           f'<title>openclaw-guru: battle scars, not docs summaries</title><style>{style}</style>'
           + "".join(parts) + '</svg>')
    (OUT / "readme-header.svg").write_text(svg)

# ---------- avatar 512x512 ----------
def avatar():
    parts = ['<rect width="512" height="512" fill="#0E1013"/>', mark(118, 118, 276, frame_w=4, slash_w=8)]
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512" role="img">'
           f'<title>openclaw-guru</title><style>{STYLE_DARK}</style>' + "".join(parts) + '</svg>')
    (OUT / "avatar.svg").write_text(svg)
    cairosvg.svg2png(bytestring=svg.encode(), write_to=str(OUT / "avatar.png"), output_width=512, output_height=512)

social(); header(); avatar()
print("built", VERSION, "->", OUT)
