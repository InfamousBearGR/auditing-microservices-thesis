---
name: pr
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git diff:*), Bash(git status:*), Bash(gh pr create:*), Bash(gh pr view:*)
description: Create a pull request against master with a change summary
---

## Context

- Current branch: !`git branch --show-current`
- Base branch: master
- Tracking status: !`git status -sb | head -1`
- Recent commits on branch: !`git log --oneline master..HEAD`
- Diff summary: !`git diff master...HEAD --stat`

## Task

1. If the branch is `master`, has no commits ahead of `master`, or is not pushed / is ahead of its remote (see tracking status), stop and tell the user. Do not push.
2. Analyze commits and diff to understand what changed.
3. Create PR using `gh pr create` targeting `master` with:
   - **Base**: `--base master`
   - **Title**: `<short imperative description>` (≤72 chars, Conventional Commits style matching the repo, e.g. `refactor(sse-bridge): rename UserAccount to ApiUserAccount`)
   - **Assignee**: `--assignee @me`
   - **Body** (use HEREDOC):
     ```
     ## Changes

     <2-4 bullet points describing what changed and why — focus on the "why" when non-obvious>
     ```
4. Output only the PR URL.
