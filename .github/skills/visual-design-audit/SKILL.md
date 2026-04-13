---
name: visual-design-audit
description: "Use when systematically auditing pages or components against brand directives, checking color fidelity, typography consistency, mobile-first compliance, accessibility, and CRO patterns to generate a prioritized findings report. Do NOT use for implementing fixes, building new components, SEO audits, or performance profiling."
argument-hint: "audit scope, audit depth"
user-invocable: true
---

# Visual Design Audit and Brand Consistency Review

Systematically audit every page and component of the Garnebo website against brand directives, flag violations, and generate a prioritised list of actionable design improvements.

**Project:** Garnebo — Next.js 16 App Router, static export, Tailwind CSS v4, next-intl (it/en). **Brand identity:** Clean, modern, tech-enabled renovation company. "Anti-dust, anti-chaos" personality.

## When To Use

- Performing a pre-launch brand consistency check across all pages and shared components
- A specific page or component is suspected of using hardcoded hex colours, wrong font weights, or non-token classes
- Accessibility or colour contrast issues need to be catalogued before a sprint
- Generating a structured audit report (Critical / High / Low) with specific file and `className` references
- Verifying both `it` and `en` locales display correctly without layout overflow

**Do NOT use for:** implementing the fixes identified in an audit (delegate to relevant skill), building new components, SEO meta audits, or performance/bundle-size profiling.

## Inputs To Collect First

1. Audit scope — specific page(s), specific component(s), or full site
2. Audit depth — quick structural check or full review (brand colour + typography + mobile + accessibility + CRO)
3. Whether a written report is required or just an inline list of violations
4. Sprint deadline or priority constraint affecting ranking

## Procedure

### Step 1 — Gather Audit Scope

Before making any changes, enumerate every file to audit:
```bash
find src/app -name 'page.tsx'
find src/components -name '*.tsx'
find src/app -name 'layout.tsx'
```

### Step 2 — Brand Identity Check (per component/page)

For every file, mark `✅ PASS` / `⚠️ WARN` / `❌ FAIL`:

**Color fidelity**
- [ ] Background uses only `bg-bg-primary`, `bg-bg-white`, `bg-bg-dark`, or transparent
- [ ] Body text uses `text-brand-primary` or `text-brand-secondary` (no arbitrary hex)
- [ ] CTAs use `bg-brand-primary` with `text-white`, hover is `hover:bg-accent-blue`
- [ ] No hardcoded hex in className

**Typography**
- [ ] All visible text uses Inter via `font-sans`
- [ ] `font-bold` only for H1 and wordmark; `font-semibold` for H2–H3 and CTA labels
- [ ] `font-light` / `font-extralight` only for decorative sub-labels and micro-copy
- [ ] No `text-sm`, `text-lg` etc. — project uses explicit pixel sizes: `text-[13px]`, `text-[16px]`, `text-[17px]`, `text-[20px]`, `text-[24px]`, `text-[26px]`, `text-[36px]`, `text-[52px]`

**Spacing & negative space**
- [ ] Section vertical padding: minimum `py-16 md:py-24`
- [ ] Content containers: `max-w-3xl` or `max-w-5xl`
- [ ] Card internal padding ≥ `p-6 md:p-8`

**Consistency signals**
- [ ] Interactive elements use `rounded-md`; cards use `rounded-lg`
- [ ] `transition-colors` on all interactive elements
- [ ] `shadow-sm` on cards; `hover:shadow-md` only where needed

### Step 3 — CRO and Conversion Pattern Check

- [ ] Every page has exactly one primary CTA pointing to `/quote`
- [ ] Hero: H1 + sub-headline + primary CTA + secondary text link
- [ ] `MobileStickyBar` included in `[locale]/layout.tsx`
- [ ] `WhatsAppWidget` included globally
- [ ] Header has "Get a Quote" always visible on desktop
- [ ] No page requires more than 2 taps/clicks to reach the quote form

### Step 4 — Mobile-First Compliance

- [ ] Every multi-column grid uses `md:grid-cols-*` (single column by default)
- [ ] All interactive elements have touch targets ≥ 44×44 px
- [ ] No horizontal overflow on mobile
- [ ] No fixed pixel widths on `<img>`

### Step 5 — Accessibility Check

- [ ] All icon buttons have `aria-label`
- [ ] `aria-expanded` on accordion triggers
- [ ] Colour contrast ≥ 4.5:1 for body text (`#65695B` on `#EBE0DD` = 4.6:1 ✅; white on `#4C6170` = 5.1:1 ✅)
- [ ] Semantic `<nav>` for all navigation blocks
- [ ] Descriptive `alt` text on all images

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

### Step 7 — Propose Fixes

For each `Critical` and `High` finding:
1. Show the current code snippet
2. Show the corrected version with explanation
3. Apply the fix using the appropriate tool

**Brand voice quick reference:**

| Attribute | Do | Don't |
|---|---|---|
| Tone | Confident, precise, reassuring | Casual, playful, aggressive |
| CTA copy | "Get a Free Quote", "Start Your Project" | "Click here", "Submit", "Contact" |
| Eyebrow labels | ALL CAPS, `tracking-wider`, `text-[13px]` | Sentence case |

> **Constraints:** Do NOT introduce new colour tokens without updating `@theme {}`. Do NOT use Tailwind colour utilities outside brand tokens. Do NOT remove z-index layering on sticky elements without re-testing. Do NOT make changes without testing both `it` and `en` locales.

## Completion Checks

- [ ] All page files enumerated before starting
- [ ] All component files enumerated before starting
- [ ] Every file assessed with ✅ PASS / ⚠️ WARN / ❌ FAIL
- [ ] Color fidelity verified — no arbitrary hex, correct background/text token pairings
- [ ] Typography verified — correct font weights, explicit pixel sizes, responsive scale pairs
- [ ] Mobile-first verified — single-column defaults, 44 px touch targets, no overflow
- [ ] Accessibility verified — `aria-label`, `alt` text, contrast ratios ≥4.5:1, `<nav>` semantics
- [ ] CRO patterns verified — one primary CTA per section, `MobileStickyBar` present, `WhatsAppWidget` present
- [ ] Findings classified as Critical / High / Low with specific file path and `className` reference
- [ ] Both `it` and `en` locale text lengths verified

## References

No external references required.
