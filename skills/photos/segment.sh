#!/bin/bash
# segment.sh - full photo analysis: EXIF metadata + vision description

IMAGE_PATH="$1"
PROMPT="$2"
SKILL_DIR="$(dirname "$0")"

if [ -z "$IMAGE_PATH" ]; then
  echo "Usage: segment.sh <image_path> [vision_prompt]"
  exit 1
fi

echo "=== EXIF / Metadata ==="
bash "$SKILL_DIR/exif.sh" "$IMAGE_PATH"

echo ""
echo "=== Vision Analysis ==="
if [ -n "$PROMPT" ]; then
  bash "$SKILL_DIR/analyze.sh" "$IMAGE_PATH" "$PROMPT"
else
  bash "$SKILL_DIR/analyze.sh" "$IMAGE_PATH"
fi
