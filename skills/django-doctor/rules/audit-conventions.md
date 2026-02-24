# Audit Conventions

- Run searches from the Django backend root (where `manage.py` lives).
- Prefer `rg` for static checks. If unavailable, use `grep` equivalents.
- Exclude noise by default: `.git`, virtualenv directories, build outputs, and generated files.
- Ignore `tests/` and `migrations/` unless a rule explicitly targets them.
- Every match starts as a **candidate**. Deduct score only after manual confirmation.
- Severity points: Critical `10`, High `7`, Medium `5`, Low `3`.
- For runtime checks (`COR-01`, `COR-08`), reuse `<MANAGE_CMD>` selected in Step 2 of `SKILL.md`.
