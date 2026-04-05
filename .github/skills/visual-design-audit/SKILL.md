---
name: visual-design-audit
description: "Use when systematically auditing pages or components against brand directives — checking color fidelity, typography consistency, mobile-first compliance, accessibility, and CRO patterns to generate a prioritised Critical/High/Low findings report. Do NOT use for implementing design fixes, building new components, SEO audits, or performance profiling."
argument-hint: "audit scope (page name, component name, or all), audit depth (quick/full)"
user-invocable: true
---

# Skill: Visual Design Audit & Brand Consistency Review

## Purpose

Systematically audit every page and component of the Garnebo website against brand directives, flag violations, and generate a prioritised list of actionable design improvements.

## Context

**Project:** Garnebo — Next.js 16 App Router, static export, Tailwind CSS v4, next-intl (it/en)
**Brand identity:** Clean, modern, tech-enabled renovation company. "Anti-dust, anti-chaos" personality.
**Current design tokens** (defined in `src/app/globals.css` `@theme {}`):

| Token              | Value     | Role                        |
|--------------------|-----------|-----------------------------|
| `--color-bg-primary`    | `#EBE0DD` | Warm off-white background   |
| `--color-bg-white`      | `#FFFFFF` | Section contrast background |
| `--color-brand-primary` | `#4C6170` | Deep slate — headers, CTAs  |
| `--color-brand-secondary`| `#65695B`| Olive-grey — body text      |
| `--color-accent-blue`   | `#8A9EAB` | Muted blue — links, accents |
| `--color-accent-sage`   | `#9CA38E` | Sage green — bullets, dividers |

**Existing components to audit:**
`Header`, `Footer`, `CTABanner`, `MobileStickyBar`, `WhatsAppWidget`, `ServiceCard`, `ComplianceCard`, `TimelineStep`, `FAQAccordion`

## When To Use

- Performing a pre-launch brand consistency check across all pages and shared components
- A specific page or component is suspected of using hardcoded hex colours, wrong font weights, or non-token classes
- Accessibility or colour contrast issues need to be catalogued and prioritised before a sprint
- Generating a structured audit report (Critical / High / Low) with specific file and `className` references
- Verifying both `it` and `en` locales display correctly without layout overflow

**Do NOT use for:** implementing the fixes identified in an audit (delegate to relevant skill), building new components, SEO meta audits, or performance/bundle-size profiling.

## Inputs To Collect First

1. Audit scope — specific page(s), specific component(s), or full site
2. Audit depth — quick structural check or full review (brand colour + typography + mobile + accessibility + CRO)
3. Whether a written report is required or just an inline list of violations
4. Sprint deadline or priority constraint affecting how findings should be ranked

## Procedure

### Step 1 — Gather Audit Scope

Before making any changes, enumerate every file to audit:
1. List all page files: `find src/app -name 'page.tsx'`
2. List all components: `find src/components -name '*.tsx'`
3. List all layout files: `find src/app -name 'layout.tsx'`

### Step 2 — Brand Identity Check (per component/page)

For every file, check the following and note `✅ PASS` / `⚠️ WARN` / `❌ FAIL`:

**Color fidelity**
- [ ] Background uses only `bg-bg-primary`, `bg-bg-white`, `bg-bg-dark`, or transparent
- [ ] All body text uses `text-brand-primary` or `text-brand-secondary` (never arbitrary hex)
- [ ] CTAs use `bg-brand-primary` with `text-white`, hover state is `hover:bg-accent-blue`
- [ ] No hardcoded hex colours in className props (except gradient overlays)

**Typography**
- [ ] All visible text uses the Inter font stack (via `font-sans` → `var(--font-inter)`)
- [ ] `font-bold` only for H1 and wordmark; `font-semibold` for H2–H3 and CTA labels
- [ ] `font-light` / `font-extralight` only for decorative sub-labels and micro-copy
- [ ] No `text-sm`, `text-lg` etc. — project uses explicit pixel sizes: `text-[13px]`, `text-[16px]`, `text-[17px]`, `text-[20px]`, `text-[24px]`, `text-[26px]`, `text-[36px]`, `text-[52px]`

**Spacing & negative space**
- [ ] Section vertical padding: minimum `py-16 md:py-24`
- [ ] Content containers: `max-w-3xl` (narrow/centered copy) or `max-w-5xl` (wide grids), never full-bleed text
- [ ] No cramped elements — all card internal padding ≥ `p-6 md:p-8`

**Consistency signals**
- [ ] All rounded corners on interactive elements use `rounded-md` (not `rounded`, `rounded-lg` only on cards)
- [ ] Transition classes on all interactive elements: `transition-colors` minimum
- [ ] Shadow on cards: `shadow-sm` default, `hover:shadow-md` only when needed

