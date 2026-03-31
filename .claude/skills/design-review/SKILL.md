---
name: design-review
description: Evaluate the technical merit of a chip design project repository — covering design specification, replicability, organization, readability, IPs/licenses, testing, and completeness. Use when asked to review or evaluate a hardware/chip design repo.
disable-model-invocation: true
argument-hint: [repo-directory]
allowed-tools: Read, Glob, Grep, Bash(git:*), Write(*/design-review-*.md)
---

# Chip Design Technical Review

Evaluate the repository at `$ARGUMENTS` (relative to the current working directory) against the rubric below. If no argument is provided, evaluate the current working directory.

Output your report to a markdown file named `design-review-<repo>.md` in the current working directory (NOT inside the repo), where `<repo>` is the basename of the repository directory (e.g., for `slugtpu/`, the file is `./design-review-slugtpu.md`). Do NOT convert the markdown to PDF — that step is handled separately by the Makefile.

## Pre-Review: Update Repository

Before starting the review, update the repository and all submodules. Use `git -C <dir>` instead of `cd <dir> && git ...` to avoid compound command permission issues:

1. `git -C <target-dir> checkout main` (or `master` if `main` does not exist)
2. `git -C <target-dir> pull`
3. `git -C <target-dir> submodule update --init --recursive`

The primary analysis should focus on the main branch. Also examine other branches using `git -C <dir> branch -a` — for each non-main branch, note whether it is stale (no recent commits), active (recent commits), and whether it appears ready to merge or contains work that should be integrated. All git commands during the review should use `git -C <target-dir>` rather than `cd`-ing into the directory.

If any of these commands fail, note the failure in the report but continue with the review.

## Guidelines

- Read the most relevant files: RTL code (Verilog/SystemVerilog/VHDL), testbenches, build scripts, Makefiles, READMEs, and configuration files.
- Skip files that are too long, hard to parse (waveform dumps, images, videos, binary files), or not relevant to the rubric.
- Rate each rubric section as one of: **Poor**, **Moderate**, **Good**, **Excellent**.

## Rubric

### 0. Design Specification
Check if there is a file called `report.pdf` in the repository root. If not found, look for any other `*.pdf` file in the repo root — if there is exactly one, assume it is the design specification. If found, read it and:
- Summarize the quality of the specification (clarity, completeness, formatting).
- Confirm that the repository contents correspond to what the specification describes, noting any significant differences (e.g., features described but not implemented, or implemented features not mentioned in the spec).
- Do NOT mention the filename in your report.

If no suitable PDF is found, skip this section entirely.

### 1. Replicability
- Does the repo include step-by-step instructions to replicate the results?
- Do they list the dependencies (tools, tool versions, libraries)?

### 2. Organization
- Does the repo maintain its files and directories in an organized manner?
- List the project structure in your report.

### 3. Readability
- Is the code easy to read?
- Do they follow a consistent naming convention?

### 4. IPs and Licenses
- What IPs (third-party cores, libraries, tools) do they use?
- For each IP, determine how it was included: is it a git submodule (check `.gitmodules`), or was the source code copied directly into the repo? Using submodules is preferred as it preserves provenance and allows updates; copying IP source files is poor practice.
- Does the repo include licenses for the used IPs?
- Does the repo have its own license file?
- Do source files include license or authorship headers?
- List the IPs used, noting for each whether it is a submodule or a copied source.

### 5. Testing and Verification
- Does the repo include software and/or hardware testing?
- Have they implemented a "software modeling" of the hardware (e.g., Python/C model)?
- What testing framework(s) do they use?

### 6. Summary
- Write a summary of what the project is about.
- List the complete and incomplete parts.
- Make suggestions for the contributors.

## Report Format

Use the following markdown structure for the report:

```
# Chip Design Review: [Project Name]

## 0. Design Specification — [Rating]
(Only if report.pdf exists; omit this section otherwise)
[Quality summary]
[Correspondence with repo — differences noted]

## 1. Replicability — [Rating]
[Analysis]

## 2. Organization — [Rating]
[Analysis]
[Project structure tree]

## 3. Readability — [Rating]
[Analysis]

## 4. IPs and Licenses — [Rating]
[Analysis]
[List of IPs]

## 5. Testing and Verification — [Rating]
[Analysis]

## 6. Summary
[Project summary]
### Complete Parts
[List]
### Incomplete Parts
[List]
### Suggestions
[List]
```
