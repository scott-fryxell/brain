# personal-context

Auto-loads an `AGENTS.local.md` file from the current directory (or the
nearest ancestor) and appends its contents to the system prompt.

## Why

pi loads `AGENTS.md` from global, parent, and cwd locations - but has no
built-in gitignored "local" variant. This extension provides one, so you can
keep personal, machine-specific, or sensitive context out of the shared
`AGENTS.md` while still having it active in every session.

## Setup

1. The extension is registered in the repo's `package.json` under
   `pi.extensions`, so it loads automatically once the project is trusted.
2. Create `AGENTS.local.md` next to your `AGENTS.md` (or in any ancestor
   directory you work from).
3. `AGENTS.local.md` is in the repo `.gitignore`, so it will not be
   committed.

If no `AGENTS.local.md` is found, the extension does nothing - safe to ship
in a shared repo for users who do not use the feature.

## How it works

On `session_start`, walks up from cwd looking for `AGENTS.local.md`. Stops
at the git repo boundary (a directory containing `.git`) or the filesystem
root. The first match (nearest to cwd) wins.

On `before_agent_start`, appends the file contents under a
`## Personal Context` heading, with the source path noted.
