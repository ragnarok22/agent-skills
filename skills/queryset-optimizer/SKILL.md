---
name: queryset-optimizer
description: Optimize Django ORM performance by detecting N+1 query patterns, missing `select_related`/`prefetch_related`, and likely index gaps. Run targeted static scans, optional runtime query capture, and produce a prioritized remediation plan with expected query-count impact. Use when users ask to speed up Django endpoints, reduce database hits, investigate slow views/serializers, or audit QuerySet efficiency before release.
---

# QuerySet Optimizer

Audit Django query performance with deterministic checks and evidence-backed recommendations.

## Workflow

### Step 1: Set scope and baseline target

1. Locate the Django backend root (directory containing `manage.py`).
2. Define the optimization target:
   - endpoint or view
   - serializer
   - background task
   - repeated ORM hotspot from profiling data
3. If target is unknown, scan all app directories and prioritize read-heavy paths first (list endpoints, feed pages, reports).

### Step 2: Capture runtime query evidence (preferred)

Collect at least one measurable baseline for the target before changing code.

Open Django shell:

```bash
uv run manage.py shell 2>/dev/null || python manage.py shell
```

Then capture query count for one representative code path:

```python
from django.db import connection
from django.test.utils import CaptureQueriesContext

with CaptureQueriesContext(connection) as ctx:
    # Execute the target path, for example evaluating the target queryset.
    list(qs)

print(f"queries={len(ctx.captured_queries)}")
```

If runtime capture is not feasible, continue with static analysis and mark runtime validation as not evaluated.

### Step 3: Run static scan

Read [references/antipatterns.md](references/antipatterns.md) for rule IDs, severity, search commands, and fix patterns.

For each rule:

1. Run the suggested search command.
2. Manually validate each candidate.
3. Exclude false positives (tests, migrations, fixtures, one-off scripts) unless explicitly relevant.
4. Record confirmed findings with:
   - ID
   - Severity
   - File and line number
   - Evidence (1-2 lines)
   - Fix recommendation
   - Expected impact (query count, memory, latency, or lock time)

### Step 4: Score

Start from 100 and deduct points per confirmed finding:

| Severity | Deduction |
| -------- | --------- |
| High     | -8        |
| Medium   | -5        |
| Low      | -2        |

Rules:

- Floor score at `0`.
- Cap duplicate deductions for each rule ID to 3 findings.
- Deduct only for confirmed findings.
- Add `+5` bonus (max `100`) when before/after query counts are measured for at least one hotspot.

### Step 5: Report

Output a markdown report with this structure:

```text
## QuerySet Optimizer Report

**Efficiency Score: XX / 100** [GRADE]
Grade: A (90-100), B (80-89), C (70-79), D (60-69), F (<60)
Audit root: `<path>`
Target: `<endpoint/view/task or full-scan>`

### Baseline Evidence
- Runtime query capture: [AVAILABLE/NOT AVAILABLE]
- Representative query count(s): [before values or N/A]

### Findings

#### High
| ID | Location | Issue | Fix | Expected Impact |
|----|----------|-------|-----|-----------------|
| ... | ... | ... | ... | ... |

#### Medium
...

#### Low
...

### Not Evaluated
- [RULE_ID] Reason not evaluated.

### Top Actions
1. ...
2. ...
3. ...

### Verification Plan
- [ ] Re-run representative path and compare query count.
- [ ] Confirm no behavior regressions (ordering, permissions, pagination).
- [ ] Add regression test when hotspot is business-critical.
```

If a severity bucket has no findings, omit that section.

### Step 6: Optional remediation loop

If the user asks for fixes:

1. Fix highest-impact findings first.
2. Re-measure query counts or latency for the same path.
3. Re-run Steps 3-5.
4. Report score delta and residual risks.
