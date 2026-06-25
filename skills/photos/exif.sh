#!/bin/bash
# exif.sh - extract EXIF/metadata from a photo

IMAGE_PATH="$1"

if [ -z "$IMAGE_PATH" ]; then
  echo "Usage: exif.sh <image_path>"
  exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
  echo "Error: file not found: $IMAGE_PATH"
  exit 1
fi

if command -v exiftool &>/dev/null; then
  exiftool -json "$IMAGE_PATH" | python3 -c "
import sys, json
data = json.load(sys.stdin)[0]
keep = [
  'DateTimeOriginal', 'CreateDate', 'ModifyDate',
  'GPSLatitude', 'GPSLongitude', 'GPSAltitude', 'GPSLatitudeRef', 'GPSLongitudeRef',
  'Make', 'Model', 'LensModel',
  'FocalLength', 'FocalLengthIn35mmFormat',
  'ExposureTime', 'ShutterSpeedValue', 'FNumber', 'ApertureValue',
  'ISO', 'ExposureCompensation', 'Flash',
  'ImageWidth', 'ImageHeight', 'Orientation',
  'ColorSpace', 'Software', 'Artist', 'Copyright'
]
result = {k: data[k] for k in keep if k in data}
print(json.dumps(result, indent=2))
"
else
  # fallback: macOS Spotlight metadata
  mdls \
    -name kMDItemContentType \
    -name kMDItemPixelWidth \
    -name kMDItemPixelHeight \
    -name kMDItemContentCreationDate \
    -name kMDItemGPSLatitude \
    -name kMDItemGPSLongitude \
    -name kMDItemGPSAltitude \
    -name kMDItemAcquisitionModel \
    -name kMDItemAcquisitionMake \
    -name kMDItemExposureTimeSeconds \
    -name kMDItemFNumber \
    -name kMDItemFocalLength \
    -name kMDItemISOSpeed \
    -name kMDItemOrientation \
    "$IMAGE_PATH"
fi
