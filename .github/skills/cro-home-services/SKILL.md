---
name: cro-home-services
description: "Use when designing or auditing conversion rate optimisation UX patterns for a home services renovation website — including hero headlines, CTA placement, social proof blocks, urgency copy, and quote funnel friction reduction. Do NOT use for backend analytics setup, A/B test infrastructure, or general marketing copy unrelated to home services."
argument-hint: "target page or section, conversion problem, current CTA copy and destination"
user-invocable: true
---

# Skill: Conversion Rate Optimisation (CRO) UI Patterns — Home Services

## Purpose

Design and implement high-converting UX patterns specific to residential renovation and home services businesses on the Garnebo website, using evidence-backed conversion architecture.

## Context

**Business model:** B2C renovation project management in Bologna, Italy. Primary conversion goal: visitor submits quote request (reaches `/quote` page and completes Typeform/Tally embed).
**Audience:** Homeowners planning renovations. Pain points: fear of unreliable contractors, project chaos, hidden costs, compliance issues. Trust-deficit is the #1 conversion blocker.
**Traffic profile:** 75%+ mobile, high intent (searching for renovation services). Low patience for friction.

## CRO Principles for Home Services

1. **Trust before action** — Establish credibility before showing the primary CTA
2. **Reduce perceived risk** — Show compliance, insurance, portfolio before asking for commitment
3. **One clear next step** — Every section ends with a single unambiguous action
4. **Friction removal** — Fewer fields, photo upload, WhatsApp option, no account creation
5. **Social proof density** — Multiple trust signals across the entire page journey

## When To Use

- The home page hero section needs stronger CTA click-through or a more outcome-focused headline
- A social proof block, testimonial card, or numbered stats section needs to be added or improved
- The quote funnel has high drop-off and needs friction analysis and WhatsApp alternative CTA
- Urgency or scarcity messaging needs to be added to a page without using fake tactics
- CTA button copy, placement rules, or page-level conversion architecture need review

**Do NOT use for:** backend event tracking, A/B test tooling, SEO meta copy, non-Garnebo or non-home-services projects.

## Inputs To Collect First

1. Target page or section (home page hero, services page, quote page, footer CTA, etc.)
2. Specific conversion problem to solve (low CTA rate, high bounce, form abandonment, etc.)
3. Existing CTA copy and destination URL
4. Available trust assets (testimonials, project count, certifications, team photos)

## Procedure

### Step 1 — Page-Level Conversion Architecture

Every page follows this flow:

```
AWARENESS (Hook / Headline)
    ↓
PROBLEM AGITATION (Pain points the user recognises)
    ↓
PROOF (Before/After, testimonials, compliance badges)
    ↓
SOLUTION (How Garnebo solves it, step-by-step)
    ↓
CTA (Get a Quote — low friction, clear value)
    ↓
OBJECTION HANDLING (FAQ, guarantee, local team)
    ↓
SECONDARY CTA (repeat or WhatsApp alternative)
```

### Step 2 — Hero Section Optimisation

High-converting hero for home services:

```tsx
<section className="relative overflow-hidden min-h-[520px] md:min-h-[640px] px-4 pb-16 pt-20 sm:px-6 md:pb-24 md:pt-28 lg:px-8">
  {/* Background: finished interior photo (not workers/hardhats) */}
  <Image src="/hero-finished-apartment.webp" alt="..." fill priority sizes="100vw"
    className="object-cover object-center z-0" unoptimized />
  <div className="absolute inset-0 z-10 bg-gradient-to-r from-[#F0EBD8]/90 via-[#F0EBD8]/70 to-transparent" />
  
  <div className="relative z-20 mx-auto max-w-4xl">
    {/* Eyebrow: specificity builds trust */}
    <p className="text-[13px] font-semibold uppercase tracking-wider text-accent-sage">
      Bologna · Emilia-Romagna
    </p>
    
    {/* H1: outcome-focused, not feature-focused */}
    <h1 className="mt-3 text-[36px] font-bold leading-tight text-brand-primary md:text-[52px]">
      Your Renovation, Delivered On Time and On Budget
    </h1>
    
    {/* Sub-headline: addresses top pain point */}
    <p className="mt-6 max-w-2xl text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
      We coordinate every trade, handle permits, and give you a fixed price
      before work begins — so you never get a nasty surprise.
    </p>
    
    {/* Primary CTA: specific, low-commitment language */}
    <div className="mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-start">
      <Link href="/quote"
        className="w-full rounded-md bg-brand-primary px-8 py-3 text-center text-[16px] font-semibold text-white transition-colors hover:bg-accent-blue sm:w-auto">
        Get Your Free Quote →
      </Link>
      <Link href="/how-it-works"
        className="text-[16px] font-semibold text-brand-primary underline underline-offset-4 transition-colors hover:text-accent-blue">
        See How It Works
      </Link>
    </div>
    
    {/* Micro-copy: removes hesitation */}
    <p className="mt-4 text-[13px] font-light text-accent-blue">
      Free consultation · No obligation · Response within 24 hours
    </p>
  </div>
</section>
```

