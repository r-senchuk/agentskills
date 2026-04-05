---
name: mobile-first-layout
description: "Use when designing or implementing responsive page layouts, grid systems, section shells, touch targets, CTA button stacking, or viewport-edge handling for a Tailwind CSS v4 Next.js site targeting 75%+ mobile traffic. Do NOT use for component-level styling, design token changes, z-index or sticky UI work."
argument-hint: "layout pattern (hero/grid/sidebar/timeline), desktop column count, background treatment"
user-invocable: true
---

# Skill: Mobile-First Responsive Layout Patterns

## Purpose

Design and implement responsive layouts for the Garnebo site that work flawlessly on mobile (375px+) first, then scale gracefully to tablet and desktop — using Tailwind CSS v4 with the project's established token system.

## Context

**Assumed traffic split:** 75%+ mobile. Every layout decision must start from a single-column, thumb-friendly mobile state.
**Breakpoints (Tailwind defaults, unchanged in v4):**
- No prefix → mobile (0px+)
- `sm:` → 640px+
- `md:` → 768px+
- `lg:` → 1024px+
- `xl:` → 1280px+
**Max content width:** `max-w-7xl` for nav/shell, `max-w-5xl` for content grids, `max-w-3xl` for centered copy blocks.

## When To Use

- Building a new page section that must work on 375 px mobile and scale to tablet and desktop
- A multi-column grid or flex layout needs to collapse correctly to a single column on mobile
- CTA button groups need to stack vertically on mobile and go horizontal on wider screens
- A hero section needs `min-height`, background image layer, and text overlay at all breakpoints
- A layout is causing horizontal scroll or overflowing its container on narrow viewports

**Do NOT use for:** design token changes (use `tailwind-v4-theming`), z-index or sticky element work (use `floating-sticky-ui`), or typography token audits (use `typography-color-tokens`).

## Inputs To Collect First

1. Layout pattern type (hero, feature grid, 2-column timeline, 2/3+1/3 sidebar, testimonial row, full-bleed image, etc.)
2. Number of desktop columns and whether items are fixed or dynamic in count
3. Background treatment (solid brand colour, background image with overlay, transparent)
4. Whether the section contains CTA buttons that need to stack on mobile

## Procedure

### Step 1 — Assess the Layout Need

Identify the layout type before writing any code:

| Pattern              | Mobile             | Desktop              | Use for                        |
|----------------------|--------------------|----------------------|--------------------------------|
| **Hero section**     | Single column, centered text | Side-by-side text + image | Landing page top section |
| **Feature grid**     | 1 column           | 2 or 3 columns       | Service cards, benefit lists   |
| **Testimonial row**  | Vertical stack     | Horizontal scrollable or 3-col | Social proof blocks |
| **Timeline**         | Vertical with left-connector | Horizontal with top-connector | How It Works steps |
| **Detail + aside**   | Stacked full-width | 2/3 + 1/3 columns    | Article + sidebar, FAQ + CTA   |
| **Full-bleed image** | `min-h-[300px]`    | `min-h-[520px] md:min-h-[640px]` | Hero backgrounds |

### Step 2 — Section Shell Template

Every page section uses this wrapper pattern:

```tsx
<section className="bg-bg-white px-4 py-16 sm:px-6 md:py-24 lg:px-8">
  <div className="mx-auto max-w-5xl">
    {/* content */}
  </div>
</section>
```

**Variants:**
- Narrow prose: `max-w-3xl` instead of `max-w-5xl`
- Dark background: replace `bg-bg-white` with `bg-bg-dark`
- No background: omit `bg-*` (uses inherited `bg-bg-primary`)
- Full-bleed: remove `px-*` from outer `<section>`, keep container inner

### Step 3 — Grid Layouts

**2-column (50/50):**
```tsx
<div className="grid gap-8 md:grid-cols-2">
  <div>...</div>
  <div>...</div>
</div>
```

**3-column equal:**
```tsx
<div className="grid gap-8 md:grid-cols-3">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

**2/3 + 1/3 sidebar:**
```tsx
<div className="grid gap-8 lg:grid-cols-[2fr_1fr]">
  <main>...</main>
  <aside>...</aside>
</div>
```

**Auto-fit responsive (when item count is dynamic):**
```tsx
<div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
  {/* Fills columns responsively */}
</div>
```

### Step 4 — Typography Scaling (Mobile → Desktop)

Always use the dual-size pattern:
```tsx
<h1 className="text-[36px] font-bold leading-tight text-brand-primary md:text-[52px]">
<h2 className="text-[26px] font-semibold text-brand-primary md:text-[36px]">
<h3 className="text-[20px] font-semibold text-brand-primary md:text-[24px]">
<p  className="text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
```

### Step 5 — Touch Target Compliance

All interactive elements must meet 44×44 px minimum:

```tsx
{/* Button: py-3 = 12px × 2 + 16px line-height + borders = ~44px */}
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
  <Link
    href="/quote"
    className="w-full rounded-md bg-brand-primary px-8 py-3 text-center text-[16px] font-semibold text-white transition-colors hover:bg-accent-blue sm:w-auto"
  >
    Get a Free Quote
  </Link>
  <Link
    href="/how-it-works"
    className="text-[16px] font-semibold text-brand-primary underline underline-offset-4 transition-colors hover:text-accent-blue"
  >
    See How It Works
  </Link>
