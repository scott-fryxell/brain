# Sync Workflow Details

Step-by-step guide for the agent to execute the sync.

## Step 1: Detect changes

Before syncing, understand what changed in dev since the last sync.

```bash
# List new/modified skills
ls -la /brain/skills/ | head -20

# List new/modified extensions
ls -la /brain/extensions/ | head -20

# Check if bin/pi changed
ls -la /brain/bin/pi

# Check if package.json changed
git -C /brain/work/brain/ diff HEAD -- package.json | head -30
```

**Output for agent**: List the major changes detected (new skills, updated extensions, etc).

## Step 2: Create a plan

Show the user what will happen:

```markdown
# Sync Plan

## Changes detected

- New skill: `skills/example-skill/`
- Modified: `skills/existing-skill/SKILL.md`
- Updated: `extensions/my-extension/`
- No changes to: themes/, prompts/, sessions/

## What will be copied

- Source: /brain/skills/ → Destination: /brain/work/brain/skills/
- Source: /brain/extensions/ → Destination: /brain/work/brain/extensions/
- Source: /brain/themes/ → Destination: /brain/work/brain/themes/
- Source: /brain/prompts/ → Destination: /brain/work/brain/prompts/
- Source: /brain/sessions/ → Destination: /brain/work/brain/sessions/
- Source: /brain/bin/pi → Destination: /brain/work/brain/bin/pi
- Source: /brain/package.json → Destination: /brain/work/brain/package.json

## What will be excluded

- .git/ directories (from nested projects like work/agent-browser/)
- .env files (secrets)
- node_modules/ (build artifacts)
- .DS_Store, dist/, other temp files

## Ready to proceed?

- [ ] Review changes above
- [ ] Confirm you want to sync
```

**Ask the user to approve** before proceeding.

## Step 3: Execute copy

Use `rsync` for safe, atomic copying with exclusion patterns:

```bash
rsync -av \
  --delete \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='node_modules' \
  --exclude='.DS_Store' \
  --exclude='dist' \
  --exclude='.next' \
  --exclude='build' \
  /brain/skills/ /brain/work/brain/skills/

rsync -av \
  --delete \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='node_modules' \
  --exclude='.DS_Store' \
  /brain/extensions/ /brain/work/brain/extensions/

# Themes, prompts, sessions (same pattern)
rsync -av --delete /brain/themes/ /brain/work/brain/themes/
rsync -av --delete /brain/prompts/ /brain/work/brain/prompts/
rsync -av --delete /brain/sessions/ /brain/work/brain/sessions/

# Individual files
cp /brain/bin/pi /brain/work/brain/bin/pi
cp /brain/package.json /brain/work/brain/package.json
```

**Output for agent**: "Files copied. Running validation..."

## Step 4: Validate

Run all checks from `references/validation.md`.

If any check fails, show the error and stop. Ask user to fix or retry.

If all checks pass, continue to Step 5.

## Step 5: Show git diff

Display what changed in the published repo:

```bash
cd /brain/work/brain/

# Short summary
git diff --stat

# Full diff
git diff
```

For large diffs, show:

- Summary (files added/modified/deleted)
- Key files like `package.json` and `SKILL.md`s in full
- Large binary files (skip)

**Output for agent**: Clear, scannable diff that user can review.

## Step 6: Propose commit message

Analyze the changes and suggest a commit:

```bash
cd /brain/work/brain/

# Count changes by type
git diff --stat | tail -1  # shows total files/lines

# Look at package.json to infer version
grep '"version"' package.json
```

**Suggested commit format:**

```
Release: brain-sync update [date]

- Added: list new skills/extensions
- Updated: list modified skills/extensions
- Changed: package.json or config updates

Synced from dev /brain/ → published work/brain/
```

**Ask the user** to review and approve the message before committing.

## Step 7: Commit

When user approves:

```bash
cd /brain/work/brain/
git add -A
git commit -m "your approved message"
```

**Output for agent**:

```
[main abc1234] Release: brain-sync update...
 X files changed, Y insertions(+), Z deletions(-)
```

Show the commit hash and summary.

## Cleanup

After successful commit:

```bash
cd /brain/work/brain/
git log --oneline -5  # Show recent commits
```

**Output for agent**: "Sync complete. work/brain/ is now up to date and ready to tag/release."

## Troubleshooting steps

If any step fails, show the error clearly and suggest:

1. Check the file system (does the source exist?)
2. Review the exclude patterns (is something being filtered by accident?)
3. Check git status in work/brain/ (are there conflicts?)
4. Ask user if they want to skip this sync or fix and retry

Never proceed if validation fails.
