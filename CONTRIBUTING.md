# Contributing to agent-skills

Thanks for contributing. This repository is the source-of-truth for local
Codex/Agent skills, so consistency and validation are important.

## Before You Start

- Read `README.md` for project structure and commands.
- Follow our [Code of Conduct](CODE_OF_CONDUCT.md).
- For security vulnerabilities, use the private process in [Security Policy](SECURITY.md).

## Ways to Contribute

- Add a new skill under `skills/<skill-name>/`.
- Improve instructions, references, or metadata for an existing skill.
- Improve repository automation, docs, and consistency checks.

## Skill Requirements

Each skill directory must include:

- `skills/<skill-name>/SKILL.md`
- `skills/<skill-name>/agents/openai.yaml`

Recommended:

- `skills/<skill-name>/README.md`
- Optional support folders: `scripts/`, `references/`, `assets/`

Naming rules:

- Use lowercase, hyphen-separated, action-oriented names.
- Example: `pricing-copy-audit`

## Development Workflow

Run from repository root:

```bash
make lint
find skills -mindepth 1 -maxdepth 1 -type d -print | sort
find skills -type f -name '*.md' -size 0
```

Use this when needed:

```bash
make format
```

## Commit Guidelines

Use Conventional Commits:

- `feat: ...`
- `fix: ...`
- `docs: ...`
- `chore: ...`

Keep commits focused and descriptive.

## Pull Request Guidelines

- Explain purpose and scope clearly.
- List verification commands you ran and short output notes.
- Mention filesystem-impact changes when relevant.
- Link the related issue/task when applicable.
- Keep PRs small and single-purpose when possible.

## Reporting Issues

For non-security issues, open a GitHub issue and include:

- Summary of the problem
- Reproduction steps
- Expected behavior and actual behavior
- Relevant environment/context details

For security issues, do not open a public issue. Follow `SECURITY.md`.