</div>
```

### Step 7 — Hero Section with Background Image

Static export compatible (uses `fill` with `position: relative` container):

```tsx
<section className="relative overflow-hidden min-h-[520px] md:min-h-[640px] px-4 pb-16 pt-20 sm:px-6 md:pb-24 md:pt-28 lg:px-8">
  {/* Background image layer */}
  <Image
    src="/hero-image.webp"
    alt="Descriptive alt text"
    fill
    priority
    sizes="100vw"
    className="object-cover object-center z-0"
    unoptimized  {/* Required for static export */}
  />
  {/* Gradient overlay for text legibility */}
  <div className="absolute inset-0 z-10 bg-gradient-to-r from-[#F0EBD8]/90 via-[#F0EBD8]/70 to-transparent" />
  {/* Text content */}
  <div className="relative z-20 mx-auto max-w-4xl text-center">
    <h1 className="text-[36px] font-bold leading-tight text-brand-primary md:text-[52px]">
      Heading
    </h1>
  </div>
</section>
```

### Step 8 — Card Grids with Hover States

```tsx
<div className="grid gap-8 md:grid-cols-3">
  {cards.map((card) => (
    <Link
      key={card.id}
      href="/services"
      className="group block rounded-lg bg-bg-primary/50 p-6 transition-shadow hover:shadow-md md:p-8"
    >
      <h3 className="text-[20px] font-semibold text-brand-primary transition-colors group-hover:text-accent-blue md:text-[24px]">
        {card.title}
      </h3>
      <p className="mt-3 text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
        {card.body}
      </p>
    </Link>
  ))}
</div>
```

### Step 9 — Handling Text Overflow for i18n

Italian and English strings differ in length. Prevent layout breaks:

```tsx
{/* Prevent wrapping issues in navigation */}
<span className="whitespace-nowrap">Get a Quote</span>

{/* Allow long Italian words to break */}
<p className="break-words leading-relaxed">
  {t('longItalianParagraph')}
</p>

{/* Eyebrow labels: constrain to single line with ellipsis if needed */}
<p className="truncate text-[13px] uppercase tracking-wider">
  {t('eyebrow')}
</p>
```

### Step 10 — Safe Area & Viewport Edge Handling

Account for iPhone notch/home bar on sticky elements:

```tsx
{/* Mobile sticky bottom bar — clear the home indicator */}
<div className="fixed bottom-0 left-0 right-0 pb-safe">
  {/* pb-safe = env(safe-area-inset-bottom) — add to globals.css if needed */}
</div>
```

Add to `globals.css` if targeting iOS safe areas:
```css
@layer utilities {
  .pb-safe {
    padding-bottom: env(safe-area-inset-bottom, 0px);
  }
}
```

## Layout Checklist (Before Shipping)

- [ ] Opens on 375px width without horizontal scroll
- [ ] All interactive elements ≥ 44×44px tap target
- [ ] Multi-column grids collapse to single column on mobile
- [ ] Button groups stack vertically on mobile (`flex-col sm:flex-row`)
- [ ] Images are contained and don't overflow their parents
- [ ] Section padding is `py-16` mobile / `md:py-24` desktop
- [ ] Hero min-height specified for both mobile and desktop
- [ ] Text is legible on all background combinations (check contrast)
- [ ] Both `it` and `en` text lengths tested at each breakpoint

## Constraints & Anti-Patterns

- **DO NOT** design desktop-first and retrofit mobile — always start with the zero-prefix (mobile) state
- **DO NOT** use fixed pixel widths on containers — use `max-w-*` with `w-full`
- **DO NOT** use `flex-wrap` as a layout strategy for grids — use `grid` instead
- **DO NOT** specify `px-*` inside grid children — outer containers handle horizontal rhythm
- **DO NOT** use `overflow-x: scroll` on sections — all content must fit the viewport
- **AVOID** `absolute` positioning for layout — reserve it for decorative overlays and sticky elements

## Invocation Examples

- "Make the Services page grid responsive for mobile"
- "Create a new 3-column feature grid section that stacks on mobile"
- "Fix the hero section so it looks good on iPhone 12"
- "Add a 2/3 + 1/3 sidebar layout to the How It Works page"
- "Check all pages for mobile overflow issues"

## Completion Checks

- [ ] No horizontal scroll at 375 px viewport width (check with browser devtools or `overflow-x` audit)
- [ ] All multi-column grids use `md:grid-cols-*` — default state is single column (no prefix)
- [ ] All interactive elements meet 44×44 px minimum touch target (verify `py-3 px-5` on buttons, or explicit `h-11 w-11`)
- [ ] Button groups use `flex-col sm:flex-row` pattern — not `flex-row` by default
- [ ] Section outer wrapper uses `py-16 md:py-24` vertical padding
- [ ] Hero section declares `min-h-[520px] md:min-h-[640px]`
- [ ] Images are contained within their parent element and do not overflow on mobile
- [ ] No fixed pixel widths on any `<img>` or container element
- [ ] Both `it` and `en` locale text lengths verified at all intended breakpoints

## References

No external references required.
