---
name: logo-finder
description: Find and install brand SVG logos via SVGL (https://svgl.app/) and Wikimedia Commons fallbacks into public/brands for social proof and integration rows. Use for logo-finder, company logos, svgl.app, integration logos, missing About.vue logos, or refreshing work/web/public/brands. Pair with copywriting for social-proof copy.
---

# Logo Finder (SVGL + Commons)

Download brand logos into `work/web/public/brands/`. **Prefer SVG** (`.svg`); use PNG only when Commons/Wikipedia has no vector (e.g. [Final Cut Pro](https://en.wikipedia.org/wiki/Final_Cut_Pro#/media/File:FinalCutProACS2026.png)). Vite serves the folder at `/brands/{slug}.svg` or `.png`. Commit assets with the repo.

**Primary:** [SVGL API](https://svgl.app/docs/api)  
**Fallback:** curated [Wikimedia Commons](https://commons.wikimedia.org/) rows in `assets/commons-logos.tsv` (see [references/commons.md](references/commons.md))

## How files are created

### SVGL

1. **Search** - `GET https://api.svgl.app?search={product name}`
2. **Download** - `GET https://api.svgl.app/svg/{filename}`
3. **Save** - `work/web/public/brands/{slug}.svg` where `slug` matches the tool name in `About.vue` (e.g. `premiere-pro`, `after-effects`).

### Commons (when SVGL misses)

1. Find SVG on Commons (or use a known file page, e.g. [DaVinci Resolve 17 logo](https://commons.wikimedia.org/wiki/File:DaVinci_Resolve_17_logo.svg)).
2. Add `slug`, `upload_url`, wiki link, and `product_name` to `assets/commons-logos.tsv`.
3. Run `commons.sh` or let `missing-from-about.sh` pick it up after SVGL fails.

## Scripts

Requires `curl` and `jq` (`brew install jq`).

```bash
# SVGL - one logo
bash skills/logo-finder/scripts/logo.sh Figma work/web/public/brands/figma.svg
bash skills/logo-finder/scripts/logo.sh "Premiere Pro" --search

# SVGL - batch list
bash skills/logo-finder/scripts/batch.sh skills/logo-finder/assets/realness-integrations.txt work/web/public/brands

# Commons - manifest or direct URL
bash skills/logo-finder/scripts/commons.sh "DaVinci Resolve" work/web/public/brands/davinci-resolve.svg
bash skills/logo-finder/scripts/commons.sh --list

# About.vue tools with logo: null - try SVGL then commons
bash skills/logo-finder/scripts/missing-from-about.sh work/web/src/views/About.vue work/web/public/brands
```

Not fetched at runtime on the live site - only during install. Commit `public/brands/*.svg`.

## About page wiring

`About.vue` uses **static HTML** (no `v-for` data array):

```html
<img class="integration-logo" src="/brands/figma.svg" alt="" width="24" height="24" />
<strong>Figma</strong>
```

Slug in the path = lowercase hyphenated name (`DaVinci Resolve` -> `/brands/davinci-resolve.svg`). Wire only in the integrations `<ol>` (no hero rotator).

No logo yet: use `<icon name="finished" />` instead of `<img>`.

Raster fallback: `<img src="/brands/final-cut-pro.png" ...>` when only PNG exists on Commons.

When SVGL and Commons miss: add `commons-logos.tsv` row or fetch from [Procreate brand kit](https://procreate.com/brand-use); `commons.sh` also supports curated third-party URLs (see `procreate` row).

Dark marks on dark UI: wrap in `<span class="logo-wrap logo-wrap--light-bg">` (Unity, Unreal).

## Workflow

1. List brands from `About.vue` or `assets/realness-integrations.txt`.
2. Run `missing-from-about.sh` (or `batch.sh` for the full list).
3. For remaining misses: `logo.sh --search`, browse SVGL, or search Commons and append `commons-logos.tsv`.
4. Paste static `<img src="/brands/{slug}.svg" ...>` into `About.vue` integrations `<li>`.
5. **Git add** `public/brands/*.svg`.
6. Verify `/brands/{slug}.svg` returns SVG (not HTML).

## API surface (summary)

| Task | Request |
|------|---------|
| SVGL search | `GET https://api.svgl.app?search={query}` |
| SVGL SVG | `GET https://api.svgl.app/svg/{filename}` |
| Commons upload | Row in `assets/commons-logos.tsv` or Commons API `imageinfo.url` |

See [references/api-surface.md](references/api-surface.md) and [references/commons.md](references/commons.md).

## References

- [commons.md](references/commons.md)
- [common-use-cases.md](references/common-use-cases.md)
- [troubleshooting-workarounds.md](references/troubleshooting-workarounds.md)
- [normalize-for-web.md](references/normalize-for-web.md)
- [examples.md](references/examples.md)
