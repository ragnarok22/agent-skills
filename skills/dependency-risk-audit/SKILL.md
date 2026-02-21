---
name: dependency-risk-audit
description: Review Python dependencies for known security advisories, stale version pins, and unsafe upgrade paths. Use when users ask for dependency security reviews, requirements or lockfile audits, upgrade planning, pre-release risk checks, or remediation prioritization for Python projects.
---

# Dependency Risk Audit

Run a repeatable dependency-risk audit for Python projects and return a prioritized remediation plan.

## Workflow

### Step 1: Identify dependency source of truth

1. Detect package manager and files in this order:
   - `poetry.lock` + `pyproject.toml`
   - `uv.lock` + `pyproject.toml`
   - `Pipfile.lock` + `Pipfile`
   - `requirements*.txt` and optional `constraints*.txt`
2. Prefer lockfiles for resolved versions.
3. Record Python runtime constraint from:
   - `pyproject.toml` (`requires-python`)
   - `.python-version`
   - CI config (if present)

### Step 2: Build dependency inventory

Create an inventory with:

- package name
- installed/resolved version
- dependency type (`direct` or `transitive`)
- pin style (`exact`, `range`, `unbounded`)
- marker constraints (Python version, platform markers)

If direct/transitive split is unavailable from project files, state that limitation explicitly.

### Step 3: Run security advisory checks

Prefer `pip-audit`. If unavailable, fall back to lockfile/static analysis and mark advisories as partially evaluated.

Common commands:

```bash
# requirements.txt projects
pip-audit -r requirements.txt -f json

# active environment
pip-audit -f json
```

For non-requirements workflows, export to requirements format first when possible, then audit that export.

For each finding, capture:

- advisory ID (for example `PYSEC-*`, `CVE-*`, `GHSA-*`)
- package + affected version
- fixed version range
- severity (if available)
- exploit or impact notes (if available)

### Step 4: Detect stale pins

Classify each direct dependency:

- `current`: no newer release in same major
- `minor/patch stale`: behind within same major
- `major stale`: newer major available
- `unknown`: latest data unavailable

Flag stale pins as higher risk when:

- package is internet-facing, auth-related, crypto-related, or framework/core runtime
- current version is multiple majors behind
- package has a recent advisory history

### Step 5: Evaluate upgrade-path safety

For each dependency requiring change, assess upgrade risk:

- `low`: patch/minor upgrade, no known breaking changes
- `medium`: minor upgrade with behavior/config changes
- `high`: major upgrade, Python-version jump, or resolver conflicts likely

Check these risk signals:

- major-version jump required to reach fixed secure version
- declared Python requirement of target version conflicts with project runtime
- conflicting upper bounds across dependencies
- framework-coupled libraries that typically require code migrations

When possible, propose a stepwise path:

1. patch/minor upgrades first
2. isolated major upgrades next
3. framework/runtime upgrades last

### Step 6: Produce the report

Return a markdown report using this structure:

```markdown
## Dependency Risk Audit

Audit root: `<path>`
Dependency source: `<lockfile or manifest>`
Python runtime target: `<version/constraint>`

### Executive Summary

- Overall risk: [LOW|MEDIUM|HIGH|CRITICAL]
- Known advisories: X (Critical Y, High Z, ...)
- Stale direct dependencies: X (Major-stale Y)
- Unsafe upgrade paths: X

### Security Advisories

| Package | Version | Advisory | Severity | Fixed In | Notes |
| ------- | ------- | -------- | -------- | -------- | ----- |

### Stale Pins

| Package | Current | Latest | Drift Type | Risk Notes |
| ------- | ------- | ------ | ---------- | ---------- |

### Upgrade Path Risks

| Package | Current -> Target | Risk | Why Risky | Recommended Path |
| ------- | ----------------- | ---- | --------- | ---------------- |

### Prioritized Remediation Plan

1. ...
2. ...
3. ...

### Not Evaluated

- Item + reason
```

## Scoring Guidance (optional)

If the user asks for a numeric score, start at `100` and deduct:

- Critical advisory: `-15`
- High advisory: `-10`
- Medium advisory: `-6`
- Low advisory: `-3`
- Major-stale direct dependency: `-4`
- High-risk upgrade path: `-5`

Floor at `0`. Cap repeated deductions for the same package/advisory pair.

## Remediation Loop

If the user asks for fixes:

1. Address critical/high advisories first, prioritizing low-risk upgrades.
2. Re-run audit steps 2-6.
3. Report risk delta, unresolved blockers, and required code changes/tests.
