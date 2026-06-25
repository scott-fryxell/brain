#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "$0")/.." && pwd)"
logo_sh="$skill_dir/scripts/logo.sh"

usage() {
  echo "Usage: batch.sh <names.txt> <output-dir> [--dark]"
  exit 1
}

[[ $# -ge 2 ]] || usage

list_file="$1"
out_dir="$2"
shift 2
extra_flags=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dark)
      extra_flags+=(--dark)
      shift
      ;;
    *)
      echo "Unknown flag: $1" >&2
      usage
      ;;
  esac
done

[[ -f "$list_file" ]] || { echo "Missing list file: $list_file" >&2; exit 1; }
mkdir -p "$out_dir"

failed=0
while IFS= read -r line || [[ -n "$line" ]]; do
  name="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [[ -n "$name" ]] || continue
  [[ "$name" =~ ^# ]] && continue

  slug="$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//')"
  out_file="$out_dir/${slug}.svg"

  if ((${#extra_flags[@]})); then
    fetch_ok=0
    bash "$logo_sh" "$name" "${extra_flags[@]}" "$out_file" && fetch_ok=1
  else
    fetch_ok=0
    bash "$logo_sh" "$name" "$out_file" && fetch_ok=1
  fi
  if [[ "$fetch_ok" == 1 ]]; then
    echo "ok: $name -> $out_file"
  else
    echo "miss: $name" >&2
    failed=$((failed + 1))
  fi
  sleep 1
done <"$list_file"

if [[ "$failed" -gt 0 ]]; then
  echo "$failed logo(s) failed" >&2
  exit 1
fi
