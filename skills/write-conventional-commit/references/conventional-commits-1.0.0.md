# Conventional Commits 1.0.0 Reference

Source specification:

- https://www.conventionalcommits.org/en/v1.0.0/
- https://www.conventionalcommits.org/en/v1.0.0/#specification

Use this file as a compact, practical checklist for creating compliant commit messages.

## Canonical format

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Breaking change marker may be added before the colon:

```text
<type>[optional scope]!: <description>
```

## Normative rules checklist

1. Start each commit with a type followed by optional scope, optional `!`, colon, and description.
2. `feat` represents a new feature.
3. `fix` represents a bug fix.
4. Scope, when present, is wrapped in parentheses.
5. Description follows immediately after `: `.
6. Body is optional and begins one blank line after the description.
7. Footer is optional and begins one blank line after body (or after description when no body).
8. Footer tokens use trailer form, commonly `Token: value`.
9. Breaking changes can be indicated by:
   - `!` in header, and/or
   - `BREAKING CHANGE: <details>` footer.
10. Footer tokens use hyphens instead of spaces, except `BREAKING CHANGE`.

## Footer guidance

Common footer examples:

- `BREAKING CHANGE: remove legacy /v1/orders endpoint; migrate to /v2/orders`
- `Refs: #123`
- `Reviewed-by: name`

Use clear migration guidance for breaking changes.

## Type recommendations (convention, not strict spec)

The spec allows custom types. Common ecosystem types:

- `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

Prefer a small stable set per repository.

## SemVer intent mapping

- `fix` maps to PATCH intent.
- `feat` maps to MINOR intent.
- Any commit with breaking change maps to MAJOR intent.

## Good examples

- `feat(search): add saved filters for authenticated users`
- `fix(api): handle null currency on invoice creation`
- `refactor(auth): split token verification into service module`
- `feat(api)!: remove v1 profile response fields`

Body and footer example:

```text
feat(api)!: remove v1 profile response fields

Return normalized profile payload used by web and mobile clients.

BREAKING CHANGE: `full_name` and `avatar_url` were removed. Use `profile.name` and `profile.avatar.url`.
Refs: #418
```