### Step 3 — CRO & Conversion Pattern Check

- [ ] Every page has exactly one primary CTA pointing to `/quote`
- [ ] Hero section present on home page: H1 + sub-headline + primary CTA + secondary text link
- [ ] `MobileStickyBar` included in `[locale]/layout.tsx` (appears on all pages)
- [ ] `WhatsAppWidget` included globally in `[locale]/layout.tsx`
- [ ] Header has "Get a Quote" CTA button always visible on desktop
- [ ] No page requires more than 2 taps/clicks to reach the quote form

### Step 4 — Mobile-First Compliance Check

- [ ] Every multi-column grid uses `md:grid-cols-*` (mobile-first, single column by default)
- [ ] All interactive elements have touch targets ≥ 44×44 px (check `py-3 px-5` on buttons)
- [ ] No horizontal overflow on mobile (check for missing `overflow-hidden` on containers)
- [ ] Images use `w-full` or constrained within containers — no fixed pixel widths on `<img>`

### Step 5 — Accessibility Check

- [ ] All interactive elements have `aria-label` when text is absent (icon buttons, toggles)
- [ ] `aria-expanded` set on accordion triggers
- [ ] Colour contrast ≥ 4.5:1 for body text on all background combinations
  - `#65695B` on `#EBE0DD` → ratio ≈ 4.6:1 ✅
  - `#4C6170` on `#FFFFFF` → ratio ≈ 6.1:1 ✅
  - White text on `#4C6170` → ratio ≈ 5.1:1 ✅
- [ ] `role="navigation"` or semantic `<nav>` used for all nav blocks
- [ ] `alt` text on all `<Image>` / `<img>` tags (descriptive, not filename)

### Step 6 — Compile Audit Report

Structure findings as:

```
## Visual Design Audit — [Date]

### Critical (fix before launch)
- [COMPONENT] [Description] [Specific className to fix]

### High (fix in next sprint)
- ...

### Low / Cosmetic (backlog)
- ...

### Passed
- ...
```

### Step 7 — Propose & Implement Fixes

For each `Critical` and `High` finding:
1. Show the current code snippet
2. Show the corrected version with explanation
3. Apply the fix using the `edit` tool

## Brand Voice Quick Reference

| Attribute       | Do                                        | Don't                              |
|-----------------|-------------------------------------------|------------------------------------|
| Tone            | Confident, precise, reassuring            | Casual, playful, aggressive        |
| Vocabulary      | "organised", "coordinated", "transparent" | "amazing", "incredible", "hassle"  |
| CTA copy        | "Get a Free Quote", "Start Your Project"  | "Click here", "Submit", "Contact"  |
| Eyebrow labels  | ALL CAPS, `tracking-wider`, `text-[13px]` | Sentence case, decorative fonts    |

## Constraints & Anti-Patterns

- **DO NOT** introduce new colour tokens without updating `src/app/globals.css @theme {}`
- **DO NOT** use Tailwind colour utilities that don't map to brand tokens (no `bg-blue-600`, `text-gray-700`)
- **DO NOT** remove existing `z-index` layering on sticky/fixed elements without re-testing overlap
- **DO NOT** change heading hierarchy (H1 → H2 → H3) without checking SEO impact
- **DO NOT** make visual changes without testing both `it` and `en` locales (text lengths differ)

## Invocation Examples

- "Audit the home page for brand consistency"
- "Check all components against the Garnebo design system"
- "Find any hardcoded colours not using design tokens"
- "Generate a full visual audit report for garnebo.com"
- "What design improvements does the Services page need?"

## Completion Checks

- [ ] All page files enumerated before starting (`find src/app -name 'page.tsx'`)
- [ ] All component files enumerated before starting (`find src/components -name '*.tsx'`)
- [ ] Every file assessed with ✅ PASS / ⚠️ WARN / ❌ FAIL status label
- [ ] Color fidelity verified — no arbitrary hex in `className`, correct background/text token pairings
- [ ] Typography verified — correct font weights per heading level, explicit pixel sizes, responsive scale pairs
- [ ] Mobile-first compliance verified — single-column mobile defaults, 44 px touch targets, no overflow
- [ ] Accessibility verified — `aria-label` on icon buttons, `alt` text on all images, contrast ratios ≥4.5:1, `<nav>` semantics
- [ ] CRO patterns verified — one primary CTA per section, `MobileStickyBar` present globally, `WhatsAppWidget` present globally
- [ ] Findings classified as Critical / High / Low with specific file path and `className` or line reference
- [ ] Both `it` and `en` locale text lengths verified for any text-length-sensitive layout (nav, buttons, headings)

## References

No external references required.
