# realness.online web — coverage priorities

Use when `package.json` name is `@realness.online/web` or cwd is `work/web`.

## Thresholds (vite.config.js)

- Global gate: **80%** lines, branches, statements, functions
- `all: true` — untested files count against you

## Excluded from coverage (do not recommend tests here)

- `src/main.js`, `src/router.js`, `src/wasm/**`
- Already aligned with low ROI for unit tests

## Architecture map

| Area | Path | Test home | Priority |
| --- | --- | --- | --- |
| Item IDs / sync | `src/utils/itemid.js`, `itemid-parse.js` | `tests/utils/`, `tests/sync-*` | **P0** — nuclear triad |
| Auth / me | `src/utils/serverless.js`, `src/persistence/` | `tests/components/`, `tests/use/` | **P0** |
| Sponsorship / Stripe | `src/use/sponsor.js`, `src/components/sponsor/` | `tests/components/sponsor/` | **P0** |
| Posters / SVG | `src/use/poster.js`, `src/components/posters/` | `tests/components/posters/` | **P1** |
| 3D viewer | `src/3d/`, `as-viewer-3d.vue` | new `tests/3d/` or component specs | **P1** (new code) |
| Preferences | `src/utils/preference.js` | extend `tests/App.spec.js` mocks | **P2** |
| Potrace | `src/potrace/` | `tests/potrace/` | **P1** — algorithmic |
| Views | `src/views/` | `tests/views/` | **P1** — user flows |

## Existing test patterns

- Specs: `tests/**/*.spec.js` (Vitest + happy-dom)
- Mocks: `tests/mocks/`, `vi.mock` for `@/utils/serverless`, `@/utils/preference`
- Vue: `shallowMount`, stub child components, hoist refs with `vi.hoisted`
- Person prop: `{ id, name, type: 'person' }` for `is_person` validator

## Judgment rules

**Add tests when**

- Uncovered branches are user-visible (routing, payments, poster export)
- File is in P0/P1 and has no spec file yet
- Bug-prone: async, parsing, ID transforms, filesystem sync

**Defer or accept risk when**

- Thin re-export or glue to browser APIs already mocked globally
- UI-only template with logic covered by parent spec
- Exploratory / dev-only (Tweakpane tuning in preferences)

**Do not chase 100%**

- Visual 3D scene graphs — test scene factories and settings API, not every Three.js branch
- Generated or vendor-adjacent code

## Fallow + test-first refactor

- `npm run test:risk` — coverage, fallow, merged risk report
- `.fallowrc.json` — tuned with [fallow-integration.md](fallow-integration.md); update that doc when config changes

## Docs to read before recommending work

- `work/web/.cursorrules` — nuclear triad, snake_case, no defensive try/catch
- `work/web/AGENTS.md` — vp test, check commands
- Nearest existing `tests/**` mirror for the uncovered file