**Key principles applied:**
- Left-aligned text (not centred) performs better on desktop for service businesses
- Outcome-focused headline (what they GET, not what you DO)
- Primary CTA uses arrow → to imply forward momentum
- Micro-copy below CTA addresses the 3 biggest hesitations: cost, commitment, wait time

### Step 3 — Pain Agitation Section

```tsx
<section className="bg-bg-white px-4 py-16 sm:px-6 md:py-24 lg:px-8">
  <div className="mx-auto max-w-3xl">
    <p className="text-center text-[13px] font-semibold uppercase tracking-wider text-accent-sage">
      Sound familiar?
    </p>
    
    {/* Pain points as italicised "internal monologue" */}
    <div className="mt-8 space-y-4">
      {painPoints.map((pain, i) => (
        <p key={i} className="text-center text-[16px] font-normal italic text-brand-secondary md:text-[17px]">
          "{pain}"
        </p>
      ))}
    </div>
    
    {/* Pivot: we understand → we solve */}
    <p className="mt-10 text-center text-[20px] font-semibold text-brand-primary md:text-[24px]">
      There's a better way.
    </p>
    <p className="mx-auto mt-4 max-w-xl text-center text-[16px] font-normal leading-relaxed text-brand-secondary">
      Garnebo acts as your single point of contact — we manage every trade,
      every deadline, every permit, so you don't have to.
    </p>
  </div>
</section>
```

### Step 4 — Social Proof Modules

**Numbered outcomes block** (highly effective for home services):
```tsx
<section className="px-4 py-16 sm:px-6 md:py-24 lg:px-8">
  <div className="mx-auto max-w-5xl">
    <div className="grid gap-8 md:grid-cols-3">
      {[
        { stat: '120+', label: 'Renovations completed in Bologna' },
        { stat: '4.9★', label: 'Average client satisfaction rating' },
        { stat: '0', label: 'Projects without a signed fixed-price quote' },
      ].map((item) => (
        <div key={item.stat} className="text-center">
          <p className="text-[52px] font-bold leading-none text-brand-primary">{item.stat}</p>
          <p className="mt-3 text-[16px] font-normal text-brand-secondary">{item.label}</p>
        </div>
      ))}
    </div>
  </div>
</section>
```

**Testimonial card** (with photo for higher conversion):
```tsx
<div className="rounded-lg bg-bg-white p-8 shadow-sm">
  {/* Star rating */}
  <div className="flex gap-1 text-[#F59E0B]" aria-label="5 out of 5 stars">
    {Array.from({ length: 5 }).map((_, i) => (
      <svg key={i} className="h-5 w-5 fill-current" viewBox="0 0 20 20">
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    ))}
  </div>
  <blockquote className="mt-4 text-[16px] font-normal italic leading-relaxed text-brand-secondary">
    "Garnebo handled everything — from the permit to the final coat of paint.
    I didn't have to make a single phone call to a contractor."
  </blockquote>
  <div className="mt-6 flex items-center gap-3">
    <img src="/testimonials/marco-b.webp" alt="Marco B." 
      className="h-10 w-10 rounded-full object-cover" />
    <div>
      <p className="text-[16px] font-semibold text-brand-primary">Marco B.</p>
      <p className="text-[13px] font-light text-accent-blue">3-room renovation, Bologna Centro</p>
    </div>
  </div>
</div>
```

### Step 5 — Value Proposition / Process Steps

The "How It Works" 3-step pattern reduces fear of commitment:

```tsx
{/* Existing TimelineStep component handles this well */}
{/* Key: steps must feel easy and low-risk */}
{/* Step labels must be verbs: "Tell us", "We plan", "You move in" */}
```

Good step copy formula:
- **Step 1:** "Share Your Vision" (low effort: just talk to us)
- **Step 2:** "We Build the Plan" (we do the work)
- **Step 3:** "Move in to Your New Space" (outcome they want)

### Step 6 — Urgency & Scarcity (Without Being Fake)

Honest urgency that works in home services:

