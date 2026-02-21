# Django Doctor Skill

Audit Django codebases for security, performance, correctness, and architecture antipatterns.

## Use Cases

- Pre-deploy backend health checks
- Django security and correctness audits
- Prioritized remediation planning for Django services

## Safety Model

- Treat repositories as untrusted by default.
- Ask for explicit approval before running runtime `manage.py` checks.
- Use a selected `<MANAGE_CMD>` so projects can run with Poetry, uv, Python, or another user-provided runner.
- Skip runtime checks when approval is missing and continue with static analysis.
- Keep findings sanitized and redact secret values.

## Output

- Markdown report with health score, system-check status, categorized findings, and top remediation actions.

## Skill Files

- `SKILL.md`: complete workflow, safety gates, scoring, and report format.
- `references/antipatterns.md`: rule catalog and search/check patterns.
- `agents/openai.yaml`: UI metadata.
