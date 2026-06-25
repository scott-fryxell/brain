#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib.sh
source "$skill_dir/scripts/lib.sh"

manifest="$skill_dir/assets/commons-logos.tsv"

usage() {
  echo "Usage: commons.sh <slug|product name> [output path]"
  echo "       commons.sh --url <upload-url> [output path]"
  echo "       commons.sh --list"
  echo "       commons.sh --search <query>"
  exit 1
}

[[ $# -ge 1 ]] || usage

list_manifest() {
  grep -v '^#' "$manifest" | grep -v '^[[:space:]]*$' || true
}

lookup_row() {
  local key="$1"
  local slug
  slug="$(slug_from_name "$key")"
  while IFS=$'\t' read -r row_slug url wiki name; do
    [[ -n "$row_slug" ]] || continue
    if [[ "$row_slug" == "$slug" || "$name" == "$key" ]]; then
      printf '%s\t%s\t%s\t%s\n' "$row_slug" "$url" "$wiki" "$name"
      return 0
    fi
  done < <(list_manifest)
  return 1
}

case "$1" in
  --list)
    list_manifest | while IFS=$'\t' read -r slug url wiki name; do
      echo "$slug ($name)"
      echo "  $url"
      echo "  $wiki"
    done
    exit 0
    ;;
  --search)
    [[ $# -ge 2 ]] || usage
    query="$(echo "$2" | tr '[:upper:]' '[:lower:]')"
    found=0
    while IFS=$'\t' read -r slug url wiki name; do
      [[ -n "$slug" ]] || continue
      hay="${slug} $(echo "$name" | tr '[:upper:]' '[:lower:]')"
      if [[ "$hay" == *"$query"* ]]; then
        echo "$slug	$url	$wiki	$name"
        found=1
      fi
    done < <(list_manifest)
    [[ "$found" -eq 1 ]] || { echo "No commons manifest match for: $2" >&2; exit 1; }
    exit 0
    ;;
  --url)
    [[ $# -ge 2 ]] || usage
    upload_url="$2"
    shift 2
    output="${1:-}"
    if [[ -z "$output" ]]; then
      filename="${upload_url##*/}"
      output="${filename}"
    fi
    save_brand_asset "$upload_url" "$output"
    echo "saved: $output"
    echo "source: $upload_url"
    exit 0
    ;;
esac

key="$1"
shift || true
output="${1:-}"

row="$(lookup_row "$key" || true)"
if [[ -z "$row" ]]; then
  echo "No commons manifest entry for: $key (add a row to assets/commons-logos.tsv)" >&2
  exit 1
fi

IFS=$'\t' read -r slug upload_url wiki name <<<"$row"

if [[ -z "$output" ]]; then
  output="$(default_brand_output "$slug" "$upload_url")"
fi

save_brand_asset "$upload_url" "$output"

echo "saved: $output"
echo "title: $name"
echo "source: $upload_url"
echo "wiki: $wiki"
