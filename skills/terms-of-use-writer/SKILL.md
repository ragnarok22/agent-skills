---
name: terms-of-use-writer
description: Create or update Terms of Use, Terms of Service, or user agreement drafts for SaaS products, platforms, apps, marketplaces, APIs, and digital products by inspecting the current codebase, README, docs, pricing, auth, billing, user-content, and product functionality. Use when users ask to write terms, terms of use, terms of service, legal terms, platform rules, subscription/payment terms, cancellation/refund policies, acceptable use rules, IP/user-content clauses, liability limits, suspension rules, or to create an in-app Terms page.
---

# Terms Of Use Writer

Create or update a practical Terms of Use draft based on the current product implementation, project docs, and the user's stated business rules.

This skill is a drafting aid, not legal advice. Always recommend qualified legal review before publishing.

## Workflow

### Step 1: Inspect Product Context

Before writing, inspect the project for real product behavior and existing legal/business language.

Prioritize these sources:

1. Existing terms, privacy policy, legal pages, footer links, onboarding copy, pricing pages, checkout pages, cancellation/refund copy, and support docs.
2. `README.md`, product docs, landing pages, feature specs, and roadmap notes.
3. Auth/account flows, user roles, organization/team features, subscriptions, invoices, trials, cancellation, refund, and billing integration code.
4. User-content features such as uploads, posts, comments, profiles, messages, API input, generated output, storage, sharing, export, or deletion.
5. App routes/pages, API routes, backend models, permissions, moderation, suspension, rate limits, and abuse prevention.
6. App config, package files, environment variable names, third-party service integrations, analytics, payment providers, and email providers.

Common files and patterns to inspect:

```text
README.md
TERMS.md
TERMS_OF_USE.md
PRIVACY.md
LEGAL.md
docs/**/*
app/**/*.{ts,tsx,js,jsx,md,mdx}
pages/**/*.{ts,tsx,js,jsx,md,mdx}
src/**/*.{ts,tsx,js,jsx,py,rb,php,go,rs,md,mdx}
components/**/*.{ts,tsx,js,jsx}
routes/**/*
api/**/*
server/**/*
models/**/*
schema.prisma
package.json
app.json
next.config.*
stripe
billing
subscription
checkout
refund
cancel
terms
privacy
```

Treat the user's explicit instructions as the highest-priority business input. Treat project files as evidence of actual functionality. Do not invent legal facts.

### Step 2: Identify Terms-Relevant Facts

Extract or infer only supported facts about:

- Product name, operator/legal entity, contact email, and supported locations if stated.
- Account requirements, eligibility, user responsibilities, and security duties.
- Paid plans, free plans, trials, subscriptions, renewal timing, taxes, payment processors, failed payments, cancellation behavior, and refund rules.
- User content, uploaded files, generated content, feedback, ownership, licenses, moderation, and deletion.
- Prohibited conduct, abuse, scraping, reverse engineering, security testing, spam, unlawful use, and policy violations.
- Suspension, termination, account deletion, data retention, and effect of termination.
- Product IP, trademarks, software license, API usage, third-party services, support, availability, and service changes.
- Disclaimers, liability limits, indemnification, governing law, disputes, changes to terms, and contact process.

Record assumptions separately from confirmed facts.

### Step 3: Ask Only For Missing Material Facts

If important legal or business facts are missing, ask a short set of focused questions before drafting. Prefer 3-7 questions.

Ask only what affects the contract materially, such as:

1. What is the legal company/operator name and contact email?
2. Which governing law or jurisdiction should apply?
3. How do payments work: one-time purchase, subscription, usage-based billing, free trial, or custom invoices?
4. What is the cancellation and refund policy?
5. Can users upload, publish, share, or generate content, and who owns that content?
6. What conduct should allow suspension or termination?
7. Should the terms include arbitration, class-action waiver, age restrictions, or region-specific consumer language?

If the user wants a fast draft and missing facts remain, write with clear placeholders such as `[Company Legal Name]` and an assumptions section.

### Step 4: Draft Or Update Terms

Create or update `TERMS_OF_USE.md` at the project root unless the user asks for another file name or location.

Use the reference structure in [references/terms-of-use-template.md](references/terms-of-use-template.md). Adapt every clause to the product; do not leave irrelevant sections.

Writing rules:

- Use clear English and practical contract language.
- Base clauses on the observed product functionality and user-provided business rules.
- Make payment, cancellation, refund, suspension, IP, user-content, and liability terms explicit.
- Use placeholders for missing legal facts rather than inventing them.
- Mark assumptions and items requiring legal review.
- Do not claim GDPR, HIPAA, SOC 2, PCI, tax, consumer-law, or regulated-industry compliance unless project docs clearly support it.
- Do not promise uptime, support response times, refunds, data recovery, security guarantees, or feature availability unless the user or docs require it.
- Keep the tone firm, readable, and product-specific.

### Step 5: Create A Terms Page If Requested

If the user asks to create a Terms page, inspect the app framework and routing conventions before editing code.

Implementation rules:

- Reuse the existing routing structure, layout components, typography, metadata conventions, and styling system.
- Prefer rendering the terms content from a shared Markdown/MDX file when the project already supports Markdown/MDX.
- If Markdown rendering is not available, create a simple page component with semantic headings and readable sections.
- Add metadata/title when the framework supports it.
- Add or update footer/settings/legal links only when the user asks or existing patterns make the intended location obvious.
- Do not introduce a new UI library, markdown pipeline, or route convention just for the terms page.
- Preserve existing design language and accessibility expectations.

Common route targets:

```text
/terms
/terms-of-use
/legal/terms
```

### Step 6: Quality Check

Before finishing, verify the terms:

- Match the product's real features and business model.
- Define what the platform can do and cannot do.
- Explain payments, renewals, cancellation, refunds, failed payments, and taxes when relevant.
- Explain user responsibilities, acceptable use, suspension, and termination.
- Address intellectual property, user content, feedback, and licenses.
- Limit responsibility without overclaiming enforceability.
- Include placeholders or assumptions for missing legal facts.
- Avoid unsupported compliance, security, SLA, refund, or legal claims.

### Step 7: Final Summary

At the end, summarize what was written.

Include:

- Where the terms document or page was created or updated.
- Which product sources were used.
- The main sections included.
- Key assumptions, placeholders, or facts still needing legal/business confirmation.
- Whether a legal review is recommended before publishing.
