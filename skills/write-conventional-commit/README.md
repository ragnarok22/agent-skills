# Write Conventional Commit Skill

Generate and apply Git commit messages that conform to Conventional Commits 1.0.0.

## Use Cases

- Drafting conventional commit messages from staged or unstaged diffs
- Converting free-form messages into spec-compliant format
- Creating commits directly with correct headers, bodies, and footers

## Workflow Summary

- Inspect repository commit scope from `git status` and diffs.
- Select commit type and optional scope from intent.
- Detect and mark breaking changes when required.
- Compose message using canonical Conventional Commits structure.

## Output

- One recommended commit message (with optional alternatives), or an executed commit result when requested.

## Skill Files

- `SKILL.md`: full workflow and commit execution behavior.
- `references/conventional-commits-1.0.0.md`: normative specification and examples.
- `agents/openai.yaml`: UI metadata.
