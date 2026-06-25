#!/bin/bash
# analyze.sh - describe a photo using the local vision model

IMAGE_PATH="$1"
PROMPT="${2:-Describe this photograph. Identify: scene type (portrait/landscape/street/nature/indoor/architecture/etc), main subjects, notable objects, lighting, mood, and any visible text. Be specific and concise.}"
MODEL="${PHOTOS_MODEL:-gemma4:e4b}"

if [ -z "$IMAGE_PATH" ]; then
  echo "Usage: analyze.sh <image_path> [prompt]"
  exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
  echo "Error: file not found: $IMAGE_PATH"
  exit 1
fi

IMAGE_B64=$(base64 < "$IMAGE_PATH" | tr -d '\n')

curl -s http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": $(python3 -c "import json, sys; print(json.dumps(sys.argv[1]))" "$PROMPT"),
    \"images\": [\"$IMAGE_B64\"],
    \"stream\": false
  }" | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(d.get('response', d.get('error', 'no response')))
except Exception as e:
  print('parse error:', e)
"
