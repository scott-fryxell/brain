#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "$0")/.." && pwd)"
logo_sh="$skill_dir/scripts/logo.sh"
commons_sh="$skill_dir/scripts/commons.sh"
# shellcheck source=lib.sh
source "$skill_dir/scripts/lib.sh"

usage() {
  echo "Usage: missing-from-about.sh [About.vue] [output-dir]"
  echo "Lists tools missing logos in About.vue (logo: null or integrations icon fallback), tries SVGL then commons."
  exit 1
}

[[ $# -le 2 ]] || usage

about_file="${1:-work/web/src/views/About.vue}"
out_dir="${2:-work/web/public/brands}"

[[ -f "$about_file" ]] || { echo "Missing file: $about_file" >&2; exit 1; }
mkdir -p "$out_dir"

missing_names=()
while IFS= read -r name; do
  [[ -n "$name" ]] && missing_names+=("$name")
done < <(
  perl -0777 -ne '
    my @from_null;
    my $n;
    for (split /\n/, $_) {
      if (/name: '\''([^'\'']+)'\''/) { $n = $1 }
      if (/logo: null/ && $n) { push @from_null, $n; $n = "" }
    }
    if (@from_null) {
      print join("\n", @from_null), "\n";
      exit;
    }
    if (/itemprop="integrations".*?<\/section>/s) {
      my $block = $&;
      while ($block =~ /<li>\s*<icon\b[^>]*>\s*<p>\s*<strong>([^<]+)<\/strong>/sg) {
        print "$1\n";
      }
    }
  ' "$about_file"
)

if [[ ${#missing_names[@]} -eq 0 ]]; then
  echo "No logo: null entries in $about_file"
  exit 0
fi

echo "Missing logos (${#missing_names[@]}): ${missing_names[*]}"
echo

failed=0
for name in "${missing_names[@]}"; do
  slug="$(slug_from_name "$name")"
  out_file="$out_dir/${slug}.svg"

  if [[ -f "$out_file" ]]; then
    echo "skip (exists): $name -> $out_file"
    continue
  fi

  if bash "$logo_sh" "$name" "$out_file" 2>/dev/null; then
    normalize_svg "$out_file"
    echo "ok (svgl): $name -> $out_file"
    continue
  fi

  if bash "$commons_sh" "$name" "$out_file" 2>/dev/null; then
    echo "ok (commons): $name -> $out_file"
    continue
  fi

  echo "miss: $name (try: logo.sh '$name' --search; commons.sh --search '$(echo "$name" | tr '[:upper:]' '[:lower:]')')" >&2
  failed=$((failed + 1))
  sleep 1
done

if [[ "$failed" -gt 0 ]]; then
  echo "$failed still missing - add SVGL alias or a commons-logos.tsv row" >&2
  exit 1
fi
