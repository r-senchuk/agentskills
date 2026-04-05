---
name: tailwind-v4-theming
description: "Use when adding, modifying, or debugging Tailwind CSS v4 design tokens inside the @theme block, extracting repeated utility patterns with @layer components, or troubleshooting a missing or broken utility class in globals.css. Do NOT use for Tailwind v3 projects, tailwind.config.ts changes, general CSS layout work, or component markup authoring."
argument-hint: "token type (color/font/spacing), token name and value, intended utility class"
user-invocable: true
---

# Skill: Tailwind CSS v4 Theming & Component Styling

## Purpose

Author, extend, and debug Tailwind CSS v4 design tokens and utility classes for the Garnebo site using the CSS-first `@theme {}` configuration approach — no `tailwind.config.ts` involved.

## Context

**Tailwind CSS version:** v4 — configuration is done entirely in CSS, not JavaScript.
**Config file:** `src/app/globals.css` — this is the single source of truth for all design tokens.
**Import:** `@import "tailwindcss"` (replaces the v3 `@tailwind base/components/utilities` directives).
**PostCSS:** `postcss.config.mjs` with `@tailwindcss/postcss` plugin.

### How `@theme {}` Works in v4

Tokens declared inside `@theme {}` are:
1. Exposed as CSS custom properties on `:root` automatically
2. Used to generate corresponding Tailwind utility classes

```css
/* src/app/globals.css */
@import "tailwindcss";

@theme {
  /* Colors → bg-*, text-*, border-*, etc. */
  --color-brand-primary: #4C6170;
  --color-accent-blue: #8A9EAB;

  /* Fonts → font-sans, font-serif, etc. */
  --font-sans: var(--font-inter);

  /* Spacing → p-*, m-*, gap-*, etc. */
  /* --spacing-section: 6rem; */

  /* Border radius → rounded-* */
  /* --radius-card: 0.5rem; */
}
```

This generates:
- `bg-brand-primary` → `background-color: #4C6170`
- `text-brand-primary` → `color: #4C6170`
- `border-brand-primary` → `border-color: #4C6170`
- `font-sans` → `font-family: var(--font-inter)`

### Current Token Map

```css
/* All tokens live in src/app/globals.css */
--color-bg-primary:    #EBE0DD   /* Warm off-white — page background */
--color-bg-white:      #FFFFFF   /* Pure white — contrast sections */
--color-bg-dark:       #4C6170   /* = brand-primary — dark backgrounds */
--color-brand-primary: #4C6170   /* Deep slate — primary text, headers */
--color-brand-secondary:#65695B  /* Olive-grey — body / supporting text */
--color-accent-blue:   #8A9EAB   /* Muted blue — links, hover, accents */
--color-accent-sage:   #9CA38E   /* Sage green — bullets, dividers, tags */
--font-sans:           var(--font-inter)  /* Inter via next/font */
```

## When To Use

- Adding a new colour, font family, or spacing token to `src/app/globals.css` using the CSS-first `@theme {}` block
- A Tailwind utility class derived from a custom token (e.g. `bg-brand-secondary`) is not generating or applying correctly
- A repeated multi-class pattern needs to be extracted into `@layer components` as a named utility
- Debugging why a token added inside `@theme {}` does not appear on `:root` in browser DevTools

**Do NOT use for:** creating or modifying `tailwind.config.ts` (v4 is CSS-only), Tailwind v3 projects, component markup changes, or page-level layout decisions.

## Inputs To Collect First

1. Token type to add or change (color, font family, spacing, or breakpoint)
2. Desired token name and value (e.g. `accent-terracotta: #C4704A`)
3. Intended Tailwind utility class(es) that should be generated from the token
4. Whether a component utility class needs extracting and how many usage sites exist across the codebase

## Procedure

### Step 1 — Adding a New Token

1. Open `src/app/globals.css`
2. Add the token inside the `@theme {}` block using the correct prefix:
   - Colors: `--color-<name>: <value>;`
   - Font families: `--font-<name>: <value>;`
   - Custom spacing: `--spacing-<name>: <value>;`
   - Breakpoints (rare): `--breakpoint-<name>: <value>;`
3. Use the generated utility class immediately — no rebuild needed in dev

```css
/* Example: adding an error/warning colour */
@theme {
  /* ...existing tokens... */
  --color-error: #C0392B;
  --color-warning-amber: #E8A838;
}
```

Generated classes: `bg-error`, `text-error`, `border-error`, `bg-warning-amber`, etc.

### Step 2 — Adding Component Base Styles

For repeated multi-class patterns, use `@layer components` **below** the `@theme {}` block:

```css
@layer components {
  .btn-primary {
    @apply rounded-md bg-brand-primary px-6 py-3 text-[16px] font-semibold text-white
           transition-colors hover:bg-accent-blue;
  }

  .btn-ghost {
    @apply text-[16px] font-semibold text-brand-primary underline underline-offset-4
           transition-colors hover:text-accent-blue;
  }

  .section-container {
    @apply mx-auto max-w-5xl px-4 sm:px-6 lg:px-8;
  }

  .section-container-narrow {
    @apply mx-auto max-w-3xl px-4 sm:px-6 lg:px-8;
  }
}
```

**Warning:** Only extract to `@layer components` when a pattern appears 3+ times across different files. Otherwise keep utilities inline.

