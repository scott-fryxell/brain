# Validation Checklist

After copying files from dev `/brain/` to `/brain/work/brain/`, run these validations.

## Pre-copy validation

Before copying, verify:

- [ ] Dev `/brain/` has uncommitted changes that need syncing
- [ ] `work/brain/` exists and has a `.git/` directory
- [ ] No uncommitted changes in `work/brain/` (run `git status`)

## Post-copy validation

After copying, all of these must pass:

### Security checks

**No .env files**

```bash
find /brain/work/brain/ -type f -name '.env*'
# Should return nothing
```

**No git directories**

```bash
find /brain/work/brain/ -type d -name '.git'
# Should return nothing
```

### Structure checks

**Required directories exist**

```bash
test -d /brain/work/brain/skills && \
test -d /brain/work/brain/extensions && \
test -d /brain/work/brain/themes && \
test -d /brain/work/brain/prompts && \
test -d /brain/work/brain/sessions && \
test -d /brain/work/brain/bin && \
test -f /brain/work/brain/package.json
# All should exist
```

**Directories are non-empty**

```bash
[ -n "$(find /brain/work/brain/skills -maxdepth 1 -type d | tail -n +2)" ] && echo "skills has subdirs"
[ -n "$(find /brain/work/brain/extensions -maxdepth 1 -type d | tail -n +2)" ] && echo "extensions has subdirs"
# Should show at least some content
```

### Git readiness

**No git errors**

```bash
cd /brain/work/brain/
git status
# Should show clean or modified files, no errors
```

**Can stage changes**

```bash
cd /brain/work/brain/
git add -A --dry-run
# Should work without errors
```

## Validation failure recovery

| Failure             | Cause                      | Fix                                                   |
| ------------------- | -------------------------- | ----------------------------------------------------- |
| `.env` found        | Secret files copied        | Delete `work/brain/` copy, fix exclude pattern, retry |
| `.git/` found       | Nested project dirs copied | Check exclusion, manually remove `.git/` dirs, retry  |
| Missing directories | Copy was incomplete        | Verify source `/brain/` has those dirs, retry copy    |
| Git status error    | Corrupted repo state       | Run `git status` in `work/brain/`, fix issues, retry  |

If validation fails more than once, abort the sync and review the exclude patterns with the agent.
