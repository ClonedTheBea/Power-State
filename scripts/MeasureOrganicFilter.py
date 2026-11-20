"""Read-only measurement of retained Studio lossless coverage probes.

Pixels encode white land / black water through the real four-chunk display path.
The observed straight ports calibrate viewport PNG offset (0, 58). Measurements
are local witnesses, not an exhaustive supremum across corners/camera phases.
"""
from pathlib import Path
import json
import math
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/evidence/illustrated-world-v14'
CASES = [
    ('filter-r17-180-lossless.png', 603, 427, 116, 1.8, 'Default'),
    ('filter-r17-180-nearest.png', 603, 427, 116, 1.8, 'Pixelated'),
    ('filter-r17-055-nearest.png', 683, 427, 36, .55, 'Pixelated'),
]
results = []
for name, left, top, width, zoom, mode in CASES:
    im = Image.open(BASE / name).convert('RGB')
    top += 58
    outward, inward, extent = [], [], []
    for py in range(top, top + width):
        for px in range(left, left + width):
            x = 256 + (px + .5 - left) * 64 / width
            y = 704 + (py + .5 - top) * 64 / width
            if not (303 <= x <= 320 and 704 <= y <= 721):
                continue
            value = im.getpixel((px, py))[0]
            distance = math.hypot(x - 303, y - 721) - 17
            if value > 0:
                outward.append((distance, px, py, value))
                for dx in (-.5, .5):
                    for dy in (-.5, .5):
                        extent.append(math.hypot(x + dx*64/width - 303,
                                                 y + dy*64/width - 721) - 17)
            if value < 255:
                inward.append((-distance, px, py, value))
    results.append(dict(image=name, zoom=zoom, filter=mode,
                        outwardPixelCentre=max(outward), inwardPixelCentre=max(inward),
                        outwardFullPixelExtent=max(extent)))
assert results[0]['outwardPixelCentre'][0] > 1, 'Retain bilinear gate failure'
assert results[2]['outwardFullPixelExtent'] > 1, 'Nearest is not full-footprint acceptance'
print(json.dumps({'allowanceWU': 1, 'gate': 'FAIL / not accepted', 'measurements': results}, indent=2))
