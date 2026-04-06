---
name: create-release
description: Automate semantic version releases across project types by detecting version files, bumping versions, updating changelogs, creating git tags, and optionally publishing GitHub releases. Use when users ask to cut a release, bump the version, prepare a new version, tag a release, update the changelog for a release, or publish a GitHub release.
---

# Create Release

Prepare and execute a semantic version release by bumping version strings, updating changelogs, committing changes, tagging, and optionally publishing a GitHub release.

## Workflow

### Step 1: Detect version locations

Scan the repository root for files that contain version strings. Check these files in order:

1. Node.js: `package.json` (field `version`), `package-lock.json`, `lerna.json`
2. Python: `pyproject.toml` (fields `project.version` or `tool.poetry.version`), `setup.cfg` (field `version`), `setup.py` (argument `version=`), `__version__.py` or `_version.py` in source directories, `version.py`
3. Rust: `Cargo.toml` (field `version` under `[package]`)
4. Java/Kotlin: `build.gradle` or `build.gradle.kts` (property `version`), `pom.xml` (element `<version>` under `<project>`)
5. iOS/React Native: `app.json` (field `expo.version` or `version`), `Info.plist` (`CFBundleShortVersionString`)
6. Generic: `version.txt`, `VERSION`

Search commands:

```bash
# Find candidate version files
find . -maxdepth 3 \( \
  -name "package.json" -o -name "pyproject.toml" -o \
  -name "setup.cfg" -o -name "setup.py" -o \
  -name "Cargo.toml" -o -name "build.gradle" -o \
  -name "build.gradle.kts" -o -name "pom.xml" -o \
  -name "app.json" -o -name "version.txt" -o \
  -name "VERSION" -o -name "lerna.json" \
\) -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -not -path "*/vendor/*" -not -path "*/target/*"
```

```bash
# Find Python version files
find . -maxdepth 4 \( \
  -name "__version__.py" -o -name "_version.py" -o \
  -name "version.py" \
\) -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -not -path "*/.venv/*" -not -path "*/venv/*"
```

For each detected file, extract the current version string and record it. If multiple version files exist, verify they contain the same version. If versions are inconsistent, report the discrepancy to the user and ask which version to treat as canonical before proceeding.

If no version files are found, ask the user where versions should be stored and create the entry during the bump step.

### Step 2: Determine current version and release type

1. Read the canonical version from Step 1 results.
2. Validate it follows semantic versioning format: `MAJOR.MINOR.PATCH` with optional pre-release suffix.
3. Ask the user what type of release this is:
   - **major**: breaking changes (increments MAJOR, resets MINOR and PATCH to 0)
   - **minor**: new features, backward-compatible (increments MINOR, resets PATCH to 0)
   - **patch**: bug fixes, backward-compatible (increments PATCH)
4. If the user already specified the release type or target version in their request, use that without asking.
5. Compute the new version string.
6. Present the version change to the user for confirmation: `Current: X.Y.Z -> New: A.B.C`

### Step 3: Check existing tags

Determine the last release tag and the commit range for changelog generation.

```bash
# List recent version tags, sorted by version
git tag --list --sort=-version:refname | head -20
```

Identify the tag naming convention used in the repository:

- `vX.Y.Z` (most common)
- `X.Y.Z` (no prefix)
- `<package>@X.Y.Z` (monorepo style)
- Other prefix patterns

```bash
# Find the most recent tag matching a semver pattern
git tag --list --sort=-version:refname 'v*' | head -1
git tag --list --sort=-version:refname '[0-9]*' | head -1
```

If no existing tags are found:

- Inform the user this appears to be the first release.
- Use the initial commit as the starting point for changelog content.
- Default the tag prefix to `v` unless the user specifies otherwise.

Record the last release tag and the tag prefix convention for use in Steps 4 and 8.

### Step 4: Generate changelog content

1. Collect commits since the last release tag (or all commits if no prior tag exists):

```bash
# Commits since last tag
git log <last-tag>..HEAD --pretty=format:"%h %s" --no-merges

# If no prior tag exists
git log --pretty=format:"%h %s" --no-merges
```

2. If the project uses Conventional Commits, categorize entries:
   - **Added**: `feat` commits
   - **Fixed**: `fix` commits
   - **Changed**: `refactor`, `perf` commits
   - **Breaking Changes**: commits with `!` or `BREAKING CHANGE` footer
   - **Other**: `docs`, `test`, `build`, `ci`, `chore` commits

3. If commit messages do not follow Conventional Commits, group by general intent where possible, or list all changes under a single section.

4. Format the changelog entry:

```text
## [X.Y.Z] - YYYY-MM-DD

### Added
- Description of feature (hash)

### Fixed
- Description of fix (hash)

### Changed
- Description of change (hash)

### Breaking Changes
- Description of breaking change (hash)
```

Omit empty sections. Use the current date for the release date.

### Step 5: Update changelog file

1. Search for an existing changelog file:

```bash
find . -maxdepth 1 -iname "CHANGELOG*" -o -iname "HISTORY*" -o \
  -iname "CHANGES*" -o -iname "NEWS*" -o -iname "RELEASES*" | head -5
```

