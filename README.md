# Project Repo Review Tools

Automated review tools for project repositories using [Claude Code](https://claude.ai/claude-code) skills.

## Setup

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI (`claude`)
- `pandoc` with `xelatex` (for PDF generation)
- `git`, `bash`

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
```

To use a different YAML file:

```sh
make clone YAML=other-groups.yaml
```

## Skills

### design-review

Evaluates the technical merit of a chip design repo: design specification, replicability, organization, readability, IPs/licenses, testing, and completeness. Outputs a PDF.

```sh
make design-review                      # all groups
make design-review GROUP=group-project        # single group
```

### contributions

Analyzes contributor activity since a given date: commit volume per author and a qualitative assessment of each contribution as major, minor, or trivial. Outputs a dated markdown file.

```sh
make contributions                              # all groups, last 2 weeks
make contributions GROUP=group-project                # single group
make contributions GROUP=group-project SINCE=2026-03-01  # custom date
```

### weekly

Weekly progress review: what changed, new features, design progress, open issues, and an overall assessment. Outputs a dated markdown file.

```sh
make weekly                                     # all groups, last 2 weeks
make weekly GROUP=group-project                       # single group
make weekly GROUP=group-project SINCE=2026-03-01      # custom date
```

### brutal-review

Brutal final-pass reviewer for near-final research paper submissions.

## Makefile Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `YAML`   | `groups.yaml` | Groups file to use |
| `GROUP`  | (all groups) | Run against a single group |
| `SINCE`  | 2 weeks ago | Start date for contributions/weekly (`YYYY-MM-DD`) |

## Other Targets

| Target | Description |
|--------|-------------|
| `all`  | Build all design review PDFs |
| `clone` | Clone all repos from the YAML file |
| `clean` | Remove all generated files |
