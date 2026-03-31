---
name: weekly
description: Weekly progress review of a chip design repository — summarize what changed since a given date (default last two weeks), including new features, bug fixes, design changes, and open issues. Use when asked for a weekly update or progress check on a hardware/chip design repo.
disable-model-invocation: true
argument-hint: [repo-directory] [since-date]
allowed-tools: Read, Glob, Grep, Bash(git:*), Write(*/weekly-*.md)
---

# Weekly Design Review

Analyze what has changed in the repository at `$ARGUMENTS` since the given date.

- The first argument is the repo directory (relative to the current working directory). If not provided, use the current working directory.
- The second argument is a date in `YYYY-MM-DD` format. If not provided, default to two weeks before today's date.

Output your report to a markdown file named `weekly-<repo>.md` in the current working directory (NOT inside the repo), where `<repo>` is the basename of the repository directory.

## Pre-Review: Update Repository

Before starting, update the repository. Use `git -C <dir>` instead of `cd <dir> && git ...` to avoid compound command permission issues:

1. `git -C <target-dir> checkout main` (or `master` if `main` does not exist)
2. `git -C <target-dir> pull`
3. `git -C <target-dir> submodule update --init --recursive`

The primary analysis should focus on the main branch. Also examine other branches using `git -C <dir> branch -a` — for each non-main branch, note whether it is stale (no recent commits), active (recent commits), and whether it appears ready to merge or contains work that should be integrated. All git commands should use `git -C <target-dir>` rather than `cd`-ing into the directory.

If any of these commands fail, note the failure in the report but continue.

## Analysis

### 1. Change Summary

Use `git -C <dir> log --since=<date> --oneline` and `git -C <dir> diff <first-commit-before-date>..HEAD --stat` to understand the scope of changes.

Provide a high-level narrative of what happened in the repo during this period. Group changes thematically (e.g., "RTL changes", "testbench updates", "build system", "documentation").

### 2. New and Modified Files

List the files that were added, modified, or deleted. Use `git -C <dir> diff --name-status <first-commit-before-date>..HEAD` to get this.

For significant new or modified RTL files, testbenches, or build scripts, read them and briefly describe what they do or what changed.

### 3. Design Progress

Based on the changes, assess:
- What new features or modules were added?
- What existing functionality was improved or fixed?
- Were any design decisions reversed or significantly changed?
- Is there evidence of integration work (connecting modules, top-level wiring)?
- Are there new or updated testbenches that correspond to new RTL?

### 4. Open Issues

Check for signs of incomplete work:
- Unmerged branches with recent activity: `git -C <dir> branch -a --no-merged`
- TODO/FIXME/HACK comments in recently changed files.
- Testbenches that exist but appear to fail or be incomplete.

### 5. Assessment

Provide an overall assessment of the project's progress during this period:
- Is the project on track? Is meaningful progress being made?
- Are there any red flags (stalled work, regressions, abandoned branches)?
- What should the team focus on next?

## Report Format

```
# Weekly Review: [Project Name]

**Period:** [since-date] to present
**Commits in period:** N

## Change Summary
[Thematic narrative of changes]

## New and Modified Files
| Status | File | Description |
|---|---|---|
| A/M/D | path/to/file | Brief description |

## Design Progress
### New Features
[List]
### Improvements and Fixes
[List]
### Design Changes
[List]
### Integration Work
[List]

## Open Issues
### Unmerged Branches
[List or "None"]
### TODOs and FIXMEs
[List or "None"]
### Incomplete Work
[List or "None"]

## Assessment
[Overall progress assessment and recommendations]
```
