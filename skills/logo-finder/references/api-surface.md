# SVGL API surface

Base URL: `https://api.svgl.app`

Docs: https://svgl.app/docs/api

## Response type (SVG entry)

```ts
export type ThemeOptions = { dark: string; light: string }

export interface SVG {
  id: number
  title: string
  category: string | string[]
  route: string | ThemeOptions
  url: string
  wordmark?: string | ThemeOptions
  brandUrl?: string
  subTitle?: string
}
```

## Endpoints

### `GET /`

All logos. Optional query params:

| Param | Example | Behavior |
|-------|---------|----------|
| `limit` | `?limit=10` | Cap result count |
| `search` | `?search=figma` | Title search (array) |

### `GET /category/{slug}`

Logos in one category. Category slugs from `GET /categories` (lowercase, e.g. `software`, `design`).

### `GET /categories`

List of `{ category, total }`.

### `GET /svg/{filename}`

Returns raw SVG markup. Filename from `route` path (e.g. `figma.svg`, `illustrator.svg`).

| Param | Behavior |
|-------|----------|
| `no-optimize` | Skip SVGO pass |

## Route URL shapes

| Shape | Example | Fetch |
|-------|---------|-------|
| string | `https://svgl.app/library/figma.svg` | `/svg/figma.svg` |
| ThemeOptions | `{ light, dark }` | `/svg/{light-or-dark-filename}` |

`wordmark` is optional; use only when the UI needs the full wordmark, not the icon mark.

## Rate limits

Public, no API key. Rate limited - batch with pauses if a run hits errors; cache files in repo (`public/brands/`).

## Prohibited use (upstream)

Do not build a competing SVGL catalog on this API. Extensions and project asset pipelines are the intended use.
