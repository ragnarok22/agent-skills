# agent-skills

[![Skills CI](https://github.com/ragnarok22/agent-skills/actions/workflows/skills-ci.yml/badge.svg)](https://github.com/ragnarok22/agent-skills/actions/workflows/skills-ci.yml)
![Skills](https://img.shields.io/badge/skills-6-blue)
![Platform](https://img.shields.io/badge/platform-Codex%20%7C%20Claude%20Code-blueviolet)
![License](https://img.shields.io/badge/license-MIT-green)

A curated collection of reusable skills for [Codex](https://openai.com/codex) and [Claude Code](https://docs.anthropic.com/en/docs/claude-code) agents. Each skill teaches your agent a specialized workflow -- auditing code, optimizing queries, writing commits, and more.

---

## Install a Skill

Pick any skill from the catalog below and install it with one command:

```bash
npx skills add ragnarok22/agent-skills --skill <skill-name>
```

For example:

```bash
npx skills add ragnarok22/agent-skills --skill django-doctor
```

That's it. The skill is now available in your agent.

---

## Skills Catalog

### Code Quality & Security

| Skill                                                  | What it does                                                                                                                                                    |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [python-doctor](skills/python-doctor/)                 | Audits Python projects for security holes, performance issues, and antipatterns. Runs syntax checks, ruff, mypy, and pytest, then outputs a 0-100 health score. |
| [django-doctor](skills/django-doctor/)                 | Audits Django projects end-to-end: `manage.py check --deploy`, migration issues, and static rule scans against a catalog of known antipatterns.                 |
| [dependency-risk-audit](skills/dependency-risk-audit/) | Scans `poetry.lock`, `uv.lock`, `Pipfile.lock`, or `requirements.txt` for CVEs, stale pins, and risky upgrades.                                                 |

### Infrastructure

| Skill                                  | What it does                                                                                                                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| [docker-doctor](skills/docker-doctor/) | Validates Dockerfiles and Compose manifests for security, reliability, and optimization issues using built-in checks and optional Hadolint. |

### Performance

| Skill                                            | What it does                                                                                                                                     |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| [queryset-optimizer](skills/queryset-optimizer/) | Detects N+1 queries, missing `select_related`/`prefetch_related`, and likely index gaps in Django ORM code. Suggests fixes with expected impact. |

### Workflow

| Skill                                                          | What it does                                                                                                                                               |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [write-conventional-commit](skills/write-conventional-commit/) | Drafts and applies commit messages following the [Conventional Commits 1.0.0](https://www.conventionalcommits.org/) spec. Can execute the commit directly. |

---

## Create a New Skill

Want to add your own skill? Here's how.

### 1. Scaffold it

```bash
make create my-new-skill
```

This generates the required file structure:

```
skills/my-new-skill/
  SKILL.md              # Workflow instructions (required)
  agents/openai.yaml    # Agent metadata (required)
  README.md             # Human-facing docs (recommended)
```

### 2. Write the skill

**`SKILL.md`** is the core of every skill. It tells the agent exactly what to do. A good SKILL.md includes:

- **Purpose** -- what the skill audits, generates, or optimizes
- **Workflow steps** -- numbered, concrete steps the agent should follow
- **Scoring** -- how to measure results (e.g., 0-100 health score)
- **Output format** -- the expected markdown report structure
- **Safety gates** -- what the agent should never do without approval

Look at any existing skill for reference (e.g., [`skills/python-doctor/SKILL.md`](skills/python-doctor/SKILL.md)).

**`agents/openai.yaml`** contains the skill's display name and description:

```yaml
name: my-new-skill
description: One-line description of what the skill does
```

### 3. Add supporting files (optional)

| Directory     | Purpose                                          |
| ------------- | ------------------------------------------------ |
| `references/` | Rule catalogs, spec documents, antipattern lists |
| `scripts/`    | Shell scripts the agent can execute              |
| `assets/`     | Static files, templates, or fixtures             |

### 4. Validate

```bash
make lint
```

This checks that your skill folder follows naming conventions, has the required files, and has no empty markdown files.

### 5. Submit a PR

```bash
git add skills/my-new-skill/
git commit -m "feat(my-new-skill): add skill for XYZ"
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for full PR guidelines.

---

## Naming Rules

Skill folder names must be:

- **Lowercase** and **hyphen-separated**
- **Action-oriented** -- describe what the skill does

Good: `django-doctor`, `dependency-risk-audit`, `write-conventional-commit`
Bad: `DjangoDoctor`, `django_doctor`, `misc-utils`

---

## Repository Layout

```
agent-skills/
  Makefile                  # create, lint, format commands
  skills/
    <skill-name>/
      SKILL.md              # required -- agent workflow
      agents/openai.yaml    # required -- agent metadata
      README.md             # recommended -- human docs
      scripts/              # optional -- executable scripts
      references/           # optional -- rule catalogs
      assets/               # optional -- static files
```

---

## Available Commands

| Command              | What it does                                            |
| -------------------- | ------------------------------------------------------- |
| `make create <name>` | Scaffold a new skill with all required files            |
| `make lint`          | Validate naming, required files, and non-empty markdown |
| `make format`        | Format all Markdown and YAML with Prettier              |
| `make help`          | List all available commands                             |

---

## Contributing

We welcome contributions! You can:

- **Add a new skill** -- follow the steps above
- **Improve an existing skill** -- fix instructions, add references, expand coverage
- **Improve repo tooling** -- better linting, new automation, docs

Read [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow. We use [Conventional Commits](https://www.conventionalcommits.org/) for all commit messages.

---

## Links

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)
- [MIT License](LICENSE)
