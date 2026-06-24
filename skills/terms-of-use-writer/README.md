# Terms Of Use Writer Skill

Create or update Terms of Use drafts for SaaS products, platforms, apps, APIs, marketplaces, and digital products based on the current codebase, docs, and user-provided business rules.

## Use Cases

- Write `TERMS_OF_USE.md` for a product or platform.
- Update existing terms after adding billing, accounts, user content, or subscription features.
- Draft payment, cancellation, refund, suspension, IP, user-content, liability, and acceptable-use clauses.
- Create an in-app Terms or Terms of Use page when requested.

## Workflow Summary

- Inspect project docs, routes, billing, auth, pricing, user-content, and existing legal pages.
- Ask only for missing legal or business facts that materially affect the contract.
- Draft clear terms with assumptions and placeholders for unknown facts.
- Reuse the app's framework, routing, layout, and styling when creating a Terms page.
- Summarize what was written, sources used, assumptions made, and legal-review needs.

## Output

- `TERMS_OF_USE.md` at the project root unless another location is requested.
- A Terms page such as `/terms`, `/terms-of-use`, or `/legal/terms` if the user asks for one.

## Skill Files

- `SKILL.md`: complete workflow and output rules.
- `references/terms-of-use-template.md`: reusable drafting structure.
- `agents/openai.yaml`: UI metadata.
