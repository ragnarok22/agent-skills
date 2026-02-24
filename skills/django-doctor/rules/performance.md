# Performance Rules

## PERF-01: Missing select_related/prefetch_related

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'select_related|prefetch_related|ForeignKey|ManyToManyField' apps .`
**Confirm**: Related objects accessed in serializers/views/loops without eager loading. Focus on queryset construction in views, serializers, and services — model field definitions alone are not findings.
**Fix**: Add `select_related`/`prefetch_related` to querysets.

## PERF-02: Unbounded list endpoints

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'queryset\s*=|\.all\(\)|\.filter\(' apps .`
**Confirm**: Collection endpoint returns unpaginated or unsliced results.
**Fix**: Add DRF pagination or explicit limits.

## PERF-03: N+1 queries in loops

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'for .* in .*:' apps .`
**Confirm**: ORM relationship lookups happen inside iteration without prefetch.
**Fix**: Restructure query or eager-load relations.

## PERF-04: Missing indexes for hot filters

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' '\.filter\(|db_index=True|indexes\s*=' apps .`
**Confirm**: Frequently filtered/sorted fields lack DB index coverage.
**Fix**: Add `db_index=True` or `Meta.indexes`.

## PERF-05: Loading unnecessary model fields

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' '\.only\(|\.values\(' apps .`
**Confirm**: Large models fully loaded while response uses a narrow field subset.
**Fix**: Use `.only()`/`.values()` when appropriate.

## PERF-06: Heavy synchronous work in request cycle

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'send_mail|requests\.(get|post|put|delete)|urlopen' apps .`
**Confirm**: Costly I/O or compute executes inline on request path.
**Fix**: Offload to background jobs or async workflow.

## PERF-07: Missing caching for low-churn reference data

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' 'cache\.get|cache\.set|objects\.(all|filter|get)\(' apps .`
**Confirm**: Repeated reads of low-change reference tables with no cache layer.
**Fix**: Add cache lookup/refresh policy.

## PERF-08: Per-row writes instead of bulk operations

**Severity**: Medium (5 pts)
**Search**: `rg -nU --glob '*.py' 'for .* in .*:\n(?:\s+.*\n){0,8}\s+.*\.(save|create)\(' apps .`
**Confirm**: Loop body calls `.save()` or `.create()` per iteration and no per-row side effect (signals, pre-save hooks) requires individual saves.
**Fix**: Use `bulk_create()`, `bulk_update()`, or `QuerySet.update()` for batch operations. Call signals explicitly after bulk write if needed.

## PERF-09: Using `.count()` where `.exists()` suffices

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' 'if .*\.count\(\)\s*[><=!]' apps .`
**Confirm**: Code checks `queryset.count() > 0`, `count() == 0`, or similar boolean-intended comparisons where `.exists()` or `not .exists()` would suffice.
**Fix**: Replace `qs.count() > 0` with `qs.exists()` and `qs.count() == 0` with `not qs.exists()`.

## PERF-10: Heavy synchronous work in Django signals

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' '@receiver\(|\.connect\(' apps .`
**Confirm**: Signal handler body contains expensive operations: HTTP requests (`requests.`, `httpx.`), email sending (`send_mail`, `EmailMessage`), file I/O, or external API calls. Lightweight handlers (cache invalidation, field updates) are false positives.
**Fix**: Offload heavy work in signal handlers to Celery tasks, Django-Q jobs, or async queues. Alternatively, replace signals with explicit service calls.

## PERF-11: QuerySet evaluated multiple times

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' '\.all\(\)|\.filter\(' apps .`
**Confirm**: The same queryset expression is evaluated more than once in a function (e.g., iterated in a for loop and then passed to `.count()` or `len()`). Single evaluation or intentional re-query is a false positive.
**Fix**: Evaluate the queryset once into a list/variable and reuse the result, or restructure to avoid multiple evaluations.
