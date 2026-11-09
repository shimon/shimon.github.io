#!/usr/bin/env python3
"""Reproduce only reviewed wagon display images from private, hash-checked originals.

Download URLs are read from an uncommitted private source-map JSON. The public
manifest records file hashes and pixel rectangles, never private album tokens.
Coordinates refer to the EXIF-transposed original, before resizing. Every plate
rectangle receives an opaque fill; blur is deliberately not used.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
import urllib.request
from urllib.parse import urlsplit
from PIL import Image, ImageDraw, ImageOps, __version__
from atomic_output import atomic_write_bytes

MAX_BYTES = 80 * 1024 * 1024
Image.MAX_IMAGE_PIXELS = 80_000_000

def digest(data):
    return hashlib.sha256(data).hexdigest()

def safe_name(value):
    if not value or Path(value).name != value or value in {'.', '..'}:
        raise ValueError('Manifest filenames must be simple basenames')
    return value

class GoogleOnlyRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        check_url(newurl)
        return super().redirect_request(req, fp, code, msg, headers, newurl)

def check_url(url):
    p = urlsplit(url)
    if p.scheme != 'https' or p.username or p.password:
        raise ValueError('Source must be an HTTPS Google media URL without credentials')
    if not any(p.hostname == host or p.hostname.endswith('.' + host)
               for host in ('googleusercontent.com', 'google.com')):
        raise ValueError('Unrecognized source host')

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--manifest', type=Path, required=True)
    ap.add_argument('--originals', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    ap.add_argument('--sources', type=Path, help='Private JSON mapping source basename to exact verified download URL')
    ap.add_argument('--download', action='store_true')
    args = ap.parse_args()
    config = json.loads(args.manifest.read_text())
    if __version__ != config['pillow_version']:
        raise ValueError(f"Use Pillow {config['pillow_version']} for reproducibility")
    originals = args.originals.resolve()
    output = args.output.resolve()
    repo = Path(__file__).resolve().parents[2]
    if originals == repo or repo in originals.parents:
        raise ValueError('Originals must remain outside the public repository')
    if originals == output or originals in output.parents or output in originals.parents:
        raise ValueError('Originals and output must be separate directories')
    if not config['photos']:
        raise ValueError('No reviewed photographs in manifest')
    sources = json.loads(args.sources.read_text()) if args.sources else {}
    if args.download and not sources:
        raise ValueError('--download requires --sources')
    originals.mkdir(parents=True, exist_ok=True)
    output.mkdir(parents=True, exist_ok=True)
    report = {'pillow_version': __version__, 'manifest_sha256': digest(args.manifest.read_bytes()), 'photos': []}
    names = set()
    for entry in config['photos']:
        source = originals / safe_name(entry['source'])
        name = safe_name(entry['output'])
        if name in names or not name.endswith('.webp'):
            raise ValueError('Output names must be unique .webp files')
        names.add(name)
        if args.download and not source.exists():
            url = sources[entry['source']]
            check_url(url)
            opener = urllib.request.build_opener(GoogleOnlyRedirect())
            with opener.open(url, timeout=90) as response:
                data = response.read(MAX_BYTES + 1)
            if len(data) > MAX_BYTES or digest(data) != entry['source_sha256']:
                raise ValueError(f'Source download size/hash mismatch: {source.name}')
            source.write_bytes(data)
        data = source.read_bytes()
        if digest(data) != entry['source_sha256']:
            raise ValueError(f'Source hash mismatch: {source.name}')
        with Image.open(io.BytesIO(data)) as original:
            if getattr(original, 'n_frames', 1) != 1:
                raise ValueError('Animated images and videos are not supported')
            oriented = ImageOps.exif_transpose(original).convert('RGB')
        if list(oriented.size) != entry['oriented_size']:
            raise ValueError(f'Unexpected oriented dimensions: {source.name}')
        rectangles = entry['plate_rectangles']
        polygons = entry.get('plate_polygons', [])
        status = entry['plate_review']
        if status not in ('no_plate_visible', 'redacted') or (status == 'redacted') != bool(rectangles or polygons):
            raise ValueError('Every photo requires an explicit plate review')
        # Fresh RGB image intentionally drops all original metadata before encoding.
        clean = Image.new('RGB', oriented.size)
        clean.paste(oriented)
        draw = ImageDraw.Draw(clean)
        for rect in rectangles:
            if len(rect) != 4 or any(type(v) is not int for v in rect):
                raise ValueError('Rectangles require four integer pixel coordinates')
            x0, y0, x1, y1 = rect
            if not (0 <= x0 < x1 <= clean.width and 0 <= y0 < y1 <= clean.height):
                raise ValueError('Invalid plate rectangle')
            draw.rectangle((x0, y0, x1 - 1, y1 - 1), fill=tuple(config['mask_rgb']))
        for polygon in polygons:
            points = polygon['points']
            color = polygon['fill_rgb']
            if len(points) < 3 or any(len(p) != 2 or any(type(v) is not int for v in p) for p in points):
                raise ValueError('Plate polygons require at least three integer coordinate pairs')
            if any(not (0 <= x < clean.width and 0 <= y < clean.height) for x, y in points):
                raise ValueError('Plate polygon lies outside the image')
            if len(color) != 3 or any(type(v) is not int or not 0 <= v <= 255 for v in color):
                raise ValueError('Plate fill must be three RGB bytes')
            draw.polygon([tuple(p) for p in points], fill=tuple(color))
        if 'crop' in entry:
            x0, y0, x1, y1 = entry['crop']
            if not (0 <= x0 < x1 <= clean.width and 0 <= y0 < y1 <= clean.height):
                raise ValueError('Invalid crop rectangle')
            clean = clean.crop((x0, y0, x1, y1))
        clean.thumbnail(tuple(config['max_size']), Image.Resampling.LANCZOS)
        target = output / name
        encoded = io.BytesIO()
        clean.save(encoded, 'WEBP', quality=config['quality'], method=6, exact=True)
        atomic_write_bytes(target, encoded.getvalue())
        with Image.open(target) as result:
            if result.getexif() or any(k in result.info for k in ('exif', 'xmp', 'icc_profile')):
                raise ValueError('Unexpected metadata in processed output')
        report['photos'].append({'output': name, 'sha256': digest(target.read_bytes()), 'size': list(clean.size), 'plate_review': status})
    atomic_write_bytes(output / 'processing-report.json', (json.dumps(report, indent=2) + '\n').encode())
    print(f"Processed {len(report['photos'])} reviewed photographs")

if __name__ == '__main__':
    main()
