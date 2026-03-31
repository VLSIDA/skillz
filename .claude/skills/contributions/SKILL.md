---
name: contributions
description: Analyze a repository for contributor activity since a given date — commit counts per author and a qualitative assessment of the complexity and significance of each contributor's work. Use when asked to evaluate contributions or contributor activity.
disable-model-invocation: true
argument-hint: [repo-directory] [since-date]
allowed-tools: Read, Glob, Grep, Bash(git:*), Write(*/contributions-*.md)
---

# Repository Contribution Analysis

Analyze contributions to the repository at `$ARGUMENTS`.

- The first argument is the repo directory (relative to the current working directory). If not provided, use the current working directory.
- The second argument is a date in `YYYY-MM-DD` format. If not provided, default to two weeks before today's date.

Output your report to a markdown file named `contributions-<repo>.md` in the current working directory (NOT inside the repo), where `<repo>` is the basename of the repository directory.

## Pre-Review: Update Repository

Before starting, update the repository. Use `git -C <dir>` instead of `cd <dir> && git ...` to avoid compound command permission issues:

1. `git -C <target-dir> checkout main` (or `master` if `main` does not exist)
2. `git -C <target-dir> pull`
3. `git -C <target-dir> submodule update --init --recursive`

The primary analysis should focus on the main branch. Also examine other branches using `git -C <dir> branch -a` — for each non-main branch, note whether it is stale (no recent commits), active (recent commits), and whether it appears ready to merge or contains work that should be integrated. All git commands should use `git -C <target-dir>` rather than `cd`-ing into the directory.

If any of these commands fail, note the failure in the report but continue.

## Part 1: Contribution Volume

Analyze commit activity on the main branch since the given date:

- Use `git -C <dir> shortlog -sne --since=<date>` to get commit counts per author.
- Use `git -C <dir> log --since=<date> --oneline` to get the full commit list.
- Use `git -C <dir> log --since=<date> --format="%H %ae" --shortstat` to gather per-author lines added/removed.
- Present a table of contributors with: number of commits, lines added, lines removed.
- Note any group members (from the repo's contributor history) who have zero commits in the period.

## Part 2: Contribution Quality

For each contributor, examine their commits in detail using `git -C <dir> log --since=<date> --author=<email> -p` and classify each commit into one of the following categories:

### Major
Commits that add substantial new functionality, implement significant features, create new modules, or address critical missing components. These commits involve meaningful design decisions and nontrivial code.

### Minor
Commits that fix bugs, improve existing code quality, add meaningful tests, refactor for clarity or performance, or extend existing features in useful ways. These require understanding of the codebase and make real improvements.

### Trivial
Commits that make superficial changes with little substance — whitespace fixes, renaming without purpose, comment-only changes, reformatting, duplicating existing code, or splitting work into many tiny commits to inflate commit count. Also includes merge commits that resolve no conflicts.

For each contributor, provide:
- A breakdown of how many of their commits fall into each category.
- A brief narrative summarizing the nature and significance of their contributions.
- Representative examples of their most and least significant commits (cite commit hash and message).

## Report Format

```
# Contribution Analysis: [Project Name]

**Period:** [since-date] to present

## Contribution Volume

| Contributor | Commits | Lines Added | Lines Removed |
|---|---|---|---|
| ... | ... | ... | ... |

[Note any contributors with zero commits]

## Contribution Quality

### [Contributor Name] <email>
- **Major:** N commits
- **Minor:** N commits
- **Trivial:** N commits

[Narrative summary]

**Notable commits:**
- `abc1234` — [description] (Major)
- `def5678` — [description] (Trivial)

(Repeat for each contributor)

## Overall Assessment

[Summary of team contribution patterns — is work evenly distributed? Are contributions substantive or inflated? Any concerns?]
```
