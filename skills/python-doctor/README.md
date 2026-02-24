# Python Doctor Skill

Audit Python codebases for security, performance, correctness, and architecture antipatterns.

## Use Cases

- Pre-release Python code health checks
- Backend security audits (injection, deserialization, path traversal, XXE, credential leaks)
- Performance review (async blocking, timeout hygiene, connection pooling, quadratic patterns)
- Correctness verification (exception handling, dead code, shadowed builtins, type safety)
- Architecture assessment (circular imports, god classes, dependency pinning, unused imports)
- Prioritized remediation planning for Python services and libraries

## Rule Coverage

49 rules across four categories:

- **Security (13)**: Hardcoded credentials, shell injection, deserialization, eval/exec, TLS, temp files, weak randomness, SQL injection, interface binding, path traversal, weak hashing, sensitive logging, XXE
- **Performance (10)**: Async blocking, missing timeouts, loop-heavy I/O, streaming, eager lists, regex caching, string concat, session reuse, membership checks, data copying
- **Correctness (14)**: Mutable defaults, bare except, broad except, naive datetime, assert misuse, None comparison, mutable class attrs, syntax checks, test failures, super init, identity vs equality, dead code, pointless f-strings, shadowed builtins
- **Architecture (12)**: Wildcard imports, deep relative imports, import-time side effects, oversized modules, global mutable state, logging policy, circular imports, sync/async mixing, unpinned deps, god classes, missing init, unused imports

## Safety Model

- Treat repositories as untrusted by default.
- Ask for explicit approval before running runtime commands.
- Use a selected `<PY_CMD>` so projects can run with Poetry, uv, Pipenv, or plain Python.
- Skip runtime checks when approval is missing and continue with static analysis.
- Keep findings sanitized and redact secret values.

## Output

- Markdown report with health score, runtime-check status, categorized findings, and top remediation actions.

## Skill Files

- `SKILL.md`: complete workflow, rules index, safety gates, scoring, and report format.
- `rules/`: individual rule files organized by category.
- `references/antipatterns.md`: index pointing to rule files.
- `agents/openai.yaml`: UI metadata.
