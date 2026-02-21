# Dependency Risk Audit Skill

Audit Python dependencies for security advisories, stale pins, and unsafe upgrade paths.

## Use Cases

- Dependency security reviews
- Requirements or lockfile audits
- Upgrade planning and remediation prioritization

## Inputs

- `poetry.lock` + `pyproject.toml`
- `uv.lock` + `pyproject.toml`
- `Pipfile.lock` + `Pipfile`
- `requirements*.txt` and optional `constraints*.txt`

## Output

- Markdown report with executive summary, advisories, stale pins, upgrade path risks, and prioritized remediation actions.
- Optional 0-100 score when requested.

## Skill Files

- `SKILL.md`: complete workflow and scoring rules.
- `agents/openai.yaml`: UI metadata.
