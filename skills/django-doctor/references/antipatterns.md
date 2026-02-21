# Django Antipattern Catalog

## Table of Contents

- [Audit Conventions](#audit-conventions)
- [Security](#security)
- [Performance](#performance)
- [Correctness](#correctness)
- [Architecture](#architecture)

---

## Audit Conventions

- Run searches from the Django backend root (where `manage.py` lives).
- Prefer `rg` for static checks. If unavailable, use `grep` equivalents.
- Exclude noise by default: `.git`, virtualenv directories, build outputs, and generated files.
- Ignore `tests/` and `migrations/` unless a rule explicitly targets them.
- Every match starts as a **candidate**. Deduct score only after manual confirmation.
- Severity points: Critical `10`, High `7`, Medium `5`, Low `3`.

---

## Security

### SEC-01: Hardcoded SECRET_KEY

**Severity**: Critical (10 pts)  
**Search**: `rg -n --glob '*.py' 'SECRET_KEY\s*=' config settings .`  
**Confirm**: Literal secret in shared/base/production settings, not an env lookup.  
**Fix**: Load from environment in deployable settings.

### SEC-02: DEBUG=True in deployable settings

**Severity**: Critical (10 pts)  
**Search**: `rg -n --glob '*.py' 'DEBUG\s*=\s*True' config settings .`  
**Confirm**: Value is active in production/deploy profile, not local-only settings.  
**Fix**: Set `DEBUG = False` for deployed environments.

### SEC-03: Raw SQL without parameterization

**Severity**: Critical (10 pts)  
**Search**: `rg -n --glob '*.py' '\.raw\(f"|\.raw\(".*%|\.raw\(".*\.format|cursor\.execute\(f"' apps .`  
**Confirm**: User-controlled values are interpolated into SQL.  
**Fix**: Use parameterized SQL arguments.

### SEC-04: Missing CSRF protection on state-changing endpoints

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' '@csrf_exempt' apps .`  
**Confirm**: Endpoint mutates state and is not an intentional public auth endpoint.  
**Fix**: Remove `@csrf_exempt` or add proper CSRF/session strategy.

### SEC-05: Exposed traces or raw exception messages

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'traceback\.print_exc|str\(e\)|repr\(e\)' apps .`  
**Confirm**: Response payload leaks internals to clients.  
**Fix**: Log server-side details and return generic client errors.

### SEC-06: Wildcard CORS or ALLOWED_HOSTS

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' 'CORS_ALLOW_ALL_ORIGINS\s*=\s*True|ALLOWED_HOSTS\s*=\s*\[[^]]*\*' config settings .`  
**Confirm**: Wildcards are enabled in deployable settings.  
**Fix**: Restrict to explicit origins/hosts.

### SEC-07: Missing authentication on protected endpoints

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' 'class .*?(APIView|ViewSet)' apps .`  
**Confirm**: Endpoint is not public but lacks auth requirements (`IsAuthenticated` or equivalent).  
**Fix**: Add explicit permission/authentication classes.

### SEC-08: Secrets committed in source

**Severity**: Critical (10 pts)  
**Search**: `rg -n --glob '*.py' "(password|api_key|token|secret)\s*=\s*['\"][^'\"]+['\"]" apps config settings .`  
**Confirm**: Hardcoded credential in non-test code.  
**Fix**: Move to env vars or a secrets manager.

---

## Performance

### PERF-01: Missing select_related/prefetch_related

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' 'select_related|prefetch_related|ForeignKey|ManyToManyField' apps .`  
**Confirm**: Related objects accessed in serializers/views/loops without eager loading.  
**Fix**: Add `select_related`/`prefetch_related` to querysets.

### PERF-02: Unbounded list endpoints

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' 'queryset\s*=|\.all\(\)|\.filter\(' apps .`  
**Confirm**: Collection endpoint returns unpaginated or unsliced results.  
**Fix**: Add DRF pagination or explicit limits.

### PERF-03: N+1 queries in loops

**Severity**: High (7 pts)  
**Search**: `rg -n --glob '*.py' 'for .* in .*:' apps .`  
**Confirm**: ORM relationship lookups happen inside iteration without prefetch.  
**Fix**: Restructure query or eager-load relations.

### PERF-04: Missing indexes for hot filters

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' '\.filter\(|db_index=True|indexes\s*=' apps .`  
**Confirm**: Frequently filtered/sorted fields lack DB index coverage.  
**Fix**: Add `db_index=True` or `Meta.indexes`.

### PERF-05: Loading unnecessary model fields

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' '\.only\(|\.values\(' apps .`  
**Confirm**: Large models fully loaded while response uses a narrow field subset.  
**Fix**: Use `.only()`/`.values()` when appropriate.

### PERF-06: Heavy synchronous work in request cycle

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'send_mail|requests\.(get|post|put|delete)|urlopen' apps .`  
**Confirm**: Costly I/O or compute executes inline on request path.  
**Fix**: Offload to background jobs or async workflow.

### PERF-07: Missing caching for low-churn reference data

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' 'cache\.get|cache\.set|objects\.(all|filter|get)\(' apps .`  
**Confirm**: Repeated reads of low-change reference tables with no cache layer.  
**Fix**: Add cache lookup/refresh policy.

---

## Correctness

### COR-01: Missing migrations

**Severity**: Critical (10 pts)  
**Check**: `uv run manage.py makemigrations --check --dry-run || python manage.py makemigrations --check --dry-run`  
**Confirm**: Command reports model drift.  
**Fix**: Generate and review migrations.

### COR-02: Missing model constraints for business rules

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'def validate|UniqueConstraint|CheckConstraint|constraints\s*=' apps .`  
**Confirm**: Rule enforced only in serializer/view logic, not DB constraints.  
**Fix**: Add appropriate model constraints.

### COR-03: Risky cascade deletes

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'on_delete\s*=\s*models\.CASCADE' apps .`  
**Confirm**: CASCADE used where reference integrity should be preserved.  
**Fix**: Prefer `PROTECT` or `SET_NULL` when ownership is not strict parent-child.

### COR-04: Timezone-naive datetime usage

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'datetime\.now\(\)|datetime\.utcnow\(\)' apps .`  
**Confirm**: Naive time used in persisted/business-critical logic.  
**Fix**: Use `django.utils.timezone.now()`.

### COR-05: Mutable default arguments

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'def .*\=\[\]|def .*\=\{\}' apps .`  
**Confirm**: Mutable default values in function signatures.  
**Fix**: Use `None` default, initialize inside function.

### COR-06: Silenced exceptions

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'except:\s*$|except Exception:\s*$' apps .`  
**Confirm**: Exception is swallowed (`pass`) or obscured without logging/handling.  
**Fix**: Catch specific exceptions and handle/log explicitly.

### COR-07: Inefficient or incorrect queryset evaluation

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' 'len\([^)]*queryset|if\s+[^:]*\.all\(\)|list\([^)]*queryset' apps .`  
**Confirm**: Uses eager/materializing patterns where `.count()`/`.exists()` is intended.  
**Fix**: Replace with queryset-native operations.

### COR-08: Django system check failures

**Severity**: Varies  
**Check**: `uv run manage.py check --deploy || python manage.py check --deploy`  
**Confirm**: Any warning/error relevant to target deployment mode.  
**Fix**: Resolve each warning or explicitly justify accepted risk.

---

## Architecture

### ARCH-01: Fat views with business logic

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'class .*?(APIView|ViewSet)|def (create|update|post|put|patch|get)\(' apps .`  
**Confirm**: Complex domain logic embedded in views.  
**Fix**: Extract business rules into `services.py` or domain layer.

### ARCH-02: Business logic in serializers

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*.py' 'class .*Serializer|def (validate|create|update)\(' apps .`  
**Confirm**: Non-serialization domain logic inside serializer methods.  
**Fix**: Move logic to services/use-case layer.

### ARCH-03: Cross-app model imports in `models.py`

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*/models.py' 'from apps\.[^.]+\.models import' apps .`  
**Confirm**: Cross-app imports create coupling/cycle risk.  
**Fix**: Use string model references or service boundaries.

### ARCH-04: Missing `@extend_schema` annotations

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' '@extend_schema|class .*?(APIView|ViewSet)' apps .`  
**Confirm**: Public API handlers lack schema metadata where project expects drf-spectacular docs.  
**Fix**: Add `@extend_schema` to documented endpoints.

### ARCH-05: Missing shared base model inheritance

**Severity**: Medium (5 pts)  
**Search**: `rg -n --glob '*/models.py' 'class .*\(.*models\.Model.*\)|UUIDModel|TimeStampedModel' apps .`  
**Confirm**: Project standard requires shared base models and a domain model skips them.  
**Fix**: Adopt required base model mixins where applicable.

### ARCH-06: Missing user scoping (multi-tenant leak risk)

**Severity**: Critical (10 pts)  
**Search**: `rg -n --glob '*.py' '\.objects\.(all|filter|get)\(' apps .`  
**Confirm**: User-owned data queried without `request.user` scoping (or equivalent tenant guard).  
**Fix**: Enforce tenant/user filtering in all user-scoped access paths.

### ARCH-07: Models missing admin registration

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*/models.py' '^class .*models\.Model' apps . && rg -n --glob '*/admin.py' '@admin\.register|admin\.site\.register' apps .`  
**Confirm**: Internal/admin-facing models expected in admin are not registered.  
**Fix**: Register models with sensible admin configuration.

### ARCH-08: Inconsistent API error envelope

**Severity**: Low (3 pts)  
**Search**: `rg -n --glob '*.py' 'Response\(\{[^}]*("error"|"detail")' apps .`  
**Confirm**: API mixes inconsistent error response contracts without explicit versioning.  
**Fix**: Standardize error shape and exception handling strategy.
