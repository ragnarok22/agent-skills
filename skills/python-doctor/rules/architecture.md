# Architecture Rules

## ARCH-01: Wildcard imports

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "from .* import \*" .`
**Confirm**: Wildcard import is used outside controlled module export patterns (i.e., not in an `__init__.py` that defines `__all__`).
**Fix**: Import explicit symbols.

## ARCH-02: Deep relative imports

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' "from \\.{2,}" .`
**Confirm**: Excessive relative imports indicate fragile package boundaries.
**Fix**: Prefer absolute imports from stable module roots.

## ARCH-03: Import-time side effects

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "requests\.|open\(|connect\(|create_engine\(" .`
**Confirm**: Network/file/database side effects execute at module import time (top-level scope outside functions/classes).
**Fix**: Move side effects to explicit startup or runtime functions.

## ARCH-04: Oversized modules

**Severity**: Medium (5 pts)
**Search**: `find . -name '*.py' -not -path '*/tests/*' -not -path '*/.venv/*' -print0 | xargs -0 wc -l | sort -nr | head`
**Confirm**: Large modules (for example 500+ lines) contain multiple unrelated responsibilities.
**Fix**: Split into cohesive modules with clear ownership.

## ARCH-05: Global mutable state

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "^\s*[A-Z_][A-Z0-9_]*\s*=\s*(\[\]|\{\}|set\(\))|^\s*global\s+" .`
**Confirm**: Shared mutable globals affect behavior across requests or threads.
**Fix**: Replace with immutable config, dependency injection, or stateful objects with controlled lifecycle.

## ARCH-06: Logging and error policy inconsistency

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' "print\(|logging\.(debug|info|warning|error|exception)\(" .`
**Confirm**: Project mixes ad-hoc `print` diagnostics with inconsistent structured logging/error handling. CLI tools and scripts that intentionally use `print` for user output are false positives.
**Fix**: Standardize logging interface and error envelope per project conventions.

## ARCH-07: Circular imports between modules

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "^from \.|^import \." .` combined with cross-referencing imports between modules
**Confirm**: Module A imports from Module B, and Module B imports from Module A (bidirectional dependency). This causes `ImportError` at runtime or forces fragile deferred imports. One-way imports are not findings.
**Fix**: Extract shared logic into a third module, use dependency injection, or restructure module boundaries. Deferred imports (`import inside function`) are an acceptable temporary workaround.

## ARCH-08: Mixed sync and async patterns

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "async def |def " .` combined with checking files for both sync and async public APIs
**Confirm**: Same module or class exposes both synchronous and asynchronous versions of the same operation without clear separation. Wrapper functions that bridge sync-to-async (e.g., `asyncio.run`, `run_in_executor`) are acceptable.
**Fix**: Separate sync and async interfaces into distinct modules or provide a single paradigm. Use `asyncio.to_thread()` or `run_in_executor()` for bridging when needed.

## ARCH-09: Dependency version not pinned

**Severity**: Medium (5 pts)
**Search**: `rg -n "^[a-zA-Z]" requirements*.txt .` or inspect `[project.dependencies]` in `pyproject.toml`
**Confirm**: Production dependencies lack version pins (no `==`, `~=`, `>=` constraints). Development-only or optional dependencies with loose pins are lower risk. Projects using lock files (`poetry.lock`, `uv.lock`, `Pipfile.lock`) for pinning are false positives.
**Fix**: Pin dependencies with `>=X.Y,<X+1` or `~=X.Y` ranges in requirements/pyproject.toml. Use a lock file for reproducible installs.

## ARCH-10: God classes

**Severity**: Medium (5 pts)
**Search**: `rg -n --glob '*.py' "^class " .` then inspect class size
**Confirm**: A single class has more than approximately 20 methods or 500 lines. This indicates multiple responsibilities that should be decomposed. Data classes or models with many fields but few methods are false positives.
**Fix**: Extract cohesive method groups into separate classes using composition. Apply the single-responsibility principle.

## ARCH-11: Missing `__init__.py` for packages

**Severity**: Low (3 pts)
**Search**: List directories containing `.py` files and check for `__init__.py`
**Confirm**: A directory intended as a Python package contains `.py` modules but lacks an `__init__.py`. Namespace packages (PEP 420) intentionally omit `__init__.py` and are false positives.
**Fix**: Add an `__init__.py` (can be empty) to make the directory a regular package, or document the namespace package intent.

## ARCH-12: Unused imports

**Severity**: Low (3 pts)
**Search**: `rg -n --glob '*.py' "^import |^from .* import " .` cross-referenced with usage in the same file
**Confirm**: Imported names are not referenced elsewhere in the file. Re-exports in `__init__.py` guarded by `__all__` are false positives. Type-checking imports under `if TYPE_CHECKING:` are also acceptable.
**Fix**: Remove unused imports. Use `__all__` in `__init__.py` to make intentional re-exports explicit. Ruff (`F401`) or autoflake can automate this.
