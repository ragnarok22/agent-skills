# Django Doctor Skill

Audit Django codebases for security, performance, correctness, and architecture antipatterns.

## Use Cases

- Pre-deploy backend health checks
- Django security and correctness audits (XSS, CSRF, SQL injection, file uploads, mass assignment)
- Transaction safety and migration drift detection
- Deprecated API and upgrade-readiness checks
- Prioritized remediation planning for Django services

## Rule Coverage

53 rules across four categories:

- **Security (14)**: SECRET_KEY, DEBUG, SQL injection, CSRF, CORS, secrets, security middleware, XSS, file uploads, rate limiting, mass assignment
- **Performance (11)**: N+1 queries, unbounded endpoints, missing indexes, caching, bulk operations, signal overhead, queryset evaluation
- **Correctness (14)**: Migration drift, constraints, cascades, timezone, exceptions, transactions, DoesNotExist, deprecated APIs, settings split, signal signatures
- **Architecture (14)**: Fat views, serializer logic, cross-app coupling, schema annotations, base models, tenant scoping, admin registration, error envelopes, circular imports, URL namespacing, signals as business logic, AppConfig, god models, custom managers

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
