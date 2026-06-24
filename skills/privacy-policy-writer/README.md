# Privacy Policy Writer Skill

Create or update privacy policy drafts for SaaS products, websites, apps, APIs, platforms, and digital products based on installed packages, project code, docs, and user-provided data practices.

## Use Cases

- Write `PRIVACY.md` for a product or platform.
- Update an existing privacy policy after adding auth, analytics, payments, ads, AI features, uploads, or support tools.
- Identify likely data collection from package manifests, SDKs, app code, backend routes, forms, databases, and environment variables.
- Draft user-facing disclosures for collected data, purposes, third-party sharing, retention, and deletion/export requests.
- Create an in-app or website privacy page when requested.

## Workflow Summary

- Inspect project docs, package files, routes, forms, models, APIs, auth, billing, analytics, storage, AI services, and existing legal pages.
- Ask only for missing privacy facts that materially affect the policy.
- Draft clear privacy language with assumptions and placeholders for unknown facts.
- Write `PRIVACY.md` by default, or create/update a privacy page when the user explicitly asks for one.
- Summarize what was written, sources used, included data categories, third parties, retention/deletion rules, assumptions, and legal-review needs.

## Output

- `PRIVACY.md` at the project root unless a different file is requested.
- A privacy page such as `/privacy`, `/privacy-policy`, or `/legal/privacy` if the user asks for one.

## Skill Files

- `SKILL.md`: complete workflow and output rules.
- `references/privacy-policy-template.md`: reusable drafting structure.
- `agents/openai.yaml`: UI metadata.
