"""Independent integer reference for approved P2b v1 climate gates; no Roblox integration.

Runs exact Python integer arithmetic rather than Luau limb operations. The radial
transition is sampled outside all starter reservations, so this gate does not
need an implementation of the future pad/corridor geometry.
"""
from functools import lru_cache
from pathlib import Path
import argparse
import hashlib
import json
import struct

Q = 4096
TAGS = {'elevation-coarse', 'elevation-fine', 'temperature', 'rainfall', 'start-layout', 'town-name'}


def fnv(data: bytes) -> int:
    h = 2166136261
    for byte in data:
        h = ((h ^ byte) * 16777619) & 0xffffffff
    return h


def smooth(u: int) -> int:
    assert 0 <= u <= Q
    return (u * u * (3 * Q - 2 * u) + Q * Q // 2) // (Q * Q)


def lerp(a: int, b: int, w: int) -> int:
    return a + ((b - a) * w + Q // 2) // Q


@lru_cache(maxsize=32768)
def keyed(seed: bytes, tag: str, x: int, y: int, index: int = 0) -> int:
    assert len(seed) == 16 and tag in TAGS
    data = (b'PS2B\0' + seed + struct.pack('<I', 1) + bytes([len(tag)])
            + tag.encode('ascii') + struct.pack('<iiI', x, y, index))
    return fnv(data)


def field(seed: bytes, tag: str, x: int, y: int, spacing: int, low: int, high: int) -> int:
    ix, rx = divmod(x, spacing)
    iy, ry = divmod(y, spacing)
    wx, wy = smooth(rx * Q // spacing), smooth(ry * Q // spacing)
    def sample(dx, dy):
        return low + ((keyed(seed, tag, ix + dx, iy + dy) >> 16) * (high - low + 1) // 65536)
    return lerp(lerp(sample(0, 0), sample(1, 0), wx),
                lerp(sample(0, 1), sample(1, 1), wx), wy)


def climate(seed: bytes, x: int, y: int, outer_radius: int = 4608) -> dict:
    elevation = (60 + field(seed, 'elevation-coarse', x, y, 512, -160, 160)
                 + field(seed, 'elevation-fine', x, y, 128, -40, 40))
    raw = field(seed, 'temperature', x, y, 8192, -2000, 3000)
    # -0.006 C/m = -0.6 centidegrees/m; ties toward positive infinity.
    lapse = (-6 * max(elevation, 0) + 5) // 10
    rain = field(seed, 'rainfall', x, y, 4096, 200, 2400)
    radius2 = (x - 512) ** 2 + (y - 512) ** 2
    u = max(0, min(Q, (radius2 - 2048**2) * Q // (outer_radius**2 - 2048**2)))
    weight = Q - smooth(u)
    return {'x': x, 'y': y, 'elevationM': elevation, 'rawTemperatureCentiC': raw,
            'lapseCentiC': lapse, 'temperateWeightQ12': weight,
            'temperatureCentiC': lerp(raw + lapse, 1700, weight),
            'rainfallMm': lerp(rain, 1000, weight)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--seeds', type=int, default=256)
    parser.add_argument("--outer-radius", type=int, choices=(4096, 4608), default=4608,
                        help="4608 is amended approved v1; 4096 reproduces the superseded failure")
    args = parser.parse_args()
    assert 1 <= args.seeds <= 10000
    assert [fnv(s) for s in (b'', b'a', b'foobar')] == [0x811c9dc5, 0xe40c292c, 0xbf9cf968]
    assert [smooth(x) for x in (0, 2048, 4096)] == [0, 2048, 4096]
    result = {'kind': 'independent Python arithmetic, not Luau/Studio', 'seedCount': args.seeds,
              'outerRadius': args.outer_radius, 'approvedContract': args.outer_radius == 4608,
              'sampling': f'64-unit global grid along four cardinal rays through (512,512), radii 2048..{args.outer_radius}; consecutive pairs',
              'temperatureLimitCentiC': 200, 'rainfallLimitMm': 150,
              'pairs': 0, 'temperatureViolations': 0, 'rainfallViolations': 0,
              'maxTemperatureDifferenceCentiC': 0, 'maxRainfallDifferenceMm': 0,
              'firstViolation': None, 'worstTemperaturePair': None,
              'canonicalVectors': []}
    for i in range(args.seeds):
        # Deterministic adversarial corpus; hashes are fixture seed creation, not the world algorithm.
        seed = bytearray(hashlib.sha256(f'PowerState-P2b-climate-gate:{i}'.encode()).digest()[:16])
        seed[6] = (seed[6] & 15) | 64
        seed[8] = (seed[8] & 63) | 128
        seed = bytes(seed)
        if i < 3:
            result['canonicalVectors'].append({'seed': seed.hex(), 'tag': 'temperature', 'x': -1, 'y': 0,
                                               'index': 0, 'hash': f'{keyed(seed,"temperature",-1,0):08x}'})
        for dx, dy in ((1, 0), (0, 1), (-1, 0), (0, -1)):
            previous = climate(seed, 512 + dx*2048, 512 + dy*2048, args.outer_radius)
            for radius in range(2112, args.outer_radius + 1, 64):
                current = climate(seed, 512 + dx*radius, 512 + dy*radius, args.outer_radius)
                dt = abs(current['temperatureCentiC'] - previous['temperatureCentiC'])
                dr = abs(current['rainfallMm'] - previous['rainfallMm'])
                pair = {'seedIndex': i, 'seed': seed.hex(), 'a': previous, 'b': current, 'deltaCentiC': dt, 'deltaRainfallMm': dr}
                result['pairs'] += 1
                if dt > result['maxTemperatureDifferenceCentiC']:
                    result['maxTemperatureDifferenceCentiC'] = dt
                    result['worstTemperaturePair'] = pair
                result['maxRainfallDifferenceMm'] = max(dr, result['maxRainfallDifferenceMm'])
                if dt > 200: result['temperatureViolations'] += 1
                if dr > 150: result['rainfallViolations'] += 1
                if (dt > 200 or dr > 150) and result['firstViolation'] is None:
                    result['firstViolation'] = pair
                previous = current
    result['passed'] = result['temperatureViolations'] == result['rainfallViolations'] == 0
    filename = 'P2B-CLIMATE-REPLAY-4096.json' if args.outer_radius == 4096 else 'P2B-CLIMATE-AMENDED-4608.json'
    path = Path(__file__).resolve().parents[1] / 'docs' / filename
    path.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k: result[k] for k in ['seedCount','pairs','temperatureViolations','rainfallViolations','maxTemperatureDifferenceCentiC','maxRainfallDifferenceMm','passed','firstViolation']},indent=2))
    raise SystemExit(0 if result['passed'] else 1)


if __name__ == '__main__':
    main()
