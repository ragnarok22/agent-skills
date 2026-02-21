# Python Antipattern Catalog

## Table of Contents

- [Audit Conventions](#audit-conventions)
- [Security](#security)
- [Performance](#performance)
- [Correctness](#correctness)
- [Architecture](#architecture)

---

## Audit Conventions

- Run searches from the selected Python project root.
- Prefer `rg` for static checks. If unavailable, use `grep` equivalents.
- Exclude noise by default: `.git`, virtualenv directories, build outputs, generated files, and vendored code.
- Ignore `tests/`, `test/`, and fixtures by default unless a rule explicitly targets them.
- Every match starts as a **candidate**. Deduct score only after manual confirmation.
- Severity points: Critical `10`, High `7`, Medium `5`, Low `3`.
- For runtime checks (`COR-08`, `COR-09`), reuse `<PY_CMD>` selected in Step 2 of `SKILL.md`.

---

## Security

### SEC-01: Hardcoded credentials in source

**Severity**: Critical (10 pts)  
**Search**: `rg -n --glob '*.py' "(password|passwd|api[_-]?key|token|secret)\s*=\s*['\"][^'\"]+['\"]" .`  
**Confirm**: Literal secret appears in non-test code and is not a documented placeholder.  
**Fix**: Load from environment variables or a secrets manager.

### SEC-02: Shell execution with injection risk

**Severity**: Critical (10 pts)  
**Search**: `rg -n --glob '*.py' "subprocess\.(run|Popen|call|check_call|check_output)\(.*shell\s*=\s*True|os\.system\(" .`  
**Confirm**: Command string can include user-controlled input or unsanitized variables.  
**Fix**: Use argument lists, `shell=False`, and strict input validation.

### SEC-03: Unsafe deserialization

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' "pickle\.loads|yaml\.load\(" .`  
**Confirm**: Untrusted input can reach deserialization path.  
**Fix**: Use safe formats and loaders (for example `yaml.safe_load`) and validate schema.

### SEC-04: Dynamic code execution

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' "\beval\(|\bexec\(" .`  
**Confirm**: Execution path can process untrusted or weakly validated input.  
**Fix**: Replace with explicit parsers, whitelisted operations, or dispatch maps.

### SEC-05: TLS verification disabled

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' "verify\s*=\s*False|ssl\._create_unverified_context|urllib3\.disable_warnings" .`  
**Confirm**: Network calls disable certificate verification outside strictly local dev-only code.  
**Fix**: Enforce TLS verification and remove certificate warning suppression.

### SEC-06: Insecure temporary file creation

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "tempfile\.mktemp\(" .`  
**Confirm**: Temporary paths are created via `mktemp` and later opened/written.  
**Fix**: Use `NamedTemporaryFile` or `mkstemp` patterns.

### SEC-07: Weak randomness in security context

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "random\.(random|randint|randrange|choice|choices)" .`  
**Confirm**: `random` module is used for tokens, password reset codes, IDs, or auth-sensitive values.  
**Fix**: Use `secrets` module or cryptographically secure token generation.

---

## Performance

### PERF-01: Blocking work inside async functions

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' "async def |requests\.(get|post|put|delete)|time\.sleep\(|subprocess\.run\(" .`  
**Confirm**: Blocking call executes inside an `async def` path.  
**Fix**: Replace with async-native APIs (`httpx.AsyncClient`, `asyncio.sleep`, async subprocess patterns).

### PERF-02: Missing timeout on HTTP requests

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' "requests\.(get|post|put|delete|request)\(" .`  
**Confirm**: Calls omit explicit `timeout=`.  
**Fix**: Set bounded connect/read timeouts and centralize defaults.

### PERF-03: Repeated expensive calls inside loops

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "for .* in .*:|while .*:|requests\.|execute\(|query\(" .`  
**Confirm**: Loop body performs avoidable network, database, or disk-heavy operation per iteration.  
**Fix**: Batch operations, move invariant work outside loops, or cache results.

### PERF-04: Full-file reads where streaming is safer

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "\.read\(\)" .`  
**Confirm**: Entire large files are read into memory in hot/request paths.  
**Fix**: Stream in chunks or iterator-based readers.

### PERF-05: Eager list creation in aggregations

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' "sum\(\[|any\(\[|all\(\[" .`  
**Confirm**: Temporary list allocations are avoidable in hot paths.  
**Fix**: Use generator expressions.

### PERF-06: Regex compilation in hot loops

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' "re\.compile\(|for .* in .*:" .`  
**Confirm**: Regex is compiled repeatedly inside iterative paths.  
**Fix**: Precompile once at module scope or cache compiled patterns.

---

## Correctness

### COR-01: Mutable default arguments

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "def .*\=\[\]|def .*\=\{\}" .`  
**Confirm**: Function signature uses mutable defaults.  
**Fix**: Use `None` and initialize inside the function.

### COR-02: Bare `except`

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' "except:\s*$" .`  
**Confirm**: Bare exception handler swallows non-local errors or system interrupts.  
**Fix**: Catch specific exceptions and handle/log explicitly.

### COR-03: Overly broad `except Exception` with weak handling

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "except Exception:\s*$|except Exception as .*:\s*$" .`  
**Confirm**: Handler masks root causes (`pass`, silent fallback, or ambiguous response).  
**Fix**: Narrow exception scope and include context-aware handling.

### COR-04: Naive datetime usage

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "datetime\.now\(\)|datetime\.utcnow\(\)" .`  
**Confirm**: Naive timestamps are persisted, compared, or serialized for business logic.  
**Fix**: Use timezone-aware timestamps (`datetime.now(timezone.utc)` or framework equivalent).

### COR-05: `assert` used for runtime validation

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "^\s*assert\s+" .`  
**Confirm**: Assertions enforce runtime validation in production paths (not tests).  
**Fix**: Replace with explicit validation and raised exceptions.

### COR-06: Comparing to `None` with equality operators

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' "==\s*None|!=\s*None" .`  
**Confirm**: Equality comparisons used instead of identity checks.  
**Fix**: Use `is None` / `is not None`.

### COR-07: Mutable class attributes as shared state

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "^\s+[A-Za-z_][A-Za-z0-9_]*\s*=\s*(\[\]|\{\}|set\(\))" .`  
**Confirm**: Mutable attribute is declared on class and unintentionally shared across instances.  
**Fix**: Initialize mutable state in `__init__`.

### COR-08: Python syntax check failures

**Severity**: Critical (10 pts)  
**Check**: `<PY_CMD> -m compileall -q .`  
**Confirm**: Compilation reports syntax/import-level failures in project modules.  
**Fix**: Resolve syntax errors and re-run check.

### COR-09: Test suite failures

**Severity**: Varies  
**Check**: `<PY_CMD> -m pytest -q`  
**Confirm**: Failures reproduce and are relevant to audited scope.  
**Fix**: Fix failing tests, stabilize flaky tests, or document known quarantined failures.

---

## Architecture

### ARCH-01: Wildcard imports

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "from .* import \*" .`  
**Confirm**: Wildcard import is used outside controlled module export patterns.  
**Fix**: Import explicit symbols.

### ARCH-02: Deep relative imports

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' "from \\.{2,}" .`  
**Confirm**: Excessive relative imports indicate fragile package boundaries.  
**Fix**: Prefer absolute imports from stable module roots.

### ARCH-03: Import-time side effects

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "requests\.|open\(|connect\(|create_engine\(" .`  
**Confirm**: Network/file/database side effects execute at module import time.  
**Fix**: Move side effects to explicit startup or runtime functions.

### ARCH-04: Oversized modules

**Severity**: Medium (5 pts)  
**Search**: `find . -name '*.py' -not -path '*/tests/*' -not -path '*/.venv/*' -print0 | xargs -0 wc -l | sort -nr | head`  
**Confirm**: Large modules (for example 500+ lines) contain multiple unrelated responsibilities.  
**Fix**: Split into cohesive modules with clear ownership.

### ARCH-05: Global mutable state

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' "^\s*[A-Z_][A-Z0-9_]*\s*=\s*(\[\]|\{\}|set\(\))|^\s*global\s+" .`  
**Confirm**: Shared mutable globals affect behavior across requests or threads.  
**Fix**: Replace with immutable config, dependency injection, or stateful objects with controlled lifecycle.

### ARCH-06: Logging and error policy inconsistency

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' "print\(|logging\.(debug|info|warning|error|exception)\(" .`  
**Confirm**: Project mixes ad-hoc `print` diagnostics with inconsistent structured logging/error handling.  
**Fix**: Standardize logging interface and error envelope per project conventions.
