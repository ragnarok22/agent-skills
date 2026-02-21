## Summary

Describe the purpose of this PR and the problem it solves.

## Scope

List the key files or directories changed.

## Related Issue

Closes #

## Verification

Paste the commands you ran and short output notes.

```bash
make lint
find skills -mindepth 1 -maxdepth 1 -type d -print | sort
find skills -type f -name '*.md' -size 0
```

## Filesystem Impact

Note any important file creation, deletion, moves, sync/import effects, or schema-like changes.

## Checklist

- [ ] Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`)
- [ ] Required skill files are present (`SKILL.md` and `agents/openai.yaml`)
- [ ] Docs or references were updated when behavior/workflow changed
- [ ] I followed `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`
- [ ] This PR does not include security-sensitive disclosures (see `SECURITY.md`)

