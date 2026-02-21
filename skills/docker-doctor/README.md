# Docker Doctor Skill

Verify Dockerfiles and Docker Compose manifests for **security issues**, **reliability risks**, **performance optimizations**, and **maintainability problems**.

## Use Cases

- Pre-deploy container configuration checks
- Dockerfile hardening and optimization reviews
- Compose validation and misconfiguration debugging

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
