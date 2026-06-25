# Common use cases

## 1. About page (`work/web`)

Brand list: `About.vue` `integration_tools` or `skills/logo-finder/assets/realness-integrations.txt`.

```bash
bash skills/logo-finder/scripts/batch.sh \
  skills/logo-finder/assets/realness-integrations.txt \
  work/web/public/brands
```

After batch misses, fill gaps from Commons and `About.vue` nulls:

```bash
bash skills/logo-finder/scripts/missing-from-about.sh work/web/src/views/About.vue work/web/public/brands
```

Markup (static paths in `About.vue`):

```html
<img class="integration-logo" src="/brands/figma.svg" alt="" width="24" height="24" />
<strong>Figma</strong>
```

Empty `alt` when the product name is visible beside the logo.

## 2. One-off fetch

```bash
bash skills/logo-finder/scripts/logo.sh Canva work/web/public/brands/canva.svg
```

## 3. Inspect before save

```bash
bash skills/logo-finder/scripts/logo.sh "Premiere Pro" --search
```

## 5. Commit for deploy

```bash
git -C work/web add public/brands/
```

Files must be in git or production 404s on `/brands/*.svg`.

## 6. Verify locally

With dev server running, visit `https://realness.local/brands/canva.svg` (or `http://localhost:5173/brands/canva.svg`).

## 7. Refresh one logo

Re-run `logo.sh` to the same path; commit the diff.

## 8. Slug map

| Display name | File slug |
|--------------|-----------|
| Premiere Pro | `premiere-pro` |
| After Effects | `after-effects` |
| Unreal Engine | `unreal-engine` |
| Affinity Designer | `affinity-designer` |
| Affinity Photo | `affinity-photo` |
