# Repository Guidelines

## Project Structure & Module Organization

This repository is a source-of-truth for local Codex/Agent skills.

- `skills/<skill-name>/`: one directory per skill.
- `skills/<skill-name>/SKILL.md`: required instructions for the skill.
- `skills/<skill-name>/agents/openai.yaml`: required agent metadata/config.
- `skills/<skill-name>/scripts/`, `references/`, `assets/`: optional supporting files.

Keep skill names lowercase and hyphenated (example: `pricing-copy-audit`).

## Build, Test, and Development Commands

- `npx skills add`: add skills to this repository via the skills CLI.
- `find skills -mindepth 1 -maxdepth 1 -type d -print | sort`: list skill directories under `skills/`.
- `find skills -type f -name '*.md' -size 0`: detect empty markdown files.

Run commands from the repository root.

## Coding Style & Naming Conventions

- Shell scripts should use Bash strict mode (`set -euo pipefail`) and clear variable names (`ROOT_DIR`, `SRC_DIR`, `TARGETS`).
- Prefer portable shell patterns and quote paths (`"$var"`).
- Use 2-space indentation in YAML and consistent indentation in Markdown lists.
- Skill folder names must be action-oriented, short, lowercase, and hyphen-separated.

## Testing Guidelines

There is no formal test suite yet. Before opening a PR:

- Run `find skills -mindepth 1 -maxdepth 1 -type d -print | sort` to confirm expected skill discovery.
- Ensure each skill contains `SKILL.md`.
- Run `find skills -type f -name '*.md' -size 0` and confirm it returns no files.

## Commit & Pull Request Guidelines

Use Conventional Commit style, as in existing history (`feat: add skills repository scaffolding and sync tooling`).

- Commit format: `type: concise summary` (`feat`, `fix`, `docs`, `chore`).
- PRs should include:
  - Purpose and scope.
  - Commands run for verification (with short output notes).
  - Any filesystem-impact notes (e.g., sync/import behavior changes).
  - Linked issue/task when applicable.
