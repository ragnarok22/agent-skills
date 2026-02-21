## Summary

Describe what changed and why.

## Scope

List key files/directories changed (for example `skills/<skill-name>/...`, docs, workflow files).

## Related Issue

Closes #

## Verification

Paste commands run and short output notes.

```bash
make lint
find skills -mindepth 1 -maxdepth 1 -type d -print | sort
find skills -type f -name '*.md' -size 0
```

## Skill Impact

If applicable, describe how skill behavior/instructions changed and who is affected.

## Repository Impact

Note important file creation, deletion, moves, or sync/import behavior changes.

## Checklist

- [ ] Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`)
- [ ] If adding/updating a skill, required files are present (`SKILL.md` and `agents/openai.yaml`)
- [ ] Markdown/YAML content is non-empty and aligned with repository structure conventions
- [ ] Verification commands above were run and outputs were reviewed
- [ ] Docs/references were updated when skill behavior/workflow changed
- [ ] I followed `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`
- [ ] This PR does not include security-sensitive disclosures (see `SECURITY.md`)
