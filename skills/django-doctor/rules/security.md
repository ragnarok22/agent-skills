# Security Rules

## SEC-01: Hardcoded SECRET_KEY

**Severity**: Critical (10 pts)
**Search**: `rg -n --glob '*.py' 'SECRET_KEY\s*=' config settings .`
**Confirm**: Literal secret in shared/base/production settings, not an env lookup.
**Fix**: Load from environment in deployable settings.

## SEC-02: DEBUG=True in deployable settings

**Severity**: Critical (10 pts)
**Search**: `rg -n --glob '*.py' 'DEBUG\s*=\s*True' config settings .`
**Confirm**: Value is active in production/deploy profile, not local-only settings.
**Fix**: Set `DEBUG = False` for deployed environments.

## SEC-03: Raw SQL without parameterization

**Severity**: Critical (10 pts)
**Search**: `rg -n --glob '*.py' '\.raw\(f"|\.raw\(".*%|\.raw\(".*\.format|cursor\.execute\(f"|\.extra\(' apps .`
**Confirm**: User-controlled values are interpolated into SQL.
**Fix**: Use parameterized SQL arguments.

## SEC-04: Missing CSRF protection on state-changing endpoints

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' '@csrf_exempt' apps .`
**Confirm**: Endpoint mutates state and is not an intentional public auth endpoint.
**Fix**: Remove `@csrf_exempt` or add proper CSRF/session strategy.

## SEC-05: Exposed traces or raw exception messages

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'traceback\.print_exc|str\(e\)|repr\(e\)' apps .`
**Confirm**: Response payload leaks internals to clients.
**Fix**: Log server-side details and return generic client errors.

## SEC-06: Wildcard CORS or ALLOWED_HOSTS

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'CORS_ALLOW_ALL_ORIGINS\s*=\s*True|CORS_ORIGIN_ALLOW_ALL\s*=\s*True|ALLOWED_HOSTS\s*=\s*\[[^]]*\*' config settings .`
**Confirm**: Wildcards are enabled in deployable settings.
**Fix**: Restrict to explicit origins/hosts.

## SEC-07: Missing authentication on protected endpoints

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'class .*?(APIView|ViewSet)' apps .`
**Confirm**: Endpoint is not public but lacks auth requirements (`IsAuthenticated` or equivalent).
**Fix**: Add explicit permission/authentication classes.

## SEC-08: Secrets committed in source

**Severity**: Critical (10 pts)
**Search**: `rg -n --glob '*.py' "(password|api_key|token|secret)\s*=\s*['\"][^'\"]+['\"]" apps config settings .`
**Confirm**: Hardcoded credential in non-test code.
**Fix**: Move to env vars or a secrets manager.

## SEC-09: Missing security middleware settings

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'SECURE_SSL_REDIRECT|SECURE_HSTS_SECONDS|SESSION_COOKIE_SECURE|CSRF_COOKIE_SECURE|X_FRAME_OPTIONS|SECURE_CONTENT_TYPE_NOSNIFF' config settings .`
**Confirm**: Deployable settings (production, staging, base without override) lack these settings or set them to insecure values (`False`, `0`). Local/dev-only settings are excluded. If COR-08 runtime check passed and already covered these, do not double-deduct.
**Fix**: In production settings set `SECURE_SSL_REDIRECT = True`, `SECURE_HSTS_SECONDS = 31536000` (with `SECURE_HSTS_INCLUDE_SUBDOMAINS = True`, `SECURE_HSTS_PRELOAD = True`), `SESSION_COOKIE_SECURE = True`, `CSRF_COOKIE_SECURE = True`, `X_FRAME_OPTIONS = 'DENY'`, `SECURE_CONTENT_TYPE_NOSNIFF = True`.

## SEC-10: XSS via `mark_safe()` or `|safe` template filter

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'mark_safe\(' apps .` and `rg -n --glob '*.html' '\|safe' apps templates .`
**Confirm**: The argument to `mark_safe()` or the variable piped through `|safe` can include user-controlled content (form input, database fields from users, URL params). Pure static content (hardcoded HTML fragments, icon SVGs) is a false positive.
**Fix**: Sanitize user content with `bleach.clean()` or `django.utils.html.escape()` before marking safe. Prefer template-level escaping and avoid `mark_safe` for user data entirely.

## SEC-11: Unsafe file upload handling

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' 'FileField|ImageField|request\.FILES|InMemoryUploadedFile|TemporaryUploadedFile' apps .`
**Confirm**: Upload fields or handlers lack file type validation (no `FileExtensionValidator` or custom content-type check), lack size limits (no `DATA_UPLOAD_MAX_MEMORY_SIZE` or manual check), or store files in publicly accessible paths without sanitizing filenames.
**Fix**: Add `FileExtensionValidator` with an allowlist, validate content type against actual file bytes, enforce `DATA_UPLOAD_MAX_MEMORY_SIZE`, use `upload_to` with a sanitizing function, and serve from a non-executable storage backend.

## SEC-12: Missing rate limiting on authentication endpoints

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' 'LoginView|TokenObtainPairView|obtain_auth_token|login|password_reset|AuthToken' apps .` and `rg -n --glob '*.py' 'throttle_classes|UserRateThrottle|AnonRateThrottle|ratelimit|django-axes' apps .`
**Confirm**: Auth views or endpoints lack throttle/rate-limit declarations and no project-wide throttle is configured in `REST_FRAMEWORK['DEFAULT_THROTTLE_CLASSES']`. Infrastructure-level rate limiting (reverse proxy, CDN) is a valid exception.
**Fix**: Add `throttle_classes = [AnonRateThrottle]` to auth endpoints, configure `DEFAULT_THROTTLE_RATES` in DRF settings, or integrate `django-axes`/`django-ratelimit`.

## SEC-13: Mass assignment via uncontrolled serializer fields

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "fields\s*=\s*['\"]__all__['\"]|exclude\s*=\s*\(" apps .`
**Confirm**: A write-capable serializer (used in POST/PUT/PATCH endpoints) exposes all fields or uses `exclude` (which silently includes new fields when the model changes). Read-only serializers or admin-only endpoints are false positives.
**Fix**: Use explicit `fields = [...]` lists on writable serializers. Never use `fields = '__all__'` on endpoints that accept user input. For models with sensitive fields, use separate read and write serializers.

## SEC-14: Unsafe `JsonResponse` with unescaped user data

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' 'JsonResponse\(.*safe\s*=\s*False|HttpResponse\(.*json\.dumps' apps .`
**Confirm**: User-controlled data serialized via `JsonResponse(data, safe=False)` or raw `json.dumps` through `HttpResponse` without proper `content_type='application/json'` header.
**Fix**: Use `JsonResponse` with default `safe=True` for dicts, validate/sanitize user data before serialization, ensure `content_type='application/json'` is always set.
