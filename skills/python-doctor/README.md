# Python Doctor Skill

Audit Python codebases for security, performance, correctness, and architecture antipatterns.

## Use Cases

- Pre-release Python code health checks
- Backend security and correctness audits
- Prioritized remediation planning for Python services and libraries

## Safety Model

- Treat repositories as untrusted by default.
- Ask for explicit approval before running runtime commands.
- Use a selected `<PY_CMD>` so projects can run with Poetry, uv, Pipenv, or plain Python.
- Skip runtime checks when approval is missing and continue with static analysis.
- Keep findings sanitized and redact secret values.

## Output

- Markdown report with health score, runtime-check status, categorized findings, and top remediation actions.

## Skill Files

- `SKILL.md`: complete workflow, safety gates, scoring, and report format.
- `references/antipatterns.md`: rule catalog and search/check patterns.
- `agents/openai.yaml`: UI metadata.
