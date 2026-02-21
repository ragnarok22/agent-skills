# Repository Guidelines

## Project Structure & Module Organization
This repository is a source-of-truth for local Codex/Agent skills.

- `skills/<skill-name>/`: one directory per skill.
- `skills/<skill-name>/SKILL.md`: required instructions for the skill.
- `skills/<skill-name>/agents/openai.yaml`: required agent metadata/config.
- `skills/<skill-name>/scripts/`, `references/`, `assets/`: optional supporting files.
- `tools/`: Bash utilities for syncing/importing skills.
- `Makefile`: task entry points (`list`, `import`, `sync`).

Keep skill names lowercase and hyphenated (example: `pricing-copy-audit`).

## Build, Test, and Development Commands
- `make list`: lists skill directories under `skills/`.
- `make import`: imports skills from `~/.agents/skills` and `~/.codex/skills` into this repo.
- `make sync`: copies repo skills to both local targets above.
- `bash -n tools/*.sh`: quick syntax check for shell scripts.

Run commands from the repository root.

## Coding Style & Naming Conventions
- Shell scripts should use Bash strict mode (`set -euo pipefail`) and clear variable names (`ROOT_DIR`, `SRC_DIR`, `TARGETS`).
- Prefer portable shell patterns and quote paths (`"$var"`).
- Use 2-space indentation in YAML and consistent indentation in Markdown lists.
- Skill folder names must be action-oriented, short, lowercase, and hyphen-separated.

## Testing Guidelines
There is no formal test suite yet. Before opening a PR:

- Run `make list` to confirm expected skill discovery.
- Run `make sync` and verify skills appear in both target directories.
- For script changes, run `bash -n tools/*.sh` and exercise the updated path manually.

## Commit & Pull Request Guidelines
Use Conventional Commit style, as in existing history (`feat: add skills repository scaffolding and sync tooling`).

- Commit format: `type: concise summary` (`feat`, `fix`, `docs`, `chore`).
- PRs should include:
  - Purpose and scope.
  - Commands run for verification (with short output notes).
  - Any filesystem-impact notes (e.g., sync/import behavior changes).
  - Linked issue/task when applicable.
