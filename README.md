# agent-skills

[![Skills CI](https://github.com/ragnarok22/agent-skills/actions/workflows/skills-ci.yml/badge.svg)](https://github.com/ragnarok22/agent-skills/actions/workflows/skills-ci.yml)
![Skills](https://img.shields.io/badge/skills-4-blue)
![Platform](https://img.shields.io/badge/platform-Codex%20%7C%20Claude%20Code-blueviolet)

Source-of-truth repository for local Codex/Agent skills. Skills are reusable, versioned, and validated in CI.

## Available Skills

| Skill                                                          | Description                                                                                                   |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| [dependency-risk-audit](skills/dependency-risk-audit/)         | Review Python dependencies for security advisories, stale pins, and unsafe upgrade paths                      |
| [django-doctor](skills/django-doctor/)                         | Audit Django codebases for security, performance, correctness, and architecture antipatterns                  |
| [queryset-optimizer](skills/queryset-optimizer/)               | Optimize Django ORM performance by detecting N+1 query patterns, missing eager loading, and likely index gaps |
| [write-conventional-commit](skills/write-conventional-commit/) | Draft and apply commit messages that comply with Conventional Commits 1.0.0                                   |

## Repository Layout

```text
agent-skills/
  AGENTS.md
  README.md
  skills/
    <skill-name>/
      SKILL.md              # required
      agents/openai.yaml    # required
      README.md             # recommended
      scripts/              # optional
      references/           # optional
      assets/               # optional
```

Skill folder names must be lowercase and hyphen-separated (example: `pricing-copy-audit`).

## Quick Start

### Install a skill from this repo

```bash
npx skills add ragnarok22/agent-skills --skill django-doctor
```

### Create a new skill scaffold

```bash
make create <skill-name>
```

This creates:

- `skills/<skill-name>/SKILL.md`
- `skills/<skill-name>/agents/openai.yaml`
- `skills/<skill-name>/README.md`
- Optional support directories: `scripts/`, `references/`, `assets/`

### Validate local changes

```bash
make lint
find skills -mindepth 1 -maxdepth 1 -type d -print | sort
find skills -type f -name '*.md' -size 0
```

### Format docs and metadata

```bash
make format
```

## Contribution Guidelines

1. Add or update skill content under `skills/<skill-name>/`.
2. Ensure each skill includes required files:
   - `SKILL.md`
   - `agents/openai.yaml`
3. Run local checks (`make lint`) before opening a PR.
4. Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`).

PR descriptions should include purpose/scope, verification commands run, and notable filesystem-impact notes (if any).

## CI

The `Skills CI` workflow validates skill structure and repository consistency on pushes and pull requests.
