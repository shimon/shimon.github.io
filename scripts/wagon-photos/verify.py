#!/usr/bin/env python3
"""Verify the exact reviewed processed-photo set, hashes, and metadata boundary."""
import argparse,hashlib,json
from pathlib import Path
from PIL import Image
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--site-dir', type=Path, help='Also verify the actual built site, e.g. _site')
args=parser.parse_args()
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

thumb_dir=root/'tsx-wagon/thumbnails'
thumb_report=json.loads((thumb_dir/'processing-report.json').read_text())
assert {p.name for p in thumb_dir.iterdir() if p.is_file()}==expected|{'processing-report.json'}
assert {row['output'] for row in thumb_report['photos']}==expected
sources={row['output']:row['sha256'] for row in report['photos']}
for row in thumb_report['photos']:
 p=thumb_dir/row['output']
 assert row['source_sha256']==sources[row['output']]
 assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256']
 with Image.open(p) as image:
  assert image.format=='WEBP' and image.n_frames==1 and max(image.size)<=800
  assert list(image.size)==row['size'] and not image.getexif()
  assert not any(k in image.info for k in ('exif','xmp','icc_profile'))
print(f'PASS: {len(expected)} thumbnails match verified redacted sources and contain no metadata')

if args.site_dir:
 for folder, asset_report in [('photos', report), ('thumbnails', thumb_report)]:
  for row in asset_report['photos']:
   built=args.site_dir/'tsx-wagon'/folder/row['output']
   assert built.is_file(), f'Missing built image: {built}'
   assert hashlib.sha256(built.read_bytes()).hexdigest()==row['sha256'], f'Empty, incomplete, or stale built image: {built}'
 print(f'PASS: all {len(expected)*2} built image files match their verified sources in {args.site_dir}')
