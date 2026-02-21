# Docker Doctor Skill

Verify Dockerfiles and Docker Compose manifests for **security issues**, **reliability risks**, **performance optimizations**, and **maintainability problems**.

## What It Checks

- Security hardening:
  - Privileged containers, docker socket mounts, host networking
  - Root user defaults, mutable `:latest` tags, unsafe shell piping
- Optimization opportunities:
  - Missing apt cache cleanup
  - Missed multi-stage build candidates
  - Missing container CPU/memory limits
- Reliability and correctness:
  - Compose config parse failures
  - Missing restart policies and healthchecks
  - Missing build context paths
- Maintainability:
  - `ADD` vs `COPY` misuse
  - Optional Dockerfile lint checks via `hadolint`

## Use Cases

- Pre-deploy container configuration checks
- Dockerfile hardening and optimization audits
- Compose troubleshooting before CI/CD or production rollouts

## Quick Start

From the repository root being audited:

```bash
skills/docker-doctor/scripts/verify-docker.sh .
```

The script prints structured lines:

- `CHECK|...` for tool validations (`docker compose config`, `hadolint`)
- `FINDING|...` for rule hits with severity and category
- `SUMMARY|...` with counts and overall result

## Workflow Summary

1. Discover Dockerfiles and Compose files.
2. Run `scripts/verify-docker.sh` for deterministic checks.
3. Confirm and triage findings from `references/checks.md`.
4. Return a scored report with top remediation actions.

## Skill Files

- `SKILL.md`: full audit workflow and scoring/report rules.
- `scripts/verify-docker.sh`: reusable validator for Dockerfiles and Compose files.
- `references/checks.md`: categorized check catalog and manual commands.
- `agents/openai.yaml`: UI metadata.
