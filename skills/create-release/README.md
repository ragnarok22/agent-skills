# Create Release Skill

Automate semantic version releases by detecting version files, bumping versions, updating changelogs, creating git tags, and optionally publishing GitHub releases.

## Use Cases

- Cutting a new release for any project type (Python, Node, Rust, Java, mobile)
- Bumping version numbers consistently across multiple version files
- Generating changelog entries from commit history since the last tag
- Creating annotated git tags with proper naming conventions
- Publishing GitHub releases with changelog bodies via `gh` CLI

## Supported Project Types

- **Node.js**: `package.json`, `package-lock.json`, `lerna.json`
- **Python**: `pyproject.toml`, `setup.cfg`, `setup.py`, `__version__.py`
- **Rust**: `Cargo.toml`
- **Java/Kotlin**: `build.gradle`, `build.gradle.kts`, `pom.xml`
- **iOS/React Native**: `app.json`, `Info.plist`
- **Generic**: `version.txt`, `VERSION`

## Workflow Summary

1. Detect all version files and extract current version.
2. Ask for release type (major, minor, patch) and compute new version.
3. Check existing git tags for last release and tag naming convention.
4. Generate changelog content from commits since last tag.
5. Update changelog file (or offer to create one).
6. Check README for version references that may need updating.
7. Bump version in all detected files.
8. Commit changes and create annotated git tag (with user confirmation).
9. Optionally create a GitHub release via `gh` CLI.

## Safety Model

- All git write operations (commit, tag, push) require explicit user confirmation.
- Package registry publishing is out of scope and never executed.
- Dirty working trees are detected and reported before proceeding.
- Inconsistent versions across files are flagged for user resolution.

## Output

Version bump applied to all detected files, changelog updated, git commit and tag created, and optionally a GitHub release published.

## Skill Files

- `SKILL.md`: complete workflow, safety gates, and edge-case handling.
- `references/semver-2.0.0.md`: semantic versioning specification summary.
- `agents/openai.yaml`: UI metadata.
