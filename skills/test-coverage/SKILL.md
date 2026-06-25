---
name: test-coverage
description: Analyzes Vitest V8 coverage and Fallow health (complexity, CRAP, cycles, unused files) to prioritize test-first refactors. Use when improving coverage, reviewing fallow output, asking what to test before refactoring, or after test:coverage or npx fallow fails thresholds.
---

# Test coverage + Fallow refactor risk

Turn **`npm run test:coverage`** and **`npx fallow`** into a **test-before-refactor** plan — not a blind chase for 100%.

## When to use

- User asks what to test, what to refactor, or where risk is highest
- `test:coverage` or coverage thresholds fail CI / pre-commit
- After `npx fallow` reports cycles, complexity, or unused files
- Before breaking import cycles or extracting large functions

## Prerequisites

From the **project root** (where `vite.config` / `package.json` lives):

```bash
npm run test:risk
```

Or step by step:

```bash
npm run test:coverage    # coverage/coverage-final.json
npx fallow             # fallow-report.json (Vitest plugin + health)
npm run test:risk:report
```

## Workflow

### 1. Risk report (start here)

```bash
npm run test:risk
# or, if reports already exist:
npm run test:risk:report
```

Runs `scripts/prioritize-refactor-risk.js` (skill path via package.json).

- **Delete or wire** — fallow `unused-files`; do not add tests
- **Test before refactor** — ranked by coverage gap + CRAP + fan-in + hotspots + P0/P1

Options: `--threshold 80 --top 25 --root .`

### 2. Coverage-only table

```bash
node skills/test-coverage/scripts/summarize-coverage.js --root .
```

### 3. HTML + line detail

Open `coverage/index.html` for uncovered lines inside a file.

### 4. Fallow detail

```bash
npx fallow health --targets    # refactoring recommendations
npx fallow health --hotspots   # churn + complexity
npx fallow --format json       # full machine output
```

### 5. Project context

1. Nearest spec: `tests/**` mirroring `src/**`
2. `.cursorrules`, `AGENTS.md`
3. **realness web:** [references/web-realness.md](references/web-realness.md)
4. **Fallow config:** [references/fallow-integration.md](references/fallow-integration.md)

Classify each item:

| Verdict | Meaning |
| --- | --- |
| **test-first** | Add/extend specs before refactor |
| **refactor-with-tests** | Some coverage; add tests around hot paths then refactor |
| **delete-or-wire** | Fallow unused file — entry point or delete |
| **defer** | Low product risk |

### 6. Evolving Fallow config

When this skill changes behavior, update:

1. Project `.fallowrc.json` (see fallow-integration.md sections)
2. Changelog table in [references/fallow-integration.md](references/fallow-integration.md)
3. This SKILL.md if workflow or scripts change

### 7. Optional: implement tests

Only when the user asks. Re-run `npm run test:risk` after changes.

## Output format

```markdown
# Refactor risk (coverage + fallow)

## Delete or wire
- …

## Test before refactor
| file | pri | cov% | risk | … |

## Workflow
```

Priority labels: **P0** IDs/auth/sync/payments, **P1** posters/potrace/3D, **P2** rest.

## Judgment principles

- Unused in fallow graph → **delete or wire**, not test
- High complexity + low coverage + high fan-in → **test-first**
- Cycles (`itemid` ↔ `serverless`, `Directory`) → characterize with tests, then break cycle
- Nuclear triad: typecheck + lint + tests; coverage supports refactors
- Match existing spec style; prefer extending specs over new files

## Scripts

| Script | Purpose |
| --- | --- |
| `scripts/summarize-coverage.js` | Coverage table |
| `scripts/prioritize-refactor-risk.js` | Coverage + fallow merge |
| `scripts/lib/coverage-metrics.js` | Shared Istanbul parsing |

## Related skills

- `test-javascript-patterns` — Vitest/Vue tests
- [Fallow integration](references/fallow-integration.md) — `.fallowrc.json` ownership
