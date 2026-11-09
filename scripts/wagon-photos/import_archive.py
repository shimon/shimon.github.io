#!/usr/bin/env python3
"""Verify the privately downloaded Google Photos ZIP and extract selected originals.

Google Photos currently requires its Download all UI for this album. This is
an archive-import step, not an automated album downloader. No URLs are guessed.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
EXPECTED_ARCHIVE_SHA256='4ea521c4176125bc2e138595e38d2b9b8e42be875ea02b8cc91646a3e4c379ee'
ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('--archive',type=Path,required=True)
ap.add_argument('--manifest',type=Path,required=True)
ap.add_argument('--originals',type=Path,required=True)
args=ap.parse_args()
repo=Path(__file__).resolve().parents[2]
for p in (args.archive.resolve(),args.originals.resolve()):
    if p==repo or repo in p.parents:
        raise ValueError('Archive and originals must remain outside the public repository')
h=hashlib.sha256()
with args.archive.open('rb') as f:
    for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
if h.hexdigest()!=EXPECTED_ARCHIVE_SHA256:raise ValueError('Archive hash differs; review a new archive before accepting it')
manifest=json.loads(args.manifest.read_text())
args.originals.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(args.archive) as z:
    for entry in manifest['photos']:
        name=entry['source']
        if Path(name).name!=name:raise ValueError('Unsafe source basename')
        matches=[i for i in z.infolist() if Path(i.filename).name==name and not i.is_dir()]
        if len(matches)!=1 or matches[0].file_size>80*1024*1024:raise ValueError('Missing, duplicate, or oversized photo')
        data=z.read(matches[0])
        if hashlib.sha256(data).hexdigest()!=entry['source_sha256']:raise ValueError('Photo hash mismatch')
        (args.originals/name).write_bytes(data)
print(f"Imported {len(manifest['photos'])} selected photographs; no videos extracted")
