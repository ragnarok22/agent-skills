# Django Antipattern Catalog

## Table of Contents

- [Security](#security)
- [Performance](#performance)
- [Correctness](#correctness)
- [Architecture](#architecture)

---

## Security

### SEC-01: Hardcoded SECRET_KEY

**Severity**: Critical (10 pts)
**Pattern**: `SECRET_KEY = "..."` in base settings (not loaded from env)
**Search**: `grep -n "SECRET_KEY\s*=" config/settings/base.py config/settings/production.py`
**Fix**: Use `os.environ` or `get_env_variable()` in production settings. A hardcoded fallback in `development.py` only is acceptable.

### SEC-02: DEBUG=True in production settings

**Severity**: Critical (10 pts)
**Pattern**: `DEBUG = True` in `config/settings/production.py`
**Search**: `grep -n "DEBUG\s*=\s*True" config/settings/production.py`
**Fix**: Set `DEBUG = False` in production settings.

### SEC-03: Raw SQL without parameterization

**Severity**: Critical (10 pts)
**Pattern**: `.raw(f"...")`, `.raw("..." % ...)`, `.raw("...".format(...))`, `cursor.execute(f"...")`
**Search**: `grep -rn "\.raw\(f\"\|\.raw(\".*%\|\.raw(\".*\.format\|cursor\.execute(f\"" apps/`
**Fix**: Use parameterized queries: `.raw("SELECT ... WHERE id = %s", [user_id])`.

### SEC-04: Missing CSRF protection on state-changing views

**Severity**: High (7 pts)
**Pattern**: `@csrf_exempt` on views that are NOT public auth endpoints (login/register)
**Search**: `grep -rn "csrf_exempt" apps/`
**Fix**: Remove `@csrf_exempt` from non-auth views. Only login/register endpoints should be exempt for frontend integration.

### SEC-05: Exposed stack traces or verbose error responses

**Severity**: Medium (5 pts)
**Pattern**: `traceback.print_exc()`, `import traceback` in views, returning `str(e)` in API responses
**Search**: `grep -rn "traceback\|str(e)\|repr(e)" apps/*/views.py`
**Fix**: Log errors server-side, return generic error messages to clients.

### SEC-06: Wildcard CORS or ALLOWED_HOSTS

**Severity**: High (7 pts)
**Pattern**: `CORS_ALLOW_ALL_ORIGINS = True` or `ALLOWED_HOSTS = ["*"]` in production settings
**Search**: `grep -n "ALLOW_ALL_ORIGINS\|ALLOWED_HOSTS.*\*" config/settings/production.py`
**Fix**: Explicitly list allowed origins and hosts.

### SEC-07: Missing authentication on views

**Severity**: High (7 pts)
**Pattern**: APIView/ViewSet without `permission_classes = [IsAuthenticated]` (excluding public endpoints)
**Search**: Scan all views for missing `permission_classes` or `AllowAny` on non-auth endpoints.
**Fix**: Add `permission_classes = [IsAuthenticated]` to all non-public views.

### SEC-08: Password or secret in source code

**Severity**: Critical (10 pts)
**Pattern**: `password = "..."`, `api_key = "..."`, `token = "..."` hardcoded (not in tests)
**Search**: `grep -rn "password\s*=\s*\"\|api_key\s*=\s*\"\|token\s*=\s*\"\|secret\s*=\s*\"" apps/ config/ --include="*.py" | grep -v test`
**Fix**: Move secrets to environment variables.

---

## Performance

### PERF-01: Missing select_related / prefetch_related

**Severity**: High (7 pts)
**Pattern**: QuerySet accessing FK/M2M fields in serializers or loops without `.select_related()` / `.prefetch_related()`
**Search**: Look for `ForeignKey` / `ManyToManyField` references in serializers whose views don't use `select_related`/`prefetch_related`.
**Fix**: Add `.select_related("fk_field")` or `.prefetch_related("m2m_field")` to the queryset.

### PERF-02: Unbounded queryset (missing pagination or limit)

**Severity**: High (7 pts)
**Pattern**: `.all()` or `.filter(...)` returned directly in list views without pagination
**Search**: Views returning `Model.objects.filter(...)` or `.all()` without pagination_class or slicing.
**Fix**: Add `pagination_class` to ViewSets or manually paginate in APIViews.

### PERF-03: Queries inside loops (N+1)

**Severity**: High (7 pts)
**Pattern**: ORM calls inside `for` loops: `for obj in qs: obj.related.field`
**Search**: Look for queryset iteration followed by FK/related access without prefetch.
**Fix**: Use `select_related` / `prefetch_related` before iteration, or restructure query.

### PERF-04: Missing database indexes

**Severity**: Medium (5 pts)
**Pattern**: Frequently filtered fields (e.g., `user`, `is_archived`, `created_at`) without `db_index=True` or `Meta.indexes`
**Search**: Cross-reference filter fields in views/managers with model field definitions.
**Fix**: Add `db_index=True` to the field or add to `Meta.indexes`.

### PERF-05: Unnecessary model field loading

**Severity**: Low (3 pts)
**Pattern**: Loading all fields when only a few are needed, especially in list views
**Search**: Views that select all fields but only serialize a subset.
**Fix**: Use `.only()` or `.values()` for large models when only a few fields are needed.

### PERF-06: Expensive operations in request cycle

**Severity**: Medium (5 pts)
**Pattern**: Sending emails, calling external APIs, heavy computation inside view methods synchronously
**Search**: `grep -rn "send_mail\|requests\.get\|requests\.post\|urlopen" apps/*/views.py`
**Fix**: Offload to background tasks (Celery, Django-Q, etc.) or use async views.

### PERF-07: Cache not used for rarely-changing data

**Severity**: Low (3 pts)
**Pattern**: Repeated DB queries for data that changes infrequently (currencies, settings, categories)
**Search**: Look for queries on lookup/reference tables without caching.
**Fix**: Use Django's cache framework (`cache.get`/`cache.set`) or model-level caching (like the CurrencyQuerySet pattern).

---

## Correctness

### COR-01: Missing migrations

**Severity**: Critical (10 pts)
**Pattern**: Model changes without corresponding migration files
**Check**: Run `uv run manage.py makemigrations --check --dry-run`
**Fix**: Run `uv run manage.py makemigrations`.

### COR-02: Missing model constraints

**Severity**: Medium (5 pts)
**Pattern**: Business rules enforced only in serializers/views but not at DB level
**Search**: Look for validation logic in serializers that should also be `CheckConstraint` or `UniqueConstraint` on the model.
**Fix**: Add `Meta.constraints` to models to enforce rules at DB level.

### COR-03: Unprotected foreign key deletion

**Severity**: Medium (5 pts)
**Pattern**: `on_delete=models.CASCADE` where `PROTECT` or `SET_NULL` would be more appropriate (e.g., deleting a currency shouldn't delete all accounts)
**Search**: `grep -rn "on_delete=models.CASCADE" apps/`
**Fix**: Use `PROTECT` for reference data, `SET_NULL` for optional relationships, `CASCADE` only for true parent-child ownership.

### COR-04: Timezone-naive datetime usage

**Severity**: Medium (5 pts)
**Pattern**: `datetime.now()` instead of `timezone.now()`, `datetime.utcnow()`
**Search**: `grep -rn "datetime\.now()\|datetime\.utcnow()" apps/`
**Fix**: Use `django.utils.timezone.now()`.

### COR-05: Mutable default arguments

**Severity**: Medium (5 pts)
**Pattern**: `def func(items=[])` or `def func(data={})`
**Search**: `grep -rn "def.*=\[\]\|def.*={}" apps/`
**Fix**: Use `None` as default and initialize inside the function.

### COR-06: Silenced exceptions

**Severity**: Medium (5 pts)
**Pattern**: Bare `except:` or `except Exception: pass`
**Search**: `grep -rn "except:\|except Exception:\s*$" apps/` then check for `pass` on next line.
**Fix**: Handle specific exceptions, log errors, or re-raise.

### COR-07: Incorrect queryset evaluation

**Severity**: Low (3 pts)
**Pattern**: Using `len(queryset)` instead of `.count()`, `list(qs)` when only checking existence, `if queryset:` instead of `.exists()`
**Search**: `grep -rn "len(.*objects\|len(.*filter\|if.*\.all()" apps/`
**Fix**: Use `.count()` for counting, `.exists()` for existence checks.

### COR-08: manage.py check failures

**Severity**: Varies
**Pattern**: System check framework warnings/errors
**Check**: Run `uv run manage.py check --deploy`
**Fix**: Address each warning per Django docs.

---

## Architecture

### ARCH-01: Fat views (business logic in views)

**Severity**: Medium (5 pts)
**Pattern**: Views containing complex business logic (>30 lines of non-DRF/non-serializer code), direct ORM aggregations, multi-step calculations
**Search**: Look for views with heavy computation, complex conditionals, or multi-model orchestration.
**Fix**: Extract business logic to a `services.py` module in the app.

### ARCH-02: Business logic in serializers

**Severity**: Medium (5 pts)
**Pattern**: Serializer `validate()` or `create()` methods containing business logic beyond validation/serialization
**Search**: Check serializer `create`, `update`, and `validate` methods for logic that doesn't relate to data transformation.
**Fix**: Move business logic to services; serializers should only validate input and serialize output.

### ARCH-03: Cross-app model imports

**Severity**: Medium (5 pts)
**Pattern**: Importing models from other apps directly in models.py (creates circular dependencies)
**Search**: `grep -rn "from apps\.\w\+\.models import" apps/*/models.py` — flag when app A imports from app B's models.
**Fix**: Use string references for ForeignKey (`"app_label.ModelName"`), or introduce a shared service layer.

### ARCH-04: Missing @extend_schema on API views

**Severity**: Low (3 pts)
**Pattern**: APIView/ViewSet methods without `@extend_schema()` decorator
**Search**: Scan all view methods for missing schema annotations.
**Fix**: Add `@extend_schema()` with operation_id, summary, description, and response types.

### ARCH-05: Missing base model inheritance

**Severity**: Medium (5 pts)
**Pattern**: Models not inheriting from `UUIDModel` and/or `TimeStampedModel`
**Search**: Check all model classes in apps/ for missing base model inheritance.
**Fix**: Inherit from `UUIDModel, TimeStampedModel` for all domain models.

### ARCH-06: Missing user filtering (multi-tenancy leak)

**Severity**: Critical (10 pts)
**Pattern**: Querysets in views that don't filter by `request.user` on user-scoped models
**Search**: Check all views for `.objects.all()` or `.objects.filter(...)` on user-scoped models without `user=request.user`.
**Fix**: Always filter by `user=request.user` on user-owned models.

### ARCH-07: Missing admin registration

**Severity**: Low (3 pts)
**Pattern**: Models defined but not registered in `admin.py`
**Search**: Cross-reference model definitions with `@admin.register()` calls.
**Fix**: Register models in admin with appropriate list_display, list_filter, and search_fields.

### ARCH-08: Inconsistent error response format

**Severity**: Low (3 pts)
**Pattern**: Views returning different error response shapes (some use `{"error": ...}`, others use `{"detail": ...}`)
**Search**: `grep -rn "Response({" apps/*/views.py` and check error key names.
**Fix**: Standardize on DRF's `{"detail": "..."}` format, or use a custom exception handler.
