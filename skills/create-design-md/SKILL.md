---
name: create-design-md
description: Create an English-only DESIGN.md that translates brand strategy and project context into practical, implementation-ready design direction for product UI, landing pages, visual systems, and AI coding agents. Use when users ask to create, update, or improve DESIGN.md; define visual direction for an app, website, SaaS, product, landing page, or design system; convert BRANDING.md into usable UI rules; or produce design tokens, palettes, component rules, responsive guidance, motion, and accessibility standards.
---

# Create DESIGN.md

Create or update `DESIGN.md` in English only. The document must translate brand strategy into usable design direction for product UI, landing pages, visual systems, and implementation.

The result should be specific enough that designers, frontend developers, and AI coding agents can build consistent screens from it.

## Workflow

### Step 1: Inspect Existing Context

Before writing, inspect the project for available context.

Prioritize these sources:

1. `BRANDING.md` as the primary source of truth when it exists.
2. `README.md` and product docs for product purpose, audience, positioning, and feature scope.
3. Existing UI files, routes, components, and screen names.
4. Theme files, design tokens, CSS variables, global CSS, Tailwind config, UI library config, or React Native theme files.
5. App screenshots, marketing images, logos, icons, or visual assets when available.

Use `BRANDING.md` to derive practical design rules. Do not duplicate the full brand guide into `DESIGN.md`.

Common files and patterns to inspect:

```text
BRANDING.md
README.md
DESIGN.md
tailwind.config.*
postcss.config.*
src/**/*.{css,scss,tsx,jsx,ts,js}
app/**/*.{css,scss,tsx,jsx,ts,js}
components/**/*.{css,scss,tsx,jsx,ts,js}
styles/**/*
theme/**/*
tokens/**/*
assets/**/*
public/**/*
*.png, *.jpg, *.jpeg, *.webp, *.svg
```

### Step 2: Ask Only Important Missing Questions

If enough context exists, do not ask questions. Create or update `DESIGN.md` directly.

If important context is missing, ask 3-6 focused questions. Prefer the most consequential questions from this list:

1. What will this design guide support: landing page, product app UI, marketing assets, or all of the above?
2. What platforms should the design account for: web, mobile app, desktop, tablet, or responsive landing page?
3. Should the product feel more minimal and serious, warm and friendly, playful but refined, premium and polished, or technical and precise?
4. Are there existing brand colors, typography choices, logo directions, or references to preserve?
5. Are there visual styles to avoid, such as corporate SaaS, luxury, crypto, childish mascot, overly colorful, or generic AI design?
6. Should the guide include implementation tokens: CSS variables, Tailwind tokens, React Native theme tokens, or design-only guidance?

Do not run a long interview. Ask only what is needed to produce a useful first version.

### Step 3: Resolve Inputs Into Direction

Turn gathered context into design decisions.

Decision rules:

- Preserve user-provided brand guidance over generic design best practices.
- Keep existing brand colors, typography, logo direction, and visual references unless the user asks to change them.
- Resolve conflicts by prioritizing `BRANDING.md`, then explicit user instructions, then existing implementation, then inferred best practice.
- Avoid vague words like "modern", "clean", or "beautiful" unless immediately explained with concrete design choices.
- Do not create a generic SaaS design guide.
- Make the visual direction distinctive to the product, audience, and product name.

### Step 4: Write DESIGN.md

Create or update `DESIGN.md` at the project root unless the user asks for another location.

Use Markdown. Use code blocks for implementation tokens. Keep sections scannable and concise.

Use this structure unless the project clearly needs a smaller or adjusted version:

