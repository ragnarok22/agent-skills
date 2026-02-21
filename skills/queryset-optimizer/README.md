# QuerySet Optimizer Skill

Optimize Django ORM performance by detecting N+1 patterns, missing eager loading, and likely index gaps.

## Use Cases

- Slow endpoint or serializer investigations
- Query count reduction before release
- Targeted ORM hotspot audits

## Workflow Summary

- Define target scope (endpoint, serializer, task, or full scan).
- Capture runtime query evidence when possible.
- Run static rule scan and validate candidates.
- Score findings and produce prioritized actions.

## Output

- Markdown report with efficiency score, baseline evidence, findings by severity, top actions, and a verification plan.

## Skill Files

- `SKILL.md`: complete audit and scoring workflow.
- `references/antipatterns.md`: performance rule catalog and search patterns.
- `agents/openai.yaml`: UI metadata.

