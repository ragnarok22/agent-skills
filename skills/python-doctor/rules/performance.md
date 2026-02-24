# Performance Rules

## PERF-01: Blocking work inside async functions

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "async def |requests\.(get|post|put|delete)|time\.sleep\(|subprocess\.run\(|httpx\.Client\(" .`
**Confirm**: Blocking call executes inside an `async def` path. Sync `httpx.Client` used in async context is also a finding.
**Fix**: Replace with async-native APIs (`httpx.AsyncClient`, `asyncio.sleep`, async subprocess patterns).

## PERF-02: Missing timeout on HTTP requests

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "requests\.(get|post|put|delete|request)\(|httpx\.(get|post|put|delete)\(" .`
**Confirm**: Calls omit explicit `timeout=`.
**Fix**: Set bounded connect/read timeouts and centralize defaults.

## PERF-03: Repeated expensive calls inside loops

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "for .* in .*:|while .*:|requests\.|execute\(|query\(" .`
**Confirm**: Loop body performs avoidable network, database, or disk-heavy operation per iteration.
**Fix**: Batch operations, move invariant work outside loops, or cache results.

## PERF-04: Full-file reads where streaming is safer

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "\.read\(\)" .`
**Confirm**: Entire large files are read into memory in hot/request paths.
**Fix**: Stream in chunks or iterator-based readers.

## PERF-05: Eager list creation in aggregations

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' "sum\(\[|any\(\[|all\(\[" .`
**Confirm**: Temporary list allocations are avoidable in hot paths.
**Fix**: Use generator expressions.

## PERF-06: Regex compilation in hot loops

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' "re\.compile\(|for .* in .*:" .`
**Confirm**: Regex is compiled repeatedly inside iterative paths.
**Fix**: Precompile once at module scope or cache compiled patterns.

## PERF-07: String concatenation in loops

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "for .* in .*:" .`
**Confirm**: Loop body appends to a string using `+=` operator repeatedly. Building strings one piece at a time creates O(n^2) behavior.
**Fix**: Collect parts in a list and use `"".join(parts)` after the loop.

## PERF-08: Missing HTTP session reuse

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "requests\.(get|post|put|delete|head|patch)\(" .`
**Confirm**: Multiple `requests.get/post/...` calls are made to the same host without using a `requests.Session()` or connection pooling. Single one-off calls are false positives.
**Fix**: Create a `requests.Session()` (or `httpx.Client()`) and reuse it for multiple calls to the same host. This enables connection pooling and cookie persistence.

## PERF-09: Quadratic list membership checks

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "if .* in \[|if .* not in \[|for .* in .*:.*if .* in " .`
**Confirm**: Membership test (`in`) runs against a list or repeated list construction inside a loop. The list is large enough or the check frequent enough to matter.
**Fix**: Convert to a `set` or `frozenset` for O(1) membership checks.

## PERF-10: Unnecessary data copying

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' "list\(.*\.keys\(\)\)|list\(.*\.values\(\)\)|list\(.*\.items\(\)\)|list\(range\(" .`
**Confirm**: Code materializes an iterator/view into a list when only iteration is needed. Views and iterators already support iteration without the extra copy.
**Fix**: Iterate directly over dict views and `range()` without wrapping in `list()`.