```markdown
# [Product Name] Design Guide

## Purpose

Explain what this document is for and how it relates to the brand guide.

## Design North Star

Define the main visual and emotional direction in one clear paragraph.

## Visual Concept

Explain the core visual metaphor and the design ingredients.

## Design Principles

List 4-6 practical principles that guide design decisions.

## Core Color Tokens

Define primary brand colors with hex values and usage.

## Functional Color Tokens

Define colors for states such as success, warning, error, info, savings, income, expense, and neutral.

## Light Mode Palette

Give concrete background, surface, text, border, and action colors.

## Dark Mode Palette

Give dark mode equivalents if relevant.

## Recommended Color Usage

Explain how colors should be used in product UI and marketing/landing pages.

## CSS Variables

Include CSS custom properties if the project uses web.

## App Theme Tokens

Include a TypeScript or JavaScript theme object if the project uses React Native, Expo, or similar.

## Typography

Recommend font families, type scale, line heights, weights, and number styling.

## Spacing System

Define spacing tokens, usually based on 4px or 8px.

## Radius System

Define border radius tokens for controls, cards, panels, pills, and icons.

## Shadows And Borders

Define subtle elevation rules for light and dark mode.

## Shape Language

Explain recurring forms: cards, circles, pills, containers, rings, etc.

## Layout Direction

Explain landing page layout rules and product screen layout rules.

## Landing Page Art Direction

Define hero treatment, section rhythm, mockups, illustrations, backgrounds, and visual details.

## Product Screen Direction

Explain design rules for core screens such as dashboard, lists, detail pages, forms, settings, empty states, and alerts.

## Component Rules

Include practical rules for buttons, cards, inputs, tabs, badges/chips, navigation, modals/sheets, and empty states.

## Data Visualization

Explain chart types, chart colors, labeling, accessibility, and what to avoid.

## Iconography

Define icon style, stroke width, shape, good icon concepts, and forbidden icon directions.

## Illustration System

Define where illustrations are allowed, visual style, mascot usage, and what to avoid.

## Logo And App Icon Direction

Describe how the brand mark should appear in product and marketing contexts.

## Motion And Interaction

Define animation duration, easing, feedback, transitions, loading states, and reduced-motion expectations.

## Accessibility

Include contrast, touch target, font size, color meaning, reduced motion, and cognitive load rules.

## Responsive Rules

Define mobile, tablet, and desktop behavior.

## Landing Page Section Guide

Give recommended section order and purpose for each section.

## Product Component Examples

Provide practical examples of important cards or UI blocks.

## Design Do And Do Not

Summarize the strongest rules.

## Implementation Checklist

End with a checklist for reviewing whether a design is ready.
```

### Step 5: Make Tokens Implementation-Friendly

When token guidance is requested or project files indicate a token system, include concrete values.

For web projects, prefer CSS variables:

```css
:root {
  --color-background: #ffffff;
  --color-surface: #f8fafc;
  --color-text: #111827;
  --space-4: 1rem;
  --radius-card: 1rem;
}
```

For Tailwind projects, include Tailwind-compatible names and usage notes instead of replacing the entire config unless requested.

For React Native, Expo, or mobile app projects, include a compact theme object:

```ts
export const theme = {
  colors: {
    background: "#ffffff",
    surface: "#f8fafc",
    text: "#111827",
  },
  spacing: {
    4: 16,
  },
  radius: {
    card: 16,
  },
};
```

Use existing project values when present. If values are inferred, make them coherent and label them as recommended values, not established brand facts.

### Step 6: Include Practical UI Rules

Make each section useful for implementation.

Examples of practical specificity:

- Say which color is used for primary actions, focus rings, destructive actions, muted borders, and page backgrounds.
- Say whether cards are flat, outlined, tinted, glassy, elevated, dense, spacious, sharp, soft, geometric, or organic.
- Say how buttons differ by hierarchy and state.
- Say how empty states, loading states, and errors should look and feel.
- Say which chart colors map to positive, negative, neutral, warning, and comparison states.
- Say what visual moves are forbidden.

### Step 7: Final Quality Check

Before finishing, verify `DESIGN.md`:

- Is written in English.
- Reflects existing `BRANDING.md` or explicitly provided brand guidance.
- Does not duplicate the entire brand guide.
- Contains concrete implementation guidance, not only strategy.
- Includes colors with hex values when colors are discussed.
- Includes typography, spacing, radius, components, motion, accessibility, and responsive rules.
- Avoids generic SaaS phrasing and unexplained visual adjectives.
- Ends with an implementation checklist.

## Output Behavior

After creating or updating `DESIGN.md`, summarize:

- Which project context sources were used.
- Whether any design decisions were inferred due to missing information.
- Where the file was written.
