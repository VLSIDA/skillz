# Project Repo Review Tools

Automated review tools for project repositories using [Claude Code](https://claude.ai/claude-code) skills.

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI (`claude`)
- `pandoc` with `xelatex` (for PDF generation)
- `git`, `bash`

## Interactive Usage

Run any skill interactively from within a repository by starting a Claude Code session:

```sh
cd my-project
claude
```

Then use a slash command to run a skill:

```
/design-review .
/contributions . 2026-03-01
/updates .
/prompt-injection-audit .
```

Or run a skill directly from the command line:

```sh
claude "/design-review my-project"
claude "/contributions my-project 2026-03-01"
claude "/updates my-project"
claude "/prompt-injection-audit my-project"
```

## Skills

### design-review

Evaluates the technical merit of a project repo: design documentation, replicability, organization, readability, IPs/licenses, testing, and completeness.

### contributions

Analyzes contributor activity since a given date (default: last 2 weeks). Reports commit volume per author and classifies each commit as major, minor, or trivial.

### updates

Progress review since a given date: what changed, new features, design progress, open issues, and an overall assessment.

### prompt-injection-audit

Scans a repository for hidden or obfuscated content designed to manipulate AI-generated reviews — including direct instructions to AI, Unicode tricks, commit message manipulation, and fabricated content.

### brutal-review

Brutal final-pass reviewer for near-final research paper submissions.

## Batch Mode

For reviewing multiple repositories at once, use the Makefile with a groups YAML file.

### Groups File

Define project groups in a YAML file. See [`example.yaml`](example.yaml) for a complete example. Each entry has a project name, a git repo URL, and a list of members:

```yaml
groups:
  - projects: "Example Group Project"
    repo: https://github.com/org/group-project
    members:
      - name: Student One
        email: XXX@ucsc.edu
      - name: Student Two
        email: XXX@ucsc.edu
      - name: Student Three
        email: XXX@ucsc.edu

  - projects: "Grad Student Individual Project"
    repo: https://github.com/jdoe/grad-project
    members:
      - name: Grad Student One
        email: XXX@ucsc.edu
```

The `GROUP` variable used in make targets corresponds to the last path component of the repo URL (e.g., `group-project` for `https://github.com/org/group-project`).

### Clone Repositories

```sh
make clone
make clone YAML=other-groups.yaml    # use a different groups file
```

### Run Reviews

```sh
make design-review                                  # all groups
make design-review GROUP=group-project              # single group

make contributions                                  # all groups, last 2 weeks
make contributions GROUP=group-project SINCE=2026-03-01  # custom date

make updates                                         # all groups, last 2 weeks
make updates GROUP=group-project SINCE=2026-03-01    # custom date

make audit                                          # all groups
make audit GROUP=group-project                      # single group
```

All targets produce both `.md` and `.pdf` output.

### Makefile Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `YAML`   | `groups.yaml` | Groups file to use |
| `GROUP`  | (all groups) | Run against a single group |
| `SINCE`  | 2 weeks ago | Start date for contributions/updates (`YYYY-MM-DD`) |

### Other Targets

| Target | Description |
|--------|-------------|
| `all`  | Build all design review PDFs |
| `clone` | Clone all repos from the YAML file |
| `clean` | Remove all generated files |
