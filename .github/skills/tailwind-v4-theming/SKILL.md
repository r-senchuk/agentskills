---
name: tailwind-v4-theming
description: "Use when adding, modifying, or debugging Tailwind CSS v4 design tokens inside the @theme block, extracting repeated utility patterns with @layer components, or troubleshooting a missing or broken utility class in globals.css. Do NOT use for Tailwind v3 projects, tailwind.config.ts changes, general CSS layout work, or component markup authoring."
argument-hint: "token type (color/font/spacing), token name and value, intended utility class"
user-invocable: true
---

# Tailwind CSS v4 Theming and Component Styling

Author, extend, and debug Tailwind CSS v4 design tokens and utility classes for the Garnebo site using the CSS-first `@theme {}` configuration approach — no `tailwind.config.ts` involved.

**Config file:** `src/app/globals.css` — single source of truth for all design tokens. **Import:** `@import "tailwindcss"` (replaces v3 directives). **PostCSS:** `postcss.config.mjs` with `@tailwindcss/postcss` plugin.

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
4. Whether a component utility class needs extracting and how many usage sites exist

## Procedure

### Step 1 — How @theme Works in v4

Tokens declared inside `@theme {}` are automatically exposed as CSS custom properties on `:root` and used to generate Tailwind utility classes:

```css
/* src/app/globals.css */
@import "tailwindcss";

@theme {
  /* Colors → bg-*, text-*, border-*, etc. */
  --color-brand-primary: #4C6170;
  --color-accent-blue: #8A9EAB;

  /* Fonts → font-sans, font-serif, etc. */
  --font-sans: var(--font-inter);
}
```

This generates: `bg-brand-primary`, `text-brand-primary`, `border-brand-primary`, `font-sans`, etc.

### Step 2 — Current Token Map

```css
--color-bg-primary:     #EBE0DD   /* Warm off-white — page background */
--color-bg-white:       #FFFFFF   /* Pure white — contrast sections */
--color-bg-dark:        #4C6170   /* = brand-primary — dark backgrounds */
--color-brand-primary:  #4C6170   /* Deep slate — primary text, headers */
--color-brand-secondary:#65695B   /* Olive-grey — body / supporting text */
--color-accent-blue:    #8A9EAB   /* Muted blue — links, hover, accents */
--color-accent-sage:    #9CA38E   /* Sage green — bullets, dividers, tags */
--font-sans:            var(--font-inter)
```

### Step 3 — Adding a New Token

1. Open `src/app/globals.css`
2. Add inside `@theme {}` with the correct prefix:
   - Colors: `--color-<name>: <value>;`
   - Font families: `--font-<name>: <value>;`
   - Custom spacing: `--spacing-<name>: <value>;`
3. Use the generated utility class immediately — no rebuild needed in dev

```css
@theme {
  /* existing tokens... */
  --color-error: #C0392B;
  --color-warning-amber: #E8A838;
}
```

Generated: `bg-error`, `text-error`, `border-error`, `bg-warning-amber`, etc.

### Step 4 — Extracting Component Base Styles

Use `@layer components` **below** `@theme {}` for patterns that appear 3+ times:

```css
@layer components {
  .btn-primary {
    @apply rounded-md bg-brand-primary px-6 py-3 text-[16px] font-semibold text-white
           transition-colors hover:bg-accent-blue;
  }

  .section-container {
    @apply mx-auto max-w-5xl px-4 sm:px-6 lg:px-8;
  }
}
```

**Only extract to `@layer components` when a pattern appears 3+ times** across different files.

### Step 5 — Typography Scale

Explicit pixel sizes — no Tailwind defaults:

| Class | Size | Usage |
|---|---|---|
| `text-[13px]` | 13px | Micro-copy, eyebrows, badges |
| `text-[16px]` | 16px | Body text, nav links, buttons |
| `text-[20px]` | 20px | H3, card titles |
| `text-[26px]` | 26px | H2 default |
| `text-[36px]` | 36px | H2 at `md:`, H1 default |
| `text-[52px]` | 52px | H1 at `md:` (hero) |

Always pair with responsive bumps: `text-[26px] md:text-[36px]`.

### Step 6 — Opacity Modifiers and Dark Sections

```tsx
{/* Opacity modifiers */}
className="border-accent-sage/30"    // 30% opacity
className="bg-brand-primary/50"      // 50% opacity

{/* Dark section text */}
<section className="bg-bg-dark">
  <h2 className="text-white">
  <p  className="text-white/80">
</section>
```

### Step 7 — Debugging Token Issues

1. Check `--color-<name>` is inside `@theme {}` in `globals.css`
2. Check for typos — token name must exactly match class suffix
3. Run `pnpm dev` — HMR picks up CSS changes instantly
4. Inspect `:root` in DevTools — all `@theme` tokens appear there
5. Ensure `@import "tailwindcss"` is the FIRST line

### Step 8 — Complete globals.css Reference Pattern

```css
@import "tailwindcss";

@theme {
  /* ─── Colors ───────────────────────── */
  --color-bg-primary:      #EBE0DD;
  --color-bg-white:        #FFFFFF;
  --color-bg-dark:         #4C6170;
  --color-brand-primary:   #4C6170;
  --color-brand-secondary: #65695B;
  --color-accent-blue:     #8A9EAB;
  --color-accent-sage:     #9CA38E;

  /* ─── Typography ───────────────────── */
  --font-sans: var(--font-inter);
}

body {
  background-color: var(--color-bg-primary);
  color: var(--color-brand-primary);
}

@layer components {
  /* Add component classes here when patterns repeat 3+ times */
}
```

> **Constraints:** Do NOT create `tailwind.config.ts` — v4 is CSS-first only. Do NOT use `@tailwind base/components/utilities` — v3 directives. Do NOT use Tailwind's built-in colour palette directly (no `bg-blue-500`). Do NOT use `theme()` function — use `var(--color-*)` instead. Do NOT add tokens outside `@theme {}`. Do NOT use `@apply` inside `@theme {}`.

## Completion Checks

- [ ] New token declared inside `@theme {}` in `src/app/globals.css`
- [ ] Token uses correct prefix for its type (`--color-*`, `--font-*`, `--spacing-*`)
- [ ] Token name is kebab-case, semantically named by role (e.g. `accent-terracotta`, not `color-orange`)
- [ ] Generated utility class visible as CSS custom property on `:root` in DevTools
- [ ] No `tailwind.config.ts` file created or modified
- [ ] No v3 directives added
- [ ] `@import "tailwindcss"` remains the first line in `globals.css`
- [ ] `@layer components` extraction only when pattern repeats 3+ times across different files

## References

No external references required.
