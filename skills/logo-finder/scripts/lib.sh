#!/usr/bin/env bash
# Shared helpers for logo-finder scripts.

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required. Install with: brew install jq" >&2
    exit 1
  fi
}

require_jq

slug_from_name() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//'
}

url_extension() {
  local url="$1"
  local base="${url%%\?*}"
  local ext="${base##*.}"
  echo "$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
}

default_brand_output() {
  local slug="$1"
  local url="$2"
  local ext
  ext="$(url_extension "$url")"
  case "$ext" in
    svg) echo "${slug}.svg" ;;
    png) echo "${slug}.png" ;;
    jpg | jpeg) echo "${slug}.jpg" ;;
    webp) echo "${slug}.webp" ;;
    *) echo "${slug}.svg" ;;
  esac
}

is_raster_url() {
  local ext
  ext="$(url_extension "$1")"
  case "$ext" in
    png | jpg | jpeg | gif | webp | avif) return 0 ;;
    *) return 1 ;;
  esac
}

require_svg_output_path() {
  local path="$1"
  local lower
  lower="$(echo "$path" | tr '[:upper:]' '[:lower:]')"
  if [[ "$lower" != *.svg ]]; then
    echo "Output must be a .svg path: $path" >&2
    return 1
  fi
}

require_svg_url() {
  local url="$1"
  local base="${url%%\?*}"
  local lower
  lower="$(echo "$base" | tr '[:upper:]' '[:lower:]')"
  if [[ "$lower" =~ \.(png|jpe?g|gif|webp|avif)$ ]]; then
    if [[ "${LOGO_FINDER_ALLOW_RASTER:-}" == 1 ]]; then
      echo "warn: raster URL allowed by LOGO_FINDER_ALLOW_RASTER=1: $url" >&2
      return 0
    fi
    echo "Reject raster URL (SVG required): $url" >&2
    return 1
  fi
}

assert_svg_file() {
  local file="$1"
  local sample mime
  [[ -f "$file" ]] || return 1
  sample="$(head -c 800 "$file" | tr -d '\0')"
  if [[ "$sample" == *"<svg"* ]]; then
    return 0
  fi
  mime="$(file -b --mime-type "$file" 2>/dev/null || true)"
  if [[ "$mime" == "image/svg+xml" ]]; then
    return 0
  fi
  echo "Download is not SVG markup: $file" >&2
  rm -f "$file"
  return 1
}

normalize_svg() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  assert_svg_file "$file" || return 1
  if ! grep -q 'xmlns=' "$file"; then
    perl -pi -e 's/<svg /<svg xmlns="http:\/\/www.w3.org\/2000\/svg" /' "$file"
  fi
}

save_brand_asset() {
  local url="$1"
  local output="$2"
  mkdir -p "$(dirname "$output")"
  if is_raster_url "$url"; then
    curl -fsSL "$url" -o "$output"
    local mime
    mime="$(file -b --mime-type "$output" 2>/dev/null || true)"
    case "$mime" in
      image/png | image/jpeg | image/webp | image/gif) return 0 ;;
      *)
        echo "Expected raster image, got: $mime ($output)" >&2
        rm -f "$output"
        return 1
        ;;
    esac
  fi
  require_svg_url "$url"
  curl -fsSL "$url" -o "$output"
  normalize_svg "$output"
}
