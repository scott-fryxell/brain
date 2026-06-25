# brain

A personal monorepo workspace for [pi](https://github.com/earendil-works/pi-coding-agent): skills, extensions, bin scripts, and agent config. Starting point for a digital brain.

## What's here

| Path            | Contents                                                       |
| --------------- | -------------------------------------------------------------- |
| `skills/`       | Original skills maintained in this repo                        |
| `extensions/`   | pi extensions (see below)                                      |
| `bin/`          | Shell and JS scripts (`pi`, vault tooling, media helpers)      |
| `AGENTS.md`     | Shared agent instructions (preferences, code style)            |
| `settings.json` | pi settings (default provider/model, enabled models, packages) |
| `models.json`   | Custom model + provider definitions                            |
| `sessions/`     | Session logs                                                   |

## Setup

Requires Node >= 22.19.

```bash
npm install
npm start          # runs pi
```

Or run pi directly:

```bash
./bin/pi
```

## Skills

Skills live in `skills/` - one folder per skill, each with a `SKILL.md`. pi discovers them automatically via the `pi.skills` entry in `package.json`.

### Skill management approach

There are two kinds of skills in a brain workspace:

**Original skills** (checked in here): maintained in this repo. Edit them directly.

**Externally-maintained skills** (hyperframes, skill-finder, simplify, etc.): maintained upstream. Do **not** vendor copies into `skills/` - they drift from upstream and become a maintenance burden. Install them as pi packages instead:

```bash
pi install git:github.com/heygen-com/hyperframes
pi install git:github.com/vercel-labs/skills
```

This adds them to `settings.json` under `packages`, and pi loads the skills from the managed location. Update with:

```bash
pi update --all
```

If you have leftover vendored copies of externally-maintained skills in `skills/`, remove them before installing as packages to avoid duplicates.

## Extensions

Extensions live in `extensions/`. Each is a subdirectory with an `index.ts`.

### personal-context

Auto-loads an `AGENTS.local.md` file from the current directory (or nearest ancestor) and appends it to the system prompt. Use it for machine-local or sensitive context you don't want to commit - personal preferences, absolute paths, project context that only applies to you.

**Setup:**

1. Create `AGENTS.local.md` next to your `AGENTS.md`.
2. It's already in `.gitignore`, so it won't be committed.

If no `AGENTS.local.md` is found, the extension does nothing. See `extensions/personal-context/README.md`.

## Agent context (`AGENTS.md`)

The shared `AGENTS.md` contains reusable agent config: output preferences, typography rules, communication style, and code conventions. It's safe for anyone to use.

Personal context (vault references, local paths, music/events) belongs in `AGENTS.local.md` (gitignored, loaded by the personal-context extension), not in the shared file.

## Syncing dev -> published

This repo is the published mirror. Develop in your local brain workspace, then sync changes here. See the `brain-sync` skill for the workflow.
