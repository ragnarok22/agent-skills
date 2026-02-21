# agent-skills

[![Skills CI](https://github.com/ragnarok22/agent-skills/actions/workflows/skills-ci.yml/badge.svg)](https://github.com/ragnarok22/agent-skills/actions/workflows/skills-ci.yml)
![Skills](https://img.shields.io/badge/skills-4-blue)
![Platform](https://img.shields.io/badge/platform-Codex%20%7C%20Claude%20Code-blueviolet)

Single source of truth for custom Codex and Agent skills — reusable, versioned, and CI-validated.

## Available Skills

| Skill                                                          | Description                                                                                                   |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| [dependency-risk-audit](skills/dependency-risk-audit/)         | Review Python dependencies for security advisories, stale pins, and unsafe upgrade paths                      |
| [django-doctor](skills/django-doctor/)                         | Audit Django codebases for security, performance, correctness, and architecture antipatterns                  |
| [queryset-optimizer](skills/queryset-optimizer/)               | Optimize Django ORM performance by detecting N+1 query patterns, missing eager loading, and likely index gaps |
| [write-conventional-commit](skills/write-conventional-commit/) | Draft and apply commit messages that comply with Conventional Commits 1.0.0                                   |

## Quick Start

### Install a skill from this repo

```bash
npx skills add ragnarok22/agent-skills --skill django-doctor
```

### Django Doctor runtime behavior

The `django-doctor` skill supports multiple project execution styles and safe defaults:

- Uses a selected `<MANAGE_CMD>` command rather than assuming `uv` only.
- Accepts a user-provided runner first (for example Poetry, uv, plain Python, Pipenv, Docker wrappers).
- Auto-detects runners when possible (`poetry.lock`/`[tool.poetry]`, then `uv.lock`, then Python fallback).
- Requires explicit trust/approval before running any runtime Django checks.
- Falls back to static-only scanning when runtime execution is not approved.
- Produces sanitized findings and redacts secrets in report output.

### Create a new skill

```bash
mkdir -p skills/my-skill/agents
```

Then add the required files:

- `skills/my-skill/SKILL.md` — skill instructions (required)
- `skills/my-skill/agents/openai.yaml` — agent metadata (required)
- `skills/my-skill/scripts/` — automation scripts (optional)
- `skills/my-skill/references/` — reference material (optional)
- `skills/my-skill/assets/` — static assets (optional)

## Project Structure

```text
agent-skills/
  skills/
    <skill-name>/
      SKILL.md              # required
      agents/openai.yaml    # required
      scripts/              # optional
      references/           # optional
      assets/               # optional
```

### Naming Conventions

- Lowercase, hyphen-separated: `pricing-copy-audit`
- Short and action-oriented

## Commands

| Command                                                 | Purpose                        |
| ------------------------------------------------------- | ------------------------------ |
| `npx skills add`                                        | Add a skill to this repository |
| `npx skills add ragnarok22/agent-skills --skill <name>` | Install a skill from this repo |

## Contributing

1. Create your skill directory under `skills/`.
2. Ensure `SKILL.md` exists and is non-empty.
3. Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`).
4. CI validates skill structure automatically on push and PR.
