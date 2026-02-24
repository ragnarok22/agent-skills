# Security Rules

## SEC-01: Hardcoded credentials in source

**Severity**: Critical (10 pts)
**Search**: `rg -n --glob '*.py' "(password|passwd|api[_-]?key|token|secret)\s*=\s*['\"][^'\"]+['\"]" .`
**Confirm**: Literal secret appears in non-test code and is not a documented placeholder. Calls to `os.environ.get()`, `os.getenv()`, or config loaders are false positives.
**Fix**: Load from environment variables or a secrets manager.

## SEC-02: Shell execution with injection risk

**Severity**: Critical (10 pts)
**Search**: `rg -n --glob '*.py' "subprocess\.(run|Popen|call|check_call|check_output)\(.*shell\s*=\s*True|os\.system\(" .`
**Confirm**: Command string can include user-controlled input or unsanitized variables.
**Fix**: Use argument lists, `shell=False`, and strict input validation.

## SEC-03: Unsafe deserialization

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "pickle\.loads|pickle\.load\(|yaml\.load\(" .`
**Confirm**: Untrusted input can reach deserialization path.
**Fix**: Use safe formats and loaders (for example `yaml.safe_load`) and validate schema.

## SEC-04: Dynamic code execution

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "\beval\(|\bexec\(" .`
**Confirm**: Execution path can process untrusted or weakly validated input.
**Fix**: Replace with explicit parsers, whitelisted operations, or dispatch maps.

## SEC-05: TLS verification disabled

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "verify\s*=\s*False|ssl\._create_unverified_context|urllib3\.disable_warnings" .`
**Confirm**: Network calls disable certificate verification outside strictly local dev-only code.
**Fix**: Enforce TLS verification and remove certificate warning suppression.

## SEC-06: Insecure temporary file creation

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "tempfile\.mktemp\(" .`
**Confirm**: Temporary paths are created via `mktemp` and later opened/written.
**Fix**: Use `NamedTemporaryFile` or `mkstemp` patterns.

## SEC-07: Weak randomness in security context

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "random\.(random|randint|randrange|choice|choices)" .`
**Confirm**: `random` module is used for tokens, password reset codes, IDs, or auth-sensitive values.
**Fix**: Use `secrets` module or cryptographically secure token generation.

## SEC-08: SQL injection via string formatting

**Severity**: Critical (10 pts)
**Search**: `rg -n --glob '*.py' "execute\(f\"|execute\(\".*%|execute\(\".*\.format|\.text\(f\"|\.text\(\".*\.format" .`
**Confirm**: User-controlled values are interpolated into SQL strings passed to database execute calls or SQLAlchemy `text()`. Parameterized queries (`execute("... %s", (val,))` or `text(":param")`) are false positives.
**Fix**: Use parameterized queries with bind variables. For SQLAlchemy, use `text(":param").bindparams(param=val)`.

## SEC-09: Binding to all interfaces in production

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "0\.0\.0\.0|host\s*=\s*['\"]0\.0\.0\.0['\"]|INADDR_ANY" .`
**Confirm**: Server binds to all interfaces (`0.0.0.0`) in production or deployable code. Local dev servers and test fixtures are false positives.
**Fix**: Bind to `127.0.0.1` or a specific interface. Use environment variables to configure host binding per environment.

## SEC-10: Path traversal via unsanitized file paths

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "open\(.*\+|os\.path\.join\(.*request|pathlib\.Path\(.*request|send_file\(|send_from_directory\(" .`
**Confirm**: User-controlled input (request parameters, form data, API arguments) flows into file path construction without sanitization or directory confinement.
**Fix**: Validate and sanitize paths with `os.path.realpath()` and verify the resolved path stays within the intended directory. Use `pathlib.Path.resolve()` and check `is_relative_to()`.

## SEC-11: Weak or deprecated hash algorithms for security

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "hashlib\.md5|hashlib\.sha1|md5\(|sha1\(" .`
**Confirm**: MD5 or SHA1 used for password hashing, token generation, integrity verification, or digital signatures. Non-security uses (checksums for caching, ETags, deduplication) are false positives.
**Fix**: Use `hashlib.sha256` or stronger. For password hashing, use `bcrypt`, `argon2`, or `hashlib.scrypt`.

## SEC-12: Logging sensitive data

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "log(ger)?\.(debug|info|warning|error|exception|critical)\(.*password|log(ger)?\.(debug|info|warning|error|exception|critical)\(.*secret|log(ger)?\.(debug|info|warning|error|exception|critical)\(.*token|log(ger)?\.(debug|info|warning|error|exception|critical)\(.*api_key" .`
**Confirm**: Log statements include sensitive variables (passwords, tokens, API keys, secrets) that would appear in log files or monitoring systems.
**Fix**: Redact sensitive fields before logging. Use structured logging with explicit field allowlists.

## SEC-13: XML External Entity (XXE) processing

**Severity**: High (7 pts)
**Search**: `rg -n --glob '*.py' "xml\.etree\.ElementTree\.parse|xml\.dom\.minidom\.parse|lxml\.etree\.parse|xml\.sax\.parse|fromstring\(" .`
**Confirm**: XML parsing processes untrusted input without disabling external entity resolution. The standard library `xml.etree.ElementTree` is safe by default but `lxml` and `xml.sax` may not be.
**Fix**: Use `defusedxml` for untrusted XML. For `lxml`, disable entity resolution with `XMLParser(resolve_entities=False)`. For `xml.sax`, set `feature_external_ges` to False.
