#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib.sh
source "$skill_dir/scripts/lib.sh"

usage() {
  echo "Usage: logo.sh <query> [output.svg]"
  echo "       logo.sh <query> --search"
  echo "       logo.sh <query> --dark [output.svg]"
  exit 1
}

[[ $# -ge 1 ]] || usage

query="$1"
shift || true
theme="light"
mode="write"
output=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --search)
      mode="search"
      shift
      ;;
    --dark)
      theme="dark"
      shift
      ;;
    --light)
      theme="light"
      shift
      ;;
    -*)
      echo "Unknown flag: $1" >&2
      usage
      ;;
    *)
      output="$1"
      shift
      ;;
  esac
done

results="$(curl -fsSL -G "https://api.svgl.app" --data-urlencode "search=$query")"

entry="$(echo "$results" | jq -c --arg q "$query" '
  [.[] | select((.subTitle // null) == null)] as $plain
  | ($plain | map(select((.title | ascii_downcase) == ($q | ascii_downcase)))[0])
  // ($plain | map(select((.title | ascii_downcase | contains($q | ascii_downcase))) )[0])
  // (.[0])
  // empty
')"

if [[ -z "$entry" ]]; then
  echo "No SVGL match for: $query" >&2
  exit 1
fi

if [[ "$mode" == "search" ]]; then
  echo "$entry" | jq .
  exit 0
fi

route="$(echo "$entry" | jq -r --arg theme "$theme" '
  .route
  | if type == "object" then
      if $theme == "dark" then .dark else .light end
    else .
    end
')"

filename="${route##*/}"
svg_url="https://api.svgl.app/svg/${filename}"

if [[ -z "$output" ]]; then
  slug="$(basename "$filename" .svg)"
  output="${slug}.svg"
fi

require_svg_output_path "$output"
require_svg_url "$svg_url"
mkdir -p "$(dirname "$output")"
curl -fsSL "$svg_url" -o "$output"
normalize_svg "$output"

title="$(echo "$entry" | jq -r '.title')"
brand_url="$(echo "$entry" | jq -r '.brandUrl // empty')"
echo "saved: $output"
echo "title: $title"
echo "route: $route"
[[ -n "$brand_url" ]] && echo "brandUrl: $brand_url"
