---
name: photos
description: Analyze and segment photographs using local vision AI (gemma4 via ollama) combined with EXIF metadata. Use when the user wants to describe, organize, or segment photos, extract location/date/camera info, or batch-process a photo library.
---

# Photo Analysis

Analyze photos with the local vision model (gemma4:e4b via ollama) plus EXIF metadata.

## Setup

Install exiftool for rich EXIF extraction (optional - falls back to macOS `mdls`):

```bash
brew install exiftool
```

## Analyze a single photo (vision + EXIF)

```bash
bash ${CLAUDE_SKILL_DIR}/segment.sh /path/to/photo.jpg
```

Returns:
- EXIF: date taken, GPS coords, camera make/model, focal length, aperture, ISO
- Vision: scene type, subjects, objects, lighting, mood

## Vision only

```bash
bash ${CLAUDE_SKILL_DIR}/analyze.sh /path/to/photo.jpg
```

## EXIF only

```bash
bash ${CLAUDE_SKILL_DIR}/exif.sh /path/to/photo.jpg
```

## Custom vision prompt

```bash
bash ${CLAUDE_SKILL_DIR}/analyze.sh /path/to/photo.jpg "What architectural details are visible?"
```

## Batch: analyze a folder

```bash
for img in /path/to/photos/*.{jpg,jpeg,JPG,JPEG,png,webp}; do
  [ -f "$img" ] || continue
  echo "### $(basename "$img")"
  bash ${CLAUDE_SKILL_DIR}/segment.sh "$img"
  echo ""
done
```

## Common tasks

- "Describe this photo" -- full segment.sh analysis
- "When and where was this taken?" -- EXIF DateTimeOriginal + GPS
- "What camera was used?" -- EXIF Make/Model
- "Organize these photos by scene type" -- batch analyze, group by vision output
- "Find all outdoor/nature photos" -- batch analyze, filter on descriptions
- "What settings were used?" -- EXIF aperture, shutter, ISO, focal length

## Model override

Set `PHOTOS_MODEL` to use a different ollama model:

```bash
PHOTOS_MODEL=gemma4:e2b bash ${CLAUDE_SKILL_DIR}/analyze.sh photo.jpg
```
