#!/usr/bin/env python3
"""Verify the exact reviewed processed-photo set, hashes, and metadata boundary."""
import hashlib,json
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[2]
manifest=json.loads((Path(__file__).parent/'manifest.json').read_text())
photo_dir=root/'tsx-wagon/photos'
report=json.loads((photo_dir/'processing-report.json').read_text())
assert report['manifest_sha256']==hashlib.sha256((Path(__file__).parent/'manifest.json').read_bytes()).hexdigest(), 'Manifest changed after processing'
expected={x['output'] for x in manifest['photos']}
actual={p.name for p in photo_dir.iterdir() if p.is_file()}
assert actual==expected|{'processing-report.json'}, 'Unexpected photo asset or missing output'
assert {x['output'] for x in report['photos']}==expected
for row in report['photos']:
 p=photo_dir/row['output']
 assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256'],f'Output changed: {p.name}'
 with Image.open(p) as image:
  assert image.format=='WEBP' and image.n_frames==1
  assert not image.getexif()
  assert not any(k in image.info for k in ('exif','xmp','icc_profile'))
  assert list(image.size)==row['size']
for p in (root/'tsx-wagon').rglob('*'):
 assert p.suffix.lower() not in ('.jpg','.jpeg','.mp4','.mov','.zip'),f'Original media in deployable folder: {p.name}'
print(f'PASS: exact set of {len(expected)} processed images; all hashes and metadata checks match')
