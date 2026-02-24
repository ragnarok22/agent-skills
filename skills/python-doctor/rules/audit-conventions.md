# Audit Conventions

- Run searches from the selected Python project root.
- Prefer `rg` for static checks. If unavailable, use `grep` equivalents.
- Exclude noise by default: `.git`, virtualenv directories, build outputs, generated files, and vendored code.
- Ignore `tests/`, `test/`, and fixtures by default unless a rule explicitly targets them.
- Every match starts as a **candidate**. Deduct score only after manual confirmation.
- Severity points: Critical `10`, High `7`, Medium `5`, Low `3`.
- For runtime checks (`COR-08`, `COR-09`), reuse `<PY_CMD>` selected in Step 2 of `SKILL.md`.
