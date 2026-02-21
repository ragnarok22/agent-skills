# agent-skills

Single source of truth for your custom Codex/Agent skills.

## Structure

```text
agent-skills/
  skills/
    <skill-name>/
      SKILL.md
      agents/openai.yaml
      scripts/        # optional
      references/     # optional
      assets/         # optional
  tools/
```

## Naming

- Use lowercase and hyphens only (example: `pricing-copy-audit`).
- Keep names short and action-oriented.

## Create Your First Skill

1. Create a folder:
   `mkdir -p skills/my-skill/agents`
2. Add required files:
   - `skills/my-skill/SKILL.md`
   - `skills/my-skill/agents/openai.yaml`
3. Add optional resources as needed:
   - `skills/my-skill/scripts/`
   - `skills/my-skill/references/`
   - `skills/my-skill/assets/`

## Commands

- `make list`: list all local skills in this repo
- `make sync`: copy repo skills to:
  - `~/.agents/skills`
  - `~/.codex/skills`

## Notes

- This repo is intended for your own skills only.
- Avoid importing default/shared skills unless you explicitly want them here.
