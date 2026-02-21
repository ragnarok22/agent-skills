---
name: django-doctor
description: Audit Django codebases for security, performance, correctness, and architecture antipatterns. Run system checks, migration drift checks, and static rule scans, then output a 0-100 health score with actionable fixes. Use when users ask to scan a Django backend, run a Django health check, review backend code quality, or perform a pre-deploy audit.
---

# Django Doctor

Run a deterministic Django audit across four categories: **Security**, **Performance**, **Correctness**, and **Architecture**.

Primary output is a scored report with evidence and prioritized remediation actions.

## Workflow

### Step 1: Identify audit scope

1. Locate the Django backend root (directory containing `manage.py`).
2. If multiple backends exist, choose one explicitly and state it in the report.
3. Default scan scope:
   - Include: backend app/source directories and settings files.
   - Exclude: `.git`, `node_modules`, build artifacts, and generated files.

### Step 2: Run Django runtime checks

From the backend root, run:

```bash
uv run manage.py check --deploy 2>&1 || python manage.py check --deploy 2>&1
uv run manage.py makemigrations --check --dry-run 2>&1 || python manage.py makemigrations --check --dry-run 2>&1
```

Capture full output and summarize pass/fail status in the report.

### Step 2: Static scan

Read [references/antipatterns.md](references/antipatterns.md) for rule IDs, severity, search patterns, and fixes.

For every rule:

1. Run the suggested search command.
2. Manually validate candidate matches before scoring.
3. Exclude false positives (tests, migrations, placeholder examples) unless rule says otherwise.
4. Record confirmed findings with:
   - **ID** (for example `SEC-03`)
   - **Severity**
   - **Category**
   - **File and line number**
   - **Brief evidence** (1-3 lines)
   - **Fix recommendation**

If a rule cannot be evaluated, add it to a `Not evaluated` list with reason.

### Step 3: Score findings

Start from 100 and deduct points per finding:

| Severity | Deduction per finding |
|----------|----------------------|
| Critical | -10 |
| High     | -7  |
| Medium   | -5  |
| Low      | -3  |

Rules:
- Floor score at `0`.
- Cap duplicate deductions per rule ID: `severity_points * min(count, 3)`.
- Deduct only for confirmed findings (not for unverified candidates).

### Step 4: Report

Output a markdown report with this structure:

```
## Django Doctor Report

**Health Score: XX / 100** [GRADE]

Grade thresholds: A (90-100), B (80-89), C (70-79), D (60-69), F (<60)
Audit root: `<path>`

### System Checks
- manage.py check --deploy: [PASS/FAIL + short summary]
- makemigrations --check --dry-run: [PASS/FAIL + short summary]

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

### Not Evaluated
- [RULE_ID] Reason rule could not be evaluated.

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

If a severity level has no findings, omit that section. Always include top 3 recommendations sorted by score impact.

### Step 5: Optional fix loop

If the user asks to remediate issues:

1. Fix the highest-impact confirmed findings first.
2. Re-run workflow steps 2-4.
3. Report score delta and remaining risks.