2. If a changelog file exists:
   - Read the file to understand its existing format and conventions.
   - Insert the new release entry at the top of the file, below any header or preamble, and above the previous release entry.
   - Preserve the existing formatting style (header levels, link references, date format).

3. If no changelog file exists:
   - Ask the user if they want one created.
   - If yes, create `CHANGELOG.md` with a standard header and the new release entry.
   - If no, skip this step and note that changelog was not updated.

4. Present the changelog diff to the user for review before saving.

### Step 6: Check README for version references

Scan the README for version-specific content that may need updating:

```bash
# Search for version strings, badges, or install instructions referencing the old version
grep -n "<old-version>\|badge.*version\|install.*<old-version>" README.md 2>/dev/null || true
```

Check for:

- Version badges (shields.io, badge URLs containing version numbers)
- Installation instructions with pinned versions (`pip install package==X.Y.Z`, `npm install package@X.Y.Z`)
- Download links with version numbers
- Compatibility tables referencing the current version

If version references are found:

- Present each occurrence to the user.
- Suggest updates but do not apply them without user confirmation.

If no version references are found or no README exists, skip this step.

### Step 7: Bump version in all detected files

Update the version string in every file identified in Step 1. Apply file-type-specific update methods:

- **package.json / package-lock.json**: Update the `"version"` field value. For package-lock.json, update both the root `version` and `packages[""].version`.
- **pyproject.toml**: Update `version = "X.Y.Z"` under `[project]` or `[tool.poetry]`.
- **setup.cfg**: Update `version = X.Y.Z` under `[metadata]`.
- **setup.py**: Update the `version="X.Y.Z"` argument.
- ****version**.py / \_version.py / version.py**: Update `__version__ = "X.Y.Z"` or `VERSION = "X.Y.Z"`.
- **Cargo.toml**: Update `version = "X.Y.Z"` under `[package]`.
- **build.gradle / build.gradle.kts**: Update `version = "X.Y.Z"` or `version "X.Y.Z"`.
- **pom.xml**: Update `<version>X.Y.Z</version>` under the root `<project>` element (not dependency versions).
- **app.json**: Update the `"version"` field.
- **version.txt / VERSION**: Replace file contents with the new version string.

After making changes, verify all version files now contain the new version:

```bash
git diff --name-only
```

### Step 8: Commit and tag

**Safety gate (mandatory):** Before executing any git commands that modify history, present the full plan to the user and wait for explicit confirmation:

1. Show the list of files that will be committed.
2. Show the proposed commit message.
3. Show the proposed tag name and format.
4. Wait for user approval before proceeding.

After approval:

```bash
# Stage all modified version and changelog files
git add <list of modified files>

# Commit with a descriptive message
git commit -m "release: bump version to X.Y.Z"
```

```bash
# Create an annotated tag
git tag -a <prefix>X.Y.Z -m "Release X.Y.Z"
```

Use the tag prefix convention detected in Step 3 (default: `v`).

After execution, confirm:

- Commit hash
- Tag name
- Files included in the commit

Do not push to remote unless the user explicitly asks. If the user requests a push:

```bash
git push origin <branch>
git push origin <prefix>X.Y.Z
```

### Step 9: Create GitHub release (optional)

1. Check if `gh` CLI is available:

```bash
gh --version 2>/dev/null
```

2. If `gh` is not installed, inform the user and skip this step.

3. If `gh` is available, ask the user if they want to create a GitHub release.

4. If confirmed, create the release using the changelog content from Step 4 as the body:

```bash
gh release create <prefix>X.Y.Z \
  --title "<prefix>X.Y.Z" \
  --notes "<changelog content>"
```

For pre-release versions (versions with `-alpha`, `-beta`, `-rc` suffixes):

```bash
gh release create <prefix>X.Y.Z \
  --title "<prefix>X.Y.Z" \
  --notes "<changelog content>" \
  --prerelease
```

5. Report the release URL upon success.

## Safety Rules

- Never push commits or tags without explicit user approval.
- Never force-push or rewrite history.
- Never modify files outside the repository root.
- Never run `npm publish`, `cargo publish`, `twine upload`, or any package registry publish command. This skill handles version bumping and tagging only, not package publishing.
- If version files have uncommitted changes before the workflow starts, warn the user and ask how to proceed.
- Treat the working tree as potentially dirty; run `git status` before committing to detect unrelated staged changes.

## Edge Cases

- **No existing tags**: Treat as first release. Use all commits for changelog. Default tag prefix to `v`.
- **No changelog file**: Ask user before creating one. Proceed without if declined.
- **Inconsistent versions across files**: Report discrepancy, ask user to confirm canonical version, then unify all files to the new version.
- **Dirty working tree**: Warn about uncommitted changes. Offer to include them in the release commit or ask user to commit/stash first.
- **Monorepo with multiple packages**: Ask user which package to release. Scope version detection to that package directory.
- **Pre-release versions**: Support `-alpha.N`, `-beta.N`, `-rc.N` suffixes. Ask user if the release is stable or pre-release.
- **Non-semver versions**: If the current version does not follow semver, inform the user and ask for the target version directly.

## Reference

Read [references/semver-2.0.0.md](references/semver-2.0.0.md) for the semantic versioning specification summary.
