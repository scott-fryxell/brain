#!/usr/bin/env python3
import os
import re
import sys
import time
import urllib.request
import urllib.parse

BASE = os.path.expanduser(
    "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Anotht"
)


def find_raindrop_files():
    list_file = os.path.join(os.path.dirname(__file__), "raindrop-files.txt")
    with open(list_file, "r") as f:
        return [line.strip() for line in f if line.strip()]


def parse_raindrop(content):
    url = None
    title = None
    description = None
    tags = []
    extra = ""

    m = re.search(r"Source URL:: (.+)", content)
    if m:
        url = m.group(1).strip()

    headings = re.findall(r"^# (.+)$", content, re.MULTILINE)
    for h in headings:
        if h.strip() not in ("Metadata",):
            title = h.strip()
            break

    if title:
        pattern = (
            r"^# " + re.escape(title) + r"\s*\n+(.*?)(?=^## Highlights|\Z)"
        )
        m = re.search(pattern, content, re.MULTILINE | re.DOTALL)
        if m:
            desc_block = m.group(1).strip()
            desc_lines = []
            for line in desc_block.split("\n"):
                if re.match(r"^#[a-z]", line):
                    tags.append(line.strip())
                else:
                    desc_lines.append(line)
            desc = "\n".join(desc_lines).strip()
            if desc:
                description = desc
    elif url:
        body = re.split(r"Source URL:: .+\n", content, maxsplit=1)
        if len(body) > 1:
            remainder = body[1].strip()
            remainder = re.sub(r"^---\s*$", "", remainder, flags=re.MULTILINE).strip()
            desc_lines = []
            for line in remainder.split("\n"):
                if re.match(r"^#[a-z]", line):
                    tags.append(line.strip())
                else:
                    desc_lines.append(line)
            desc = "\n".join(desc_lines).strip()
            if desc:
                description = desc

    if not tags:
        tags = re.findall(r"(?:^|\s)(#[a-z]\w*)", content)

    highlights_match = re.search(
        r"^## Highlights\s*\n+(.*)", content, re.MULTILINE | re.DOTALL
    )
    if highlights_match:
        hl = highlights_match.group(1).strip()
        hl_lines = [l for l in hl.split("\n") if not re.match(r"^#[a-z]", l)]
        hl_clean = "\n".join(hl_lines).strip()
        if hl_clean:
            extra = hl_clean

    return url, title, description, list(set(tags)), extra


def fetch_metadata(url):
    og_image = None
    favicon = None
    try:
        req = urllib.request.Request(
            url,
            headers={
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
            },
        )
        with urllib.request.urlopen(req, timeout=8) as resp:
            html = resp.read(200_000).decode("utf-8", errors="ignore")

        parsed = urllib.parse.urlparse(url)
        base_url = f"{parsed.scheme}://{parsed.netloc}"

        m = re.search(
            r'<meta[^>]*property=["\']og:image["\'][^>]*content=["\']([^"\']+)',
            html, re.IGNORECASE,
        )
        if not m:
            m = re.search(
                r'<meta[^>]*content=["\']([^"\']+)["\'][^>]*property=["\']og:image',
                html, re.IGNORECASE,
            )
        if m:
            og_image = m.group(1)
            if og_image.startswith("/"):
                og_image = base_url + og_image

        m = re.search(
            r'<link[^>]*rel=["\'][^"\']*icon[^"\']*["\'][^>]*href=["\']([^"\']+)',
            html, re.IGNORECASE,
        )
        if not m:
            m = re.search(
                r'<link[^>]*href=["\']([^"\']+)["\'][^>]*rel=["\'][^"\']*icon',
                html, re.IGNORECASE,
            )
        if m:
            favicon = m.group(1)
            if favicon.startswith("/"):
                favicon = base_url + favicon
    except Exception:
        pass

    return og_image, favicon


def build_note(url, title, description, tags, og_image, favicon, host, extra):
    lines = []

    lines.append("```cardlink")
    lines.append(f"url: {url}")
    if title:
        safe_title = title.replace('"', '\\"')
        lines.append(f'title: "{safe_title}"')
    if description:
        safe_desc = description.replace("\n", " ").replace('"', '\\"')[:300]
        lines.append(f'description: "{safe_desc}"')
    lines.append(f"host: {host}")
    if favicon:
        lines.append(f"favicon: {favicon}")
    if og_image:
        lines.append(f"image: {og_image}")
    lines.append("```")

    if tags:
        lines.append("")
        lines.append(" ".join(tags))

    if extra:
        lines.append("")
        lines.append(extra)

    lines.append("")
    return "\n".join(lines)


def main():
    dry_run = "--dry-run" in sys.argv
    files = find_raindrop_files()
    print(f"Found {len(files)} raindrop notes", flush=True)
    if dry_run:
        print("DRY RUN — no files will be changed\n", flush=True)

    success = 0
    skipped = 0
    errors = 0

    for i, path in enumerate(files):
        rel = path.replace(BASE + "/", "")

        with open(path, "r", errors="ignore") as f:
            content = f.read()

        url, title, description, tags, extra = parse_raindrop(content)

        if not url:
            print(f"[{i+1}/{len(files)}] SKIP (no URL): {rel}", flush=True)
            skipped += 1
            continue

        host = urllib.parse.urlparse(url).netloc
        og_image, favicon = fetch_metadata(url)

        new_content = build_note(
            url, title, description, tags, og_image, favicon, host, extra
        )

        if not dry_run:
            with open(path, "w") as f:
                f.write(new_content)

        icon = "+" if og_image else "~"
        print(f"[{i+1}/{len(files)}] {icon} {rel}", flush=True)
        success += 1
        time.sleep(0.15)

    print(f"\nDone: {success} cleaned, {skipped} skipped, {errors} errors", flush=True)


if __name__ == "__main__":
    main()
