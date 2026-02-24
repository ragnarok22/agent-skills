# Correctness Rules

## COR-01: Missing migrations

**Severity**: Critical (10 pts)
**Check**: `<MANAGE_CMD> makemigrations --check --dry-run`
**Confirm**: Command reports model drift.
**Fix**: Generate and review migrations.

## COR-02: Missing model constraints for business rules

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'def validate|UniqueConstraint|CheckConstraint|constraints\s*=' apps .`
**Confirm**: Rule enforced only in serializer/view logic, not DB constraints.
**Fix**: Add appropriate model constraints.

## COR-03: Risky cascade deletes

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'on_delete\s*=\s*models\.CASCADE' apps .`
**Confirm**: CASCADE used where reference integrity should be preserved.
**Fix**: Prefer `PROTECT` or `SET_NULL` when ownership is not strict parent-child.

## COR-04: Timezone-naive datetime usage

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'datetime\.now\(\)|datetime\.utcnow\(\)' apps .`
**Confirm**: Naive time used in persisted/business-critical logic.
**Fix**: Use `django.utils.timezone.now()`.

## COR-05: Mutable default arguments

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'def .*\=\[\]|def .*\=\{\}' apps .`
**Confirm**: Mutable default values in function signatures.
**Fix**: Use `None` default, initialize inside function.

## COR-06: Silenced exceptions

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'except:\s*$|except Exception:\s*$|except:\s*pass|except Exception:\s*pass' apps .`
**Confirm**: Exception is swallowed (`pass`) or obscured without logging/handling.
**Fix**: Catch specific exceptions and handle/log explicitly.

## COR-07: Inefficient or incorrect queryset evaluation

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' 'len\([^)]*queryset|if\s+[^:]*\.all\(\)|list\([^)]*queryset' apps .`
**Confirm**: Uses eager/materializing patterns where `.count()`/`.exists()` is intended.
**Fix**: Replace with queryset-native operations.

## COR-08: Django system check failures

**Severity**: Varies
**Check**: `<MANAGE_CMD> check --deploy`
**Confirm**: Any warning/error relevant to target deployment mode.
**Fix**: Resolve each warning or explicitly justify accepted risk.

## COR-09: Missing `transaction.atomic()` for multi-step writes

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'def (create|update|post|put|patch|perform_create|perform_update)\(' apps .`
**Confirm**: View or service method performs multiple `.save()`, `.create()`, `.delete()`, or `.update()` calls without wrapping them in `transaction.atomic()`. Single-write methods or methods already using `atomic()` are false positives. Cross-check with: `rg -n --glob '*.py' 'transaction\.atomic|@transaction\.atomic' apps .`
**Fix**: Wrap multi-step write operations in `transaction.atomic()` (decorator or context manager). Ensure error handling rolls back the transaction on failure.

## COR-10: Using `.get()` without `DoesNotExist` handling

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' '\.objects\.get\(' apps .`
**Confirm**: `.objects.get()` call is not wrapped in `try/except` for `DoesNotExist` (or `ObjectDoesNotExist`) and not using `get_object_or_404()`. Non-ORM `.get()` calls (dicts, caches) are false positives.
**Fix**: Use `get_object_or_404()` in views, or wrap in `try/except Model.DoesNotExist`. For optional lookups, consider `.filter().first()`.

## COR-11: Missing `__str__` on models

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*/models.py' 'class .*\(.*models\.Model' apps .` then check each model for `def __str__`
**Confirm**: A concrete (non-abstract) model class that maps to a database table lacks a `__str__` method. Abstract base models and proxy models without their own representation are false positives.
**Fix**: Add a `__str__` method that returns a meaningful human-readable representation.

## COR-12: Deprecated Django APIs still in use

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'django\.conf\.urls\.url\(|from django\.utils\.encoding import (force_text|smart_text)|from django\.utils\.translation import ugettext|from django\.conf\.urls import url\b' apps .`
**Confirm**: Deprecated import or function call is present in non-test production code. Libraries in `site-packages` or vendored code are false positives.
**Fix**: Replace `url()` with `re_path()` or `path()`. Replace `force_text`/`smart_text` with `force_str`/`smart_str`. Replace `ugettext`/`ugettext_lazy` with `gettext`/`gettext_lazy`.

## COR-13: Settings not split by environment

**Severity**: Medium (5 pts)
**Search**: `rg -l --glob 'settings*.py' '' config settings .` (list all settings files)
**Confirm**: Only a single `settings.py` exists with no `settings/` directory, no `local.py`/`production.py`/`staging.py` split, and no environment-based import. Projects using environment variables for all config differences (12-factor style with a single file) are a false positive.
**Fix**: Split settings into base/local/production modules, or use `django-environ`/`django-configurations` for environment-based configuration.

## COR-14: Incorrect signal receiver signatures

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' '@receiver\(' apps .`
**Confirm**: Decorated function does not accept `**kwargs` or is missing required positional parameters for its signal type (e.g., `post_save` needs `sender`, `instance`, `created`, `**kwargs`). Functions using `*args, **kwargs` are acceptable.
**Fix**: Ensure all signal receivers accept `**kwargs` at minimum and include required positional parameters for the signal type.