### Step 3 — Typography Scale

The project uses explicit pixel sizes to avoid Tailwind's default fluid scale ambiguity:

| Class           | Size  | Usage                              |
|-----------------|-------|------------------------------------|
| `text-[13px]`   | 13px  | Micro-copy, eyebrows, badges, legal |
| `text-[16px]`   | 16px  | Body text, nav links, CTA buttons  |
| `text-[17px]`   | 17px  | Body text at `md:` (slight bump)   |
| `text-[20px]`   | 20px  | H3, card titles                    |
| `text-[24px]`   | 24px  | H3 at `md:` breakpoint             |
| `text-[26px]`   | 26px  | H2 default                         |
| `text-[36px]`   | 36px  | H2 at `md:`, H1 default            |
| `text-[52px]`   | 52px  | H1 at `md:` (hero headings)        |

**Always pair body sizes with responsive bumps:**
```tsx
className="text-[16px] md:text-[17px]"  // body
className="text-[26px] md:text-[36px]"  // h2
className="text-[36px] md:text-[52px]"  // h1
```

### Step 4 — Colour Opacity Modifiers

v4 supports opacity modifiers the same way as v3:

```tsx
// 30% opacity of accent-sage for dividers
className="border-accent-sage/30"

// 50% opacity for overlay backgrounds  
className="bg-brand-primary/50"

// 80% opacity for muted text on dark backgrounds
className="text-white/80"
```

These work on all colour utilities without extra config.

### Step 5 — Dark Background Sections

When using `bg-bg-dark` (which equals `brand-primary` #4C6170), switch text tokens:

```tsx
<section className="bg-bg-dark">
  {/* White text on dark */}
  <h2 className="text-white">...</h2>
  <p className="text-white/80">...</p>
  
  {/* Inverted CTA */}
  <Link className="bg-white text-brand-primary hover:bg-bg-primary">
    Get a Quote
  </Link>
</section>
```

### Step 6 — Debugging Token Issues

If a utility class isn't working:
1. Check `src/app/globals.css` — is the `--color-<name>` token present inside `@theme {}`?
2. Check for typos: token name must exactly match the class suffix
3. Run `pnpm dev` — HMR will pick up CSS changes instantly
4. Inspect the `:root` in DevTools — all `@theme` tokens appear there as CSS variables
5. Ensure `@import "tailwindcss"` is the **first** line (before `@theme {}`)

## Complete `globals.css` Reference Pattern

```css
@import "tailwindcss";

@theme {
  /* ─── Colors ─────────────────────────────────────── */
  --color-bg-primary:      #EBE0DD;
  --color-bg-white:        #FFFFFF;
  --color-bg-dark:         #4C6170;
  --color-brand-primary:   #4C6170;
  --color-brand-secondary: #65695B;
  --color-accent-blue:     #8A9EAB;
  --color-accent-sage:     #9CA38E;

  /* ─── Typography ─────────────────────────────────── */
  --font-sans: var(--font-inter);
}

/* ─── Global base styles ──────────────────────────── */
body {
  background-color: var(--color-bg-primary);
  color: var(--color-brand-primary);
}

/* ─── Component utilities (extract only if 3+ uses) ─ */
@layer components {
  /* Add component classes here when patterns repeat */
}
```

## Constraints & Anti-Patterns

- **DO NOT** create a `tailwind.config.ts` — v4 uses CSS-first config only
- **DO NOT** use `@tailwind base`, `@tailwind components`, `@tailwind utilities` — these are v3 directives
- **DO NOT** use Tailwind's built-in colour palette directly (no `bg-blue-500`, `text-gray-700`) — always use brand tokens
- **DO NOT** use `theme()` function in CSS — use `var(--color-*)` instead (v4 deprecates `theme()`)
- **DO NOT** add tokens outside `@theme {}` — they won't generate utility classes
- **DO NOT** use `@apply` inside `@theme {}` — `@apply` is only valid inside `@layer components` or regular rules
- **AVOID** overriding Tailwind defaults (e.g. `--color-white`) unless intentional — prefix custom tokens clearly

## Invocation Examples

- "Add a new `accent-terracotta` colour token to the design system"
- "Extract the CTA button styles into a reusable component class"
- "Why isn't `bg-brand-secondary` working in my component?"
- "Update the body text colour token to be slightly darker"
- "Show me all available design tokens for the Garnebo site"
- "Add a `--spacing-section` token for consistent vertical section padding"

## Completion Checks

- [ ] New token is declared inside the `@theme {}` block in `src/app/globals.css`
- [ ] Token uses the correct prefix for its type (`--color-*`, `--font-*`, `--spacing-*`, `--breakpoint-*`)
- [ ] Token name is kebab-case and semantically named by role, not by hue (e.g. `accent-terracotta`, not `color-orange`)
- [ ] The generated utility class is visible as a CSS custom property on `:root` in browser DevTools
- [ ] No `tailwind.config.ts` file was created or modified
- [ ] No v3 directives (`@tailwind base`, `@tailwind components`, `@tailwind utilities`) were added
- [ ] `@import "tailwindcss"` remains the first line in `globals.css` — nothing before it
- [ ] Component utility classes extracted to `@layer components` only when the pattern repeats 3 or more times across different files

## References

No external references required.
