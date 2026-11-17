"""Read-only real atlas isolation checks; not a Luau analyzer or texture delivery test."""
from pathlib import Path
import hashlib, json, xml.etree.ElementTree as ET
root = Path(__file__).resolve().parents[1]
checks = []
def check(name, value):
    assert value, name
    checks.append(name)
uri = 'rbxassetid://86222383311104'
expected = 'e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb'
check('Approved atlas unchanged', hashlib.sha256((root/'assets/r32-proof-v3/power-state-map-proof-v3.png').read_bytes()).hexdigest() == expected)
for variant in ['PowerState', 'PowerStateTests']:
    place = ET.parse(root/'.build'/f'{variant}.rbxlx')
    names = [n.text for n in place.findall('.//Item/Properties/string[@name="Name"]')]
    sources = '\n'.join(n.text or '' for n in place.findall('.//Properties/*[@name="Source"]'))
    for name in ['RealAtlas', 'R34.spec', 'HybridProof']:
        check(f'{variant} isolates {name}', (name in names) == (variant == 'PowerStateTests'))
    check(f'{variant} approved URI isolation', (uri in sources) == (variant == 'PowerStateTests'))
adapter = (root/'tests/integration/RealAtlas.luau').read_text()
check('Approved Test guard', 'game.GameId == Atlas.TEST_UNIVERSE' in adapter and '10776833313' in adapter)
check('ContentProvider off main path', 'task.spawn' in adapter and 'PreloadAsync(images' in adapter)
check('Actual label readiness', 'image.IsLoaded' in adapter)
check('Bounded six sprites', '#images == 6' in adapter)
check('No source texture ID', all(uri not in p.read_text() for p in (root/'src').rglob('*.luau')))
result = {'passed': len(checks), 'checks': checks, 'scope': 'Local isolation only; engine evidence separate'}
(root/'.build/R34-local-validation.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result))
