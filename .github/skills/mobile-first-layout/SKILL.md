---
name: mobile-first-layout
description: "Use when designing or implementing responsive page layouts, grid systems, section shells, touch targets, CTA button stacking, or viewport-edge handling for a Tailwind CSS v4 Next.js site targeting 75%+ mobile traffic. Do NOT use for component-level styling, design token changes, z-index or sticky UI work."
argument-hint: "layout pattern (hero/grid/sidebar/timeline), desktop column count, background treatment"
user-invocable: true
---

# Mobile-First Responsive Layout Patterns

Design and implement responsive layouts for the Garnebo site that work flawlessly on mobile (375px+) first, then scale gracefully to tablet and desktop using Tailwind CSS v4 with the project token system.

**Traffic split:** 75%+ mobile. Every layout decision must start from a single-column, thumb-friendly mobile state. Breakpoints: no prefix = mobile (0px+), `sm:` = 640px+, `md:` = 768px+, `lg:` = 1024px+. Max content width: `max-w-7xl` for nav/shell, `max-w-5xl` for content grids, `max-w-3xl` for centered copy blocks.

## When To Use

- Building a new page section that must work on 375 px mobile and scale to tablet and desktop
- A multi-column grid or flex layout needs to collapse correctly to a single column on mobile
- CTA button groups need to stack vertically on mobile and go horizontal on wider screens
- A hero section needs `min-height`, background image layer, and text overlay at all breakpoints
- A layout is causing horizontal scroll or overflowing its container on narrow viewports

**Do NOT use for:** design token changes (use `tailwind-v4-theming`), z-index or sticky element work (use `floating-sticky-ui`), or typography token audits (use `typography-color-tokens`).

## Inputs To Collect First

1. Layout pattern type (hero, feature grid, 2-column timeline, 2/3+1/3 sidebar, testimonial row, etc.)
2. Number of desktop columns and whether items are fixed or dynamic in count
3. Background treatment (solid brand colour, background image with overlay, transparent)
4. Whether the section contains CTA buttons that need to stack on mobile

## Procedure

### Step 1 — Identify the Layout Pattern

| Pattern | Mobile | Desktop | Use for |
|---|---|---|---|
| Hero section | Single column, centered text | Side-by-side text + image | Landing page top |
| Feature grid | 1 column | 2 or 3 columns | Service cards, benefit lists |
| Testimonial row | Vertical stack | Horizontal or 3-col | Social proof blocks |
| Timeline | Vertical with left-connector | Horizontal with top-connector | How It Works steps |
| Detail + aside | Stacked full-width | 2/3 + 1/3 columns | Article + sidebar |
| Full-bleed image | `min-h-[300px]` | `min-h-[520px] md:min-h-[640px]` | Hero backgrounds |

### Step 2 — Section Shell Template

Every page section uses this wrapper pattern:

```tsx
<section className="bg-bg-white px-4 py-16 sm:px-6 md:py-24 lg:px-8">
  <div className="mx-auto max-w-5xl">
    {/* content */}
  </div>
</section>
```

Variants: narrow prose → `max-w-3xl`; dark background → `bg-bg-dark`; full-bleed → remove `px-*` from outer `<section>`.

### Step 3 — Grid Layouts

```tsx
{/* 2-column (50/50) */}
<div className="grid gap-8 md:grid-cols-2">

{/* 3-column equal */}
<div className="grid gap-8 md:grid-cols-3">

{/* 2/3 + 1/3 sidebar */}
<div className="grid gap-8 lg:grid-cols-[2fr_1fr]">

{/* Auto-fit (dynamic count) */}
<div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
```

### Step 4 — Typography Scaling

Always use the dual-size pattern:

```tsx
<h1 className="text-[36px] font-bold leading-tight text-brand-primary md:text-[52px]">
<h2 className="text-[26px] font-semibold text-brand-primary md:text-[36px]">
<h3 className="text-[20px] font-semibold text-brand-primary md:text-[24px]">
<p  className="text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
```

