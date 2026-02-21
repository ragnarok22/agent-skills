---
name: django-doctor
description: Scan a Django codebase for security, performance, correctness, and architecture antipatterns. Outputs a 0-100 health score with actionable diagnostics. Use when the user says "scan my django project", "check for antipatterns", "django health check", "audit my backend", "run django doctor", "check my django code", or asks to review Python/Django code quality. Also use after finishing a Django feature or before a deploy.
---

# Django Doctor

Scan the entire Django project for antipatterns across four categories: **Security**, **Performance**, **Correctness**, and **Architecture**. Produce a 0-100 health score and actionable fix list.

## Workflow

### Step 1: Run Django system checks

Run `uv run manage.py check --deploy 2>&1` and `uv run manage.py makemigrations --check --dry-run 2>&1` from the backend root. Capture output for the report.

### Step 2: Static scan

Read [references/antipatterns.md](references/antipatterns.md) for the full catalog of checks with IDs, severity, search patterns, and fixes.

For each antipattern, use the suggested search pattern (Grep/Glob/Read) to determine if the issue exists. Record every finding with:
- **ID** (e.g., SEC-03)
- **File and line number**
- **Brief evidence** (the offending code snippet, 1-3 lines)
- **Suggested fix**

### Step 3: Score

Start from 100 and deduct points per finding:

| Severity | Deduction per finding |
|----------|----------------------|
| Critical | -10 |
| High     | -7  |
| Medium   | -5  |
| Low      | -3  |

Floor the score at 0. Cap duplicate deductions: if the same antipattern ID appears N times, deduct `severity * min(N, 3)` (max 3x per rule to avoid a single widespread issue dominating the score).

### Step 4: Report

Output a markdown report with this structure:

```
## Django Doctor Report

**Health Score: XX / 100** [GRADE]

Grade thresholds: A (90-100), B (80-89), C (70-79), D (60-69), F (<60)

### System Checks
- manage.py check: [PASS/FAIL summary]
- Pending migrations: [PASS/FAIL summary]

### Findings

#### Critical
| ID | Location | Issue | Fix |
|----|----------|-------|-----|
| ... | ... | ... | ... |

#### High
...

#### Medium
...

#### Low
...

### Summary
- Security: X issues (Y critical)
- Performance: X issues
- Correctness: X issues
- Architecture: X issues
- **Top 3 actions to improve your score:**
  1. ...
  2. ...
  3. ...
```

If no issues are found in a severity level, omit that section. Always include the top 3 actionable recommendations sorted by impact.
