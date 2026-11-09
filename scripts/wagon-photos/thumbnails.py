#!/usr/bin/env python3
"""Build gallery thumbnails only from verified, already-redacted display photos."""
import hashlib
import io
import json
from pathlib import Path
from PIL import Image, __version__
from atomic_output import atomic_write_bytes

root = Path(__file__).resolve().parents[2]
photos = root / 'tsx-wagon/photos'
output = root / 'tsx-wagon/thumbnails'
manifest = json.loads((Path(__file__).parent / 'manifest.json').read_text())
assert __version__ == manifest['pillow_version'], 'Use the pinned Pillow version'
report = json.loads((photos / 'processing-report.json').read_text())
assert report['manifest_sha256'] == hashlib.sha256((Path(__file__).parent / 'manifest.json').read_bytes()).hexdigest()
output.mkdir(exist_ok=True)
thumbs = []
for row in report['photos']:
    source = photos / row['output']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == row['sha256']
    with Image.open(source) as image:
        clean = Image.new('RGB', image.size)
        clean.paste(image)
    clean.thumbnail((800, 800), Image.Resampling.LANCZOS)
    target = output / row['output']
    encoded = io.BytesIO()
    clean.save(encoded, 'WEBP', quality=82, method=6, exact=True)
    atomic_write_bytes(target, encoded.getvalue())
    thumbs.append({'output': row['output'], 'source_sha256': row['sha256'],
                   'sha256': hashlib.sha256(target.read_bytes()).hexdigest(), 'size': list(clean.size)})
atomic_write_bytes(output / 'processing-report.json', (json.dumps({'pillow_version': __version__, 'photos': thumbs}, indent=2) + '\n').encode())
print(f'Built {len(thumbs)} redacted thumbnails: {sum((output / x["output"]).stat().st_size for x in thumbs):,} bytes')