### Step 5 — Touch Target Compliance

All interactive elements must meet 44x44 px minimum:

```tsx
{/* Button: py-3 achieves ~44px */}
<button className="px-6 py-3 text-[16px]">CTA</button>

{/* Icon button: explicit sizing */}
<button className="flex h-11 w-11 items-center justify-center">
  <svg className="h-5 w-5" />
</button>

{/* Nav links: add padding for tap area */}
<Link className="py-2 px-1 text-[16px]">Link</Link>
```

### Step 6 — Stacking Multi-Column CTAs

Button groups that are horizontal on desktop, stacked on mobile:

```tsx
<div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
  <Link href="/quote"
    className="w-full rounded-md bg-brand-primary px-8 py-3 text-center text-[16px] font-semibold text-white transition-colors hover:bg-accent-blue sm:w-auto">
    Get a Free Quote
  </Link>
  <Link href="/how-it-works"
    className="text-[16px] font-semibold text-brand-primary underline underline-offset-4 transition-colors hover:text-accent-blue">
    See How It Works
  </Link>
</div>
```

### Step 7 — Hero Section with Background Image

```tsx
<section className="relative overflow-hidden min-h-[520px] md:min-h-[640px] px-4 pb-16 pt-20 sm:px-6 md:pb-24 md:pt-28 lg:px-8">
  <Image src="/hero-image.webp" alt="..." fill priority sizes="100vw"
    className="object-cover object-center z-0" unoptimized />
  <div className="absolute inset-0 z-10 bg-gradient-to-r from-[#F0EBD8]/90 via-[#F0EBD8]/70 to-transparent" />
  <div className="relative z-20 mx-auto max-w-4xl text-center">
    <h1 className="text-[36px] font-bold leading-tight text-brand-primary md:text-[52px]">
      Heading
    </h1>
  </div>
</section>
```

### Step 8 — Safe Area and Viewport Edge Handling

```tsx
{/* Mobile sticky bottom bar */}
<div className="fixed bottom-0 left-0 right-0 pb-safe">
  {/* pb-safe = env(safe-area-inset-bottom) */}
</div>
```

```css
/* globals.css */
@layer utilities {
  .pb-safe {
    padding-bottom: env(safe-area-inset-bottom, 0px);
  }
}
```

### Step 9 — Handling Text Overflow for i18n

Italian and English strings differ in length:

```tsx
{/* Prevent wrapping in navigation */}
<span className="whitespace-nowrap">Get a Quote</span>

{/* Allow long Italian words to break */}
<p className="break-words leading-relaxed">{t('longItalianParagraph')}</p>

{/* Eyebrow labels: constrain to single line */}
<p className="truncate text-[13px] uppercase tracking-wider">{t('eyebrow')}</p>
```

> **Constraints:** Always design mobile-first (zero-prefix state first, then `sm:`, `md:`, `lg:`). Do NOT use fixed pixel widths on containers. Do NOT use `flex-wrap` as a layout strategy for grids — use `grid`. Do NOT use `overflow-x: scroll` on sections. Avoid `absolute` positioning for layout (reserve for overlays).

## Completion Checks

- [ ] No horizontal scroll at 375 px viewport width
- [ ] All multi-column grids use `md:grid-cols-*` — default state is single column (no prefix)
- [ ] All interactive elements meet 44x44 px minimum touch target
- [ ] Button groups use `flex-col sm:flex-row` pattern
- [ ] Section outer wrapper uses `py-16 md:py-24` vertical padding
- [ ] Hero section declares `min-h-[520px] md:min-h-[640px]`
- [ ] Images contained within parent and do not overflow on mobile
- [ ] No fixed pixel widths on any `<img>` or container element
- [ ] Both `it` and `en` locale text lengths verified at all intended breakpoints

## References

No external references required.
