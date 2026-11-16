"""Generate monochrome glyph-style commodity icons (64x64, white fill, negative-space gaps)."""
import math, os, sys

OUT = sys.argv[1]
GAP = 2.4  # width of the negative-space separation between overlapping parts
os.makedirs(OUT, exist_ok=True)


def f(v):
    return f"{v:.2f}".rstrip("0").rstrip(".")


def layered(name, shapes, extra_defs=""):
    """shapes: list of SVG element strings (no fill attr), back to front.
    Each shape is masked by every shape in front of it, grown by GAP."""
    defs, body = [], []
    for i, s in enumerate(shapes):
        front = shapes[i + 1:]
        if front:
            cut = "".join(
                s2.replace("/>", f' fill="#000" stroke="#000" stroke-width="{f(GAP * 2)}" stroke-linejoin="round"/>')
                for s2 in front)
            defs.append(f'<mask id="m{i}" maskUnits="userSpaceOnUse" x="0" y="0" width="64" height="64">'
                        f'<rect width="64" height="64" fill="#fff"/>{cut}</mask>')
            body.append(f'<g mask="url(#m{i})">{s}</g>')
        else:
            body.append(s)
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">\n'
           f'<defs>{"".join(defs)}{extra_defs}</defs>\n'
           f'<g fill="#fff" fill-rule="evenodd">\n' + "\n".join(body) + '\n</g>\n</svg>\n')
    with open(os.path.join(OUT, name), "w") as fh:
        fh.write(svg)


def ring_path(cx, cy, radii):
    """evenodd path of concentric circles."""
    d = ""
    for r in radii:
        d += (f"M{f(cx - r)} {f(cy)}a{f(r)} {f(r)} 0 1 0 {f(2 * r)} 0a{f(r)} {f(r)} 0 1 0 {f(-2 * r)} 0Z")
    return f'<path d="{d}"/>'


def poly(pts):
    return '<polygon points="' + " ".join(f"{f(x)},{f(y)}" for x, y in pts) + '"/>'


# ---------- Flat coin with G ----------
g_mask = ('<mask id="g" maskUnits="userSpaceOnUse" x="0" y="0" width="64" height="64">'
          '<rect width="64" height="64" fill="#fff"/>'
          '<path d="M40.5 23.5A12 12 0 1 0 44 32H33" fill="none" stroke="#000" stroke-width="5.5" '
          'stroke-linecap="butt" stroke-linejoin="miter"/></mask>')
with open(os.path.join(OUT, "CoinG.svg"), "w") as fh:
    fh.write('<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">\n'
             f'<defs>{g_mask}</defs>\n'
             f'<g fill="#fff" fill-rule="evenodd" mask="url(#g)">{ring_path(32, 32, [28, 23.5, 21])}</g>\n</svg>\n')

# ---------- Wheat ----------
def grain(cx, cy, ang, rx=4.6, ry=8.2):
    return f'<ellipse cx="{f(cx)}" cy="{f(cy)}" rx="{f(rx)}" ry="{f(ry)}" transform="rotate({f(ang)} {f(cx)} {f(cy)})"/>'


stem = '<rect x="30.5" y="20" width="3" height="41" rx="1.5"/>'
leaf = '<path d="M32 60C25 58 19 53 16 45C23 46 29 50 32 55Z"/>'
wheat = [stem, leaf]
for y in (43, 33.5, 24):
    wheat += [grain(26.6, y, -38, 3.9, 7.6), grain(37.4, y, 38, 3.9, 7.6)]
wheat.append(grain(32, 13, 0, 3.9, 7.8))
layered("Wheat.svg", wheat)

# ---------- Iron ingot ----------
# Built as a real 3D tapered block, rotated so its long axis runs diagonally ('/'),
# then fitted to the 64x64 canvas. Only camera-facing faces are drawn.
ING_LEN, ING_WID, ING_HGT, ING_INSET = 44, 20, 14, 5  # base length/width, height, top inset
ING_YAW, ING_PITCH, ING_ROLL = 30, 40, -12             # degrees: turn, look-down, screen rotation
ING_MARGIN_X, ING_MARGIN_Y = 0, 4  # fills the full width; height capped to match the other icons


def ingot_faces():
    hl, hw = ING_LEN / 2, ING_WID / 2
    tl, tw = hl - ING_INSET, hw - ING_INSET * 0.6
    base = [(-hl, -hw, 0), (hl, -hw, 0), (hl, hw, 0), (-hl, hw, 0)]
    top_ = [(-tl, -tw, ING_HGT), (tl, -tw, ING_HGT), (tl, tw, ING_HGT), (-tl, tw, ING_HGT)]
    v = base + top_
    # quads, wound counter-clockwise when seen from outside
    quads = [(4, 5, 6, 7), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]
    y, p, r = (math.radians(a) for a in (ING_YAW, ING_PITCH, ING_ROLL))
    pts = []
    for x, yy, z in v:
        x, yy = x * math.cos(y) - yy * math.sin(y), x * math.sin(y) + yy * math.cos(y)  # yaw
        yy, z = yy * math.cos(p) - z * math.sin(p), yy * math.sin(p) + z * math.cos(p)  # pitch
        sx, sy = x, -z  # orthographic: view along +y, screen y down
        sx, sy = sx * math.cos(r) - sy * math.sin(r), sx * math.sin(r) + sy * math.cos(r)  # roll
        pts.append((sx, sy))
    xs, ys = [q[0] for q in pts], [q[1] for q in pts]
    scale = min((64 - 2 * ING_MARGIN_X) / (max(xs) - min(xs)), (64 - 2 * ING_MARGIN_Y) / (max(ys) - min(ys)))
    cx, cy = (max(xs) + min(xs)) / 2, (max(ys) + min(ys)) / 2
    pts = [(32 + (a - cx) * scale, 32 + (b - cy) * scale) for a, b in pts]
    faces = []
    for q in quads:
        a, b, c = pts[q[0]], pts[q[1]], pts[q[2]]
        cross = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
        if cross < 0:  # facing the camera (screen y is flipped)
            faces.append(poly([pts[k] for k in q]))
    return faces


layered("IronIngot.svg", ingot_faces())
print("done")
