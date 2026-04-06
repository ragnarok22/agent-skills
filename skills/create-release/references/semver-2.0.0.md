# Semantic Versioning 2.0.0 Reference

Source specification: https://semver.org/spec/v2.0.0.html

Use this file as a compact reference for version number rules when preparing releases.

## Version Format

```text
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

Examples:

- `1.0.0`
- `2.3.1`
- `1.0.0-alpha.1`
- `1.0.0-beta.2+build.123`

## Core Rules

1. A version number takes the form `X.Y.Z` where X, Y, and Z are non-negative integers.
2. Each element increases numerically: `1.9.0` -> `1.10.0` -> `1.11.0`.
3. Once a versioned package is released, the contents of that version must not be modified. Any modification requires a new version.
4. Major version zero (`0.Y.Z`) is for initial development. The public API is not stable.
5. Version `1.0.0` defines the first stable public API.

## Incrementing Rules

- **MAJOR**: Increment when you make incompatible API changes. Reset MINOR and PATCH to 0.
- **MINOR**: Increment when you add functionality in a backward-compatible manner. Reset PATCH to 0.
- **PATCH**: Increment when you make backward-compatible bug fixes.

## Pre-release Versions

- Denoted by appending a hyphen and dot-separated identifiers after the patch version.
- Examples: `1.0.0-alpha`, `1.0.0-alpha.1`, `1.0.0-0.3.7`, `1.0.0-x.7.z.92`
- Pre-release versions have lower precedence than the associated normal version.
- A pre-release version indicates the version is unstable and might not satisfy intended compatibility requirements.

## Build Metadata

- Denoted by appending a plus sign and dot-separated identifiers after the patch or pre-release version.
- Examples: `1.0.0+build.1`, `1.0.0-beta+exp.sha.5114f85`
- Build metadata is ignored when determining version precedence.

## Precedence

Precedence is determined by comparing each dot-separated identifier from left to right:

1. Major, minor, and patch are compared numerically: `1.0.0` < `2.0.0` < `2.1.0` < `2.1.1`
2. Pre-release has lower precedence than normal: `1.0.0-alpha` < `1.0.0`
3. Pre-release identifiers are compared left to right: numeric identifiers by value, alphanumeric identifiers lexically.

## Common Pre-release Labels

- `alpha` - early testing, unstable
- `beta` - feature-complete, may have bugs
- `rc` (release candidate) - potential final release

Typical progression: `1.0.0-alpha.1` -> `1.0.0-alpha.2` -> `1.0.0-beta.1` -> `1.0.0-rc.1` -> `1.0.0`
