"""Refresh checksums after preparation/validation; no network or runtime access."""
from pathlib import Path
import hashlib,json
OUT=Path(__file__).resolve().parent
files={str(p.relative_to(OUT)).replace('\\','/'):hashlib.sha256(p.read_bytes()).hexdigest()
       for p in sorted(OUT.rglob('*')) if p.is_file() and '__pycache__' not in p.parts
       and p.name!='package-hashes.json'}
(OUT/'package-hashes.json').write_text(json.dumps({'algorithm':'SHA-256','files':files},indent=2)+'\n',encoding='utf-8')
print(f'Hashed {len(files)} local package files; checksum index excludes itself.')