```tsx
{/* Seasonal capacity note */}
<p className="rounded-md bg-accent-sage/10 px-4 py-3 text-[13px] font-normal text-brand-secondary">
  📅 We typically book 3–4 weeks in advance. Request your free quote now to 
  secure your preferred start date.
</p>
```

**Do NOT:**
- Use fake countdown timers
- Claim "only 2 slots left" unless it's true
- Use "Limited time offer" without a real end date

### Step 7 — Secondary CTA / WhatsApp Alternative

For users not ready to fill a form (high in home services):

```tsx
<div className="mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
  <Link href="/quote"
    className="rounded-md bg-brand-primary px-8 py-3 text-[16px] font-semibold text-white hover:bg-accent-blue transition-colors">
    Get a Free Quote
  </Link>
  <a href="https://wa.me/393517443151?text=Hi%2C%20I'm%20interested%20in%20a%20renovation%20quote"
    target="_blank" rel="noopener noreferrer"
    className="flex items-center gap-2 text-[16px] font-semibold text-brand-primary underline underline-offset-4 hover:text-accent-blue transition-colors">
    <svg className="h-5 w-5 fill-[#25D366]" viewBox="0 0 32 32">...</svg>
    Or message us on WhatsApp
  </a>
</div>
```

### Step 8 — CTA Placement Rules

| Section position      | CTA type               | Notes                                   |
|-----------------------|------------------------|-----------------------------------------|
| Hero (above fold)     | Primary button         | Full-width mobile, auto desktop         |
| After proof section   | Primary button         | Repeat after trust has been established |
| Bottom of every page  | `CTABanner` component  | Dark bg, high contrast, always present  |
| Mobile bottom         | `MobileStickyBar`      | Appears after 300px scroll              |
| Desktop fixed         | Header "Get a Quote"   | Always visible in sticky nav            |

### Step 9 — Reducing Form Anxiety

Before linking to the `/quote` form, set expectations:

```tsx
<div className="mt-6 flex flex-wrap justify-center gap-x-8 gap-y-2">
  {[
    '✓ 2-minute process',
    '✓ No account needed',
    '✓ Upload photos from your phone',
    '✓ Free, no obligation',
  ].map((item) => (
    <span key={item} className="text-[13px] font-normal text-accent-blue">
      {item}
    </span>
  ))}
</div>
```

## Conversion Hierarchy Summary

```
HIGHEST IMPACT
├── Before/After slider with real project photos
├── Fixed-price promise (remove financial risk perception)
├── Local team photo + names (humanise the brand)
├── Compliance/legal badges (DM 37/2008, VAT number)
├── Numbered project stats (social proof)
├── Client testimonials with real names + neighbourhood
├── Step-by-step process (reduces fear of commitment)
└── WhatsApp alternative CTA (removes form friction)
LOWEST IMPACT (still worth doing)
```

## Constraints & Anti-Patterns

- **DO NOT** use generic stock photography (workers, blueprints, handshakes) — kills trust
- **DO NOT** have more than 1 primary CTA per section
- **DO NOT** use "Submit" as button copy — use action-outcome language
- **DO NOT** show a native multi-field form — link to Typeform/Tally embed on `/quote`
- **DO NOT** use fake urgency — dishonest scarcity destroys trust in home services
- **DO NOT** put trust signals below the fold on mobile — at least one badge/proof above fold

## Invocation Examples

- "Improve the conversion rate of the home page hero section"
- "Add social proof stats block to the Services page"
- "Write better CTA copy for the quote button"
- "Create a WhatsApp alternative CTA below the primary button"
- "Review the home page flow against CRO best practices"
- "Add an urgency note about booking availability to the hero"

## Completion Checks

- [ ] Every CTA button uses action-outcome language — no "Submit", "Click here", or "Contact"
- [ ] No more than one primary CTA per page section
- [ ] Micro-copy below primary CTA addresses at least one hesitation (cost, commitment, or response time)
- [ ] At least one trust signal (badge, stat, or compliance note) appears above the fold on mobile
- [ ] WhatsApp alternative CTA present alongside or below the primary quote CTA
- [ ] No fake countdown timers, false scarcity, or unverifiable urgency claims
- [ ] Hero H1 is outcome-focused (describes what the visitor gets, not what the company does)
- [ ] Hero text is left-aligned on desktop
- [ ] Page follows the full conversion flow: Hook → Problem → Proof → Solution → CTA → Objection handling → Secondary CTA
- [ ] `CTABanner` component present at the bottom of every page

## References

No external references required.
