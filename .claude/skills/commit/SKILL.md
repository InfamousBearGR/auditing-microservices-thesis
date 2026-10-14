---
name: commit
description: Stage and create a git commit whose message follows the caveman-commit rules (terse Conventional Commits, why over what). Use when the user says "commit", "commit it", "stage and commit", "make a commit", or invokes /commit. Unlike caveman-commit (message only), this skill actually runs git add and git commit.
---

# /commit

Create a real commit. Message written per the `caveman:caveman-commit` skill. Arguments (optional): paths to include, or a hint about intent/scope.

## Steps

1. **Inspect state** (one Bash call):
   ```bash
   git branch --show-current
   git status --short
   git diff --cached --stat
   git diff --stat
   git log --oneline -5
   ```

2. **Pick files.** Decide the exact paths that belong to this change:
   - If the user named paths, use those only.
   - Otherwise, the files this session's task modified. If unclear, ask.
   - **Already-staged files that are not part of this change must be unstaged** (`git restore --staged <path>`) before committing. Never assume the index is clean.
   - Never stage: build outputs/binaries, gitignored `graphify-out/` files (cache, backups), `.env*`, credentials, large generated files, `node_modules/`. Warn if they appear.
   - Stage with explicit paths: `git add <path>...`. Never `git add -A` / `git add .`.

3. **Verify the index** before committing: `git diff --cached --stat`. The listed files must be exactly the intended set. If anything else is there, fix it first.

4. **Write the message** following `caveman:caveman-commit` rules:
   - `<type>(<scope>): <imperative summary>`. Use the types `feat|fix|refactor|perf|docs|test|chore|build|ci|style|revert`. Aim for ≤50 chars, hard cap 72, no trailing period.
   - Match the repo's capitalization and scope style from `git log`.
   - Body only when the why is not obvious, or for breaking changes, security fixes, migrations and reverts. Wrap at 72, use `-` bullets.
   - Never write "this commit", "I", "we", "now", or emoji.
   - No AI attribution and no Co-Authored-By trailer, unless the user asks for one.

5. **Commit** with a heredoc so formatting survives:
   ```bash
   git commit -F - <<'EOF'
   <subject>

   <body if any>
   EOF
   ```
   Never `--no-verify` and never `--amend` unless the user asks. If a pre-commit hook fails, fix the cause and make a new commit. Do not bypass the hook.

6. **Confirm**: `git show --stat --format='%h %s' HEAD`. Then report:
   - the hash, branch and subject
   - the files committed
   - anything left uncommitted or unstaged on purpose

   Do not push unless asked.
