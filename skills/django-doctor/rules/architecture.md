# Architecture Rules

## ARCH-01: Fat views with business logic

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'class .*?(APIView|ViewSet)|def (create|update|post|put|patch|get)\(' apps .`
**Confirm**: Complex domain logic embedded in views.
**Fix**: Extract business rules into `services.py` or domain layer.

## ARCH-02: Business logic in serializers

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'class .*Serializer|def (validate|create|update)\(' apps .`
**Confirm**: Non-serialization domain logic inside serializer methods.
**Fix**: Move logic to services/use-case layer.

## ARCH-03: Cross-app model imports in `models.py`

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*/models.py' 'from apps\.[^.]+\.models import' apps .`
**Confirm**: Cross-app imports create coupling/cycle risk. Adjust the `apps` prefix in the search pattern to match the project's app namespace (e.g., `myproject`, `src`).
**Fix**: Use string model references or service boundaries.

## ARCH-04: Missing `@extend_schema` annotations

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' '@extend_schema|class .*?(APIView|ViewSet)' apps .`
**Confirm**: Public API handlers lack schema metadata where project expects drf-spectacular docs.
**Fix**: Add `@extend_schema` to documented endpoints.

## ARCH-05: Missing shared base model inheritance

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*/models.py' 'class .*\(.*models\.Model.*\)|UUIDModel|TimeStampedModel' apps .`
**Confirm**: Project standard requires shared base models and a domain model skips them.
**Fix**: Adopt required base model mixins where applicable.

## ARCH-06: Missing user scoping (multi-tenant leak risk)

**Severity**: Critical (10 pts)
**Search**: `rg -n --glob '*.py' '\.objects\.(all|filter|get)\(' apps .`
**Confirm**: User-owned data queried without `request.user` scoping (or equivalent tenant guard).
**Fix**: Enforce tenant/user filtering in all user-scoped access paths.

## ARCH-07: Models missing admin registration

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*/models.py' '^class .*models\.Model' apps . && rg -n --glob '*/admin.py' '@admin\.register|admin\.site\.register' apps .`
**Confirm**: Internal/admin-facing models expected in admin are not registered.
**Fix**: Register models with sensible admin configuration.

## ARCH-08: Inconsistent API error envelope

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' 'Response\(\{[^}]*("error"|"detail")' apps .`
**Confirm**: API mixes inconsistent error response contracts without explicit versioning.
**Fix**: Standardize error shape and exception handling strategy.

## ARCH-09: Circular imports between Django apps

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*/models.py' 'from apps\.' apps .` and `rg -n --glob '*/services.py' 'from apps\.' apps .` and `rg -n --glob '*/views.py' 'from apps\.' apps .`
**Confirm**: App A imports from App B, and App B imports from App A (bidirectional dependency). One-way imports and string model references (`'app_label.ModelName'`) are not circular.
**Fix**: Use string model references for ForeignKey (`to='app.Model'`), introduce a shared interface/event layer, or merge tightly coupled apps. Extract shared logic into a `common`/`core` app.

## ARCH-10: Missing URL namespacing

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*/urls.py' 'app_name|namespace' apps .` and `rg -n --glob '*/urls.py' 'urlpatterns' apps .`
**Confirm**: App-level `urls.py` defines `urlpatterns` but does not set `app_name`. The root URLconf including it does not use `namespace=`. Apps with only one or two URLs are borderline false positives.
**Fix**: Add `app_name = 'myapp'` to each app's `urls.py` and use `namespace='myapp'` in the root `include()`. Update `reverse()` calls to use namespaced names.

## ARCH-11: Signals used for core business logic

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' '@receiver\(post_save|@receiver\(pre_save|@receiver\(post_delete|@receiver\(pre_delete' apps .`
**Confirm**: Signal handler contains business logic (creating related records, sending notifications, updating aggregates, calling external services) rather than lightweight side effects (cache busting, audit log append). Handlers that only log or invalidate cache are false positives.
**Fix**: Replace business-logic signals with explicit service-layer calls. Keep signals only for truly decoupled, optional side effects (audit, analytics, cache).

## ARCH-12: Missing `AppConfig` definitions

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*/apps.py' 'class .*Config.*AppConfig' apps .` combined with listing app directories
**Confirm**: An app directory contains models and views but lacks an `apps.py` with a custom `AppConfig` subclass, or the `AppConfig` exists but `default_auto_field` is not set (causing Django 3.2+ warnings). Trivial utility packages are borderline.
**Fix**: Create or update `apps.py` with a proper `AppConfig` subclass, set `default_auto_field`, and register signals in `ready()`.

## ARCH-13: God models (excessive fields/methods)

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*/models.py' 'class .*\(.*models\.Model' apps .` then inspect model file lengths
**Confirm**: A single model class contains more than approximately 25-30 fields or the model file exceeds 500 lines for a single model. Models that are legitimately wide (event logs, audit tables with many standardized columns) are false positives.
**Fix**: Extract field groups into separate models linked by OneToOneField, use model mixins for shared field groups, or decompose into multiple bounded-context models.

## ARCH-14: Missing custom manager/queryset methods

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' '\.objects\.filter\(|\.objects\.exclude\(' apps .`
**Confirm**: The same or very similar filter chain appears in 3+ locations across different files, and the model lacks a custom manager or queryset with a method encapsulating that filter. One-off filters are false positives.
**Fix**: Create a custom `Manager` or `QuerySet` subclass on the model with named methods (e.g., `.active()`, `.visible_to(user)`) and use them consistently.
