# Correctness Rules

## COR-01: Mutable default arguments

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "def .*\=\[\]|def .*\=\{\}" .`
**Confirm**: Function signature uses mutable defaults.
**Fix**: Use `None` and initialize inside the function.

## COR-02: Bare `except`

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "except:\s*$|except:\s*pass|except:\s*\.\.\." .`
**Confirm**: Bare exception handler swallows non-local errors or system interrupts.
**Fix**: Catch specific exceptions and handle/log explicitly.

## COR-03: Overly broad `except Exception` with weak handling

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "except Exception:\s*$|except Exception as .*:\s*$|except Exception:\s*pass|except Exception as .*:\s*pass" .`
**Confirm**: Handler masks root causes (`pass`, silent fallback, or ambiguous response).
**Fix**: Narrow exception scope and include context-aware handling.

## COR-04: Naive datetime usage

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "datetime\.now\(\)|datetime\.utcnow\(\)" .`
**Confirm**: Naive timestamps are persisted, compared, or serialized for business logic.
**Fix**: Use timezone-aware timestamps (`datetime.now(timezone.utc)` or framework equivalent).

## COR-05: `assert` used for runtime validation

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "^\s*assert\s+" .`
**Confirm**: Assertions enforce runtime validation in production paths (not tests).
**Fix**: Replace with explicit validation and raised exceptions.

## COR-06: Comparing to `None` with equality operators

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' "==\s*None|!=\s*None" .`
**Confirm**: Equality comparisons used instead of identity checks.
**Fix**: Use `is None` / `is not None`.

## COR-07: Mutable class attributes as shared state

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "^\s+[A-Za-z_][A-Za-z0-9_]*\s*=\s*(\[\]|\{\}|set\(\))" .`
**Confirm**: Mutable attribute is declared on class and unintentionally shared across instances.
**Fix**: Initialize mutable state in `__init__`.

## COR-08: Python syntax check failures

**Severity**: Critical (10 pts)
**Check**: `<PY_CMD> -m compileall -q .`
**Confirm**: Compilation reports syntax/import-level failures in project modules.
**Fix**: Resolve syntax errors and re-run check.

## COR-09: Test suite failures

**Severity**: Varies
**Check**: `<PY_CMD> -m pytest -q`
**Confirm**: Failures reproduce and are relevant to audited scope.
**Fix**: Fix failing tests, stabilize flaky tests, or document known quarantined failures.

## COR-10: Missing `super().__init__()` calls

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "def __init__\(self" .`
**Confirm**: A subclass defines `__init__` but does not call `super().__init__()` (or parent `__init__`), and the parent class has initialization logic that would be skipped. Classes inheriting only from `object` with no parent init logic are false positives.
**Fix**: Add `super().__init__(*args, **kwargs)` at the start of the child `__init__` method.

## COR-11: `is` used for value comparison

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "\bis\s+(-?\d+|['\"]|True|False(?!\s*[,\)]))" .`
**Confirm**: Identity operator `is` used to compare integer values, strings, or booleans other than `None`, `True`, `False` singletons. Comparisons to `None` are correct and should be excluded. Note: `is True` / `is False` are intentional in some testing contexts; flag only when equality semantics are intended.
**Fix**: Use `==` / `!=` for value comparison. Reserve `is` for `None` checks and singleton identity.

## COR-12: Unreachable code after return/raise/break

**Severity**: Low (3 pts)
**Search**: `rg -nU --glob '*.py' "(return|raise|break|continue)\s.*\n\s+((?!def |class |#|@|except|elif|else|finally|if ).)" .`
**Confirm**: Code follows an unconditional `return`, `raise`, `break`, or `continue` at the same indentation level and cannot be reached. Guard clauses with early returns followed by the main logic are false positives.
**Fix**: Remove dead code or restructure control flow.

## COR-13: f-string without interpolation

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' 'f"[^{]*"|f'"'"'[^{]*'"'"'' .`
**Confirm**: f-string prefix is used but the string contains no `{expression}` placeholders.
**Fix**: Remove the `f` prefix to use a regular string literal.

## COR-14: Shadowing built-in names

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "^(def|class)\s+(id|type|list|dict|set|map|filter|input|open|range|print|format|hash|len|min|max|sum|any|all|next|iter|zip|int|str|float|bool|bytes|tuple|object|dir|vars)\b" .`
**Confirm**: A function or class definition shadows a Python built-in name at module scope. Local variable shadows inside functions are lower risk and generally excluded.
**Fix**: Rename the function or class to avoid shadowing. Use domain-specific names (e.g., `user_id` instead of `id`, `item_list` instead of `list`).
