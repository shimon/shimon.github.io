# Reproducing wagon photographs

Only processed WebP images belong in `tsx-wagon/photos/`. Originals, album share links, download URLs, ZIPs, and navigation videos must stay outside this public repository.

## Acquisition limitation

The album was retrieved through Google Photos **More options → Download all**. The browser returned a ZIP file but did not expose a reusable download URL. A standalone public-UI downloader is provided in `download_album.mjs`; its syntax is checked, but it has **not been executed end-to-end** in this environment. The equivalent browser UI download was verified. Google can change accessible labels or require a login, so the script fails rather than bypassing a challenge. The verified fallback is to repeat that UI step with the private album link and save the ZIP outside the repository, then run the commands below. A new ZIP may have different packaging/checksums; review and intentionally update its expected hash rather than disabling validation. The existing private archive reproduces the exact current source set.

`process.py` also supports `--download --sources /private/sources.json` for individually verified, exact Google-hosted image download URLs mapped by source filename. That optional URL route was not used or tested for this album; do not invent URLs or commit the source map.

## Optional scripted download (not end-to-end tested)

In this folder, install the pinned Playwright dependency with `npm install`, then install its Chromium with `npx playwright install chromium`. Keep your album link and destination in a JSON file **outside the repository**:

```json
{"album_url":"<your private Google Photos share URL>","archive":"/private/album.zip"}
```

Run `node download_album.mjs < /private/wagon-download.json`. This performs the public UI's More options → Download all sequence, saves outside the repository, and prints the archive checksum. No account credentials or private API calls are used. `headless: false` in the private JSON enables a visible browser. Never put the real share URL in this README or committed files.

## Deterministic transformation

Use Python 3 and the pinned Pillow version in `requirements.txt` (Pillow 13.0.0). For byte-identical output, retain the same Pillow/libwebp build. The manifest records the source SHA-256, EXIF-transposed dimensions, explicit redaction rectangles/polygons, and a reviewed no-plate status when applicable.

From the repository root:

```sh
python scripts/wagon-photos/import_archive.py \
  --archive /private/album.zip \
  --manifest scripts/wagon-photos/manifest.json \
  --originals /private/wagon-originals
python scripts/wagon-photos/process.py \
  --manifest scripts/wagon-photos/manifest.json \
  --originals /private/wagon-originals \
  --output tsx-wagon/photos
```

The importer verifies the entire expected archive, extracts only selected photographs by basename, and verifies every source hash. It does not extract videos or follow archive paths. The processor refuses originals inside the public repository. It verifies source hashes and dimensions, applies EXIF orientation, draws **opaque** plate masks in original pixel coordinates (including perspective polygons fitted inside plate faces), resizes with Lanczos to at most 2000 × 2000, and writes fresh RGB WebP files with no EXIF, XMP, ICC, GPS, or embedded motion-video data. Exterior plate faces use individually reviewed light RGB fills, preserving the surrounding frame and bumper. Background-car plates are masked too. A windshield inspection sticker is additionally masked in the cockpit photo. No rust, dents, scuffs, or upholstery damage is removed.

`processing-report.json` lists each output hash and size. Run `python scripts/wagon-photos/verify.py` to verify the exact reviewed output set, hashes, and absence of source metadata. Run twice and compare the reports to check reproducibility in the same environment. Review every output visually before publication, including backgrounds and reflections; automated hash checks do not prove that the manifest found every plate. New or changed photographs require a new visual review and explicit manifest entry.

Both generators encode images completely in memory, write a hidden temporary file beside the destination, and atomically replace the final file. This keeps a running Jekyll watcher from copying an empty or partially written image. If an older generation left empty files in `_site`, rebuild or touch the verified source assets to force the watcher to copy them again.

## Gallery thumbnails

After processing photos, run `python scripts/wagon-photos/thumbnails.py` with the same pinned Pillow version. This verifies each processed source hash, resizes only already-redacted images to at most 800 × 800, and writes fresh metadata-free WebP thumbnails at quality 82 into `tsx-wagon/thumbnails/`. Its report records source/output hashes and dimensions. `verify.py` checks both sets. The gallery eagerly loads these small thumbnails; opening the viewer loads the corresponding full-size processed photo. No originals are used by the thumbnail generator.

After a Jekyll build, run `python scripts/wagon-photos/verify.py --site-dir _site` (or the actual build destination). This also verifies every served full-size photo and thumbnail against its expected hash, catching empty, partial, or stale copies even when all source assets are valid.

## Hero composition

The hero in `tsx-wagon/index.html` reuses the redacted `01-front-three-quarter.webp` through an inline SVG mask. Its upper photograph fades into a traced lower-body silhouette; A separate full-width SVG layer draws the decorative copper/blue road behind both the title and photograph. The photo layer is transparent below the silhouette, so the road continues without a panel boundary. The tracing uses the processed photograph's 2000 × 1506 coordinates and a fixed viewBox, so it scales identically on desktop and mobile. The foreground car uses a single unfiltered copy of the redacted photograph, clipped to the existing silhouette. Its reflections, paint texture, glass, color, and contrast are unchanged; no foreground smoothing or reflection reduction is applied. All layers reuse the same redacted photograph in the same coordinates without warping or moving the car; the autumn background has a separate 35% saturation reduction, 15% brightness reduction, and 3-pixel Gaussian blur. A shadow and subtle blue-gray rim glow follow the full traced silhouette behind the car layer, leaving the original vehicle geometry and color intact. No AI generation or unredacted browser assets are involved. The gallery retains the complete, unstyled photograph. If the hero photograph or its crop changes, retrace the mask against the new processed image.

## Sharing preview

`tsx-wagon/social-preview.png` is a metadata-free 1200 × 630 center crop made only from the already-redacted front three-quarter photo. Regenerate with ImageMagick:

```sh
magick tsx-wagon/photos/01-front-three-quarter.webp -resize 1200x -gravity center -crop 1200x630+0+0 +repage -strip /tmp/wagon-social-preview.png
mv /tmp/wagon-social-preview.png tsx-wagon/social-preview.png
```

The page's Open Graph and Twitter card metadata use its public URL on `https://rura.org/tsx-wagon/`. `favicon.svg` is a black wagon outline on a white background.

## Related brochure thumbnail

`tsx-wagon/related/tsx-wagon-brochure.webp` is an Acura promotional photograph from the third image in [u/vulqcii’s brochure post](https://www.reddit.com/r/AcuraTSX/comments/1xc7xa8/found_2nd_gen_brochure_pictures/). It is separate from the sale-car gallery and credited beside the thumbnail. Visually reviewed: no license plates are present. Source: `https://preview.redd.it/found-2nd-gen-brochure-pictures-v0-rrthflp1vxwh1.jpeg?width=1080&crop=smart&auto=webp&s=8af55837f960e2dc6f83df0dbfb4ff04d86036c1`. Crop the 1080 × 834 source to `825x658+205+49`, resize to 640 pixels wide, strip metadata, and encode WebP at quality 84 using ImageMagick. Keep the downloaded source outside the repository.

## Publication boundary

Deploy only the page assets and processed photographs. No original JPG, MP4, ZIP, private URL map, or private archive should appear in Git history. The original album's videos are excluded because no frame-by-frame redaction has been completed. Mileage and current exhaust/sunroof disclosures have been updated from the owner and odometer photo. Asking price and buyer contact details still require confirmation.
