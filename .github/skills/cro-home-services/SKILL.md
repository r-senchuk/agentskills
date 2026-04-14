---
name: cro-home-services
description: "Use when designing or auditing conversion-focused UX patterns for a home services renovation website, including hero messaging, CTA placement, social proof, urgency copy, and quote funnel friction reduction. Use when user asks to 'improve conversion rate', 'fix CTA', 'add social proof', or 'reduce quote funnel drop-off'. Covers above-the-fold hierarchy, trust signals, urgency triggers, and mobile CTA optimisation. Do NOT use for backend analytics, A/B test infrastructure, performance monitoring, or generic marketing copy unrelated to home services."
argument-hint: "target page or section, conversion problem, current CTA copy, CTA destination"
user-invocable: true
---

# CRO UI Patterns for Home Services

Design and implement high-converting UX patterns specific to residential renovation and home services businesses on the Garnebo website. Business model: B2C renovation project management in Bologna, Italy — primary conversion goal is quote form submissions. Audience: homeowners (75%+ mobile), high intent, low patience for friction. Trust-deficit is the #1 conversion blocker.

**Core principles:** Trust before action → Reduce perceived risk → One clear next step per section → Friction removal → Dense social proof throughout.

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

**Key principles:** Left-aligned text on desktop outperforms centred for service businesses. Outcome-focused H1. Arrow `→` implies forward momentum. Micro-copy below CTA addresses the 3 biggest hesitations (cost, commitment, wait time).

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
  </div>
</section>
```

### Step 4 — Social Proof Modules

**Numbered outcomes block:**
```tsx
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
```

**Testimonial card (with photo for higher conversion):**
```tsx
<div className="rounded-lg bg-bg-white p-8 shadow-sm">
  <div className="flex gap-1 text-[#F59E0B]" aria-label="5 out of 5 stars">
    {Array.from({ length: 5 }).map((_, i) => (
      <svg key={i} className="h-5 w-5 fill-current" viewBox="0 0 20 20">
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    ))}
  </div>
  <blockquote className="mt-4 text-[16px] font-normal italic leading-relaxed text-brand-secondary">
    "Garnebo handled everything — from the permit to the final coat of paint."
  </blockquote>
  <div className="mt-6 flex items-center gap-3">
    <img src="/testimonials/marco-b.webp" alt="Marco B." className="h-10 w-10 rounded-full object-cover" />
    <div>
      <p className="text-[16px] font-semibold text-brand-primary">Marco B.</p>
      <p className="text-[13px] font-light text-accent-blue">3-room renovation, Bologna Centro</p>
    </div>
  </div>
</div>
```

### Step 5 — Process Steps and Urgency

**How It Works step labels (verb-first, outcome-focused):**
- Step 1: "Share Your Vision" (low effort)
- Step 2: "We Build the Plan" (we do the work)
- Step 3: "Move in to Your New Space" (outcome they want)

**Honest urgency (no fake timers):**
```tsx
<p className="rounded-md bg-accent-sage/10 px-4 py-3 text-[13px] font-normal text-brand-secondary">
  📅 We typically book 3–4 weeks in advance. Request your free quote now to secure your preferred start date.
</p>
```

### Step 6 — Secondary CTA and WhatsApp Alternative

```tsx
<div className="mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
  <Link href="/quote"
    className="rounded-md bg-brand-primary px-8 py-3 text-[16px] font-semibold text-white hover:bg-accent-blue transition-colors">
    Get a Free Quote
  </Link>
  <a href="https://wa.me/393517443151?text=Hi%2C%20I'm%20interested%20in%20a%20renovation%20quote"
    target="_blank" rel="noopener noreferrer"
    className="flex items-center gap-2 text-[16px] font-semibold text-brand-primary underline underline-offset-4 hover:text-accent-blue transition-colors">
    Or message us on WhatsApp
  </a>
</div>
```

### Step 7 — Reducing Form Anxiety

Set expectations before linking to `/quote`:
```tsx
<div className="mt-6 flex flex-wrap justify-center gap-x-8 gap-y-2">
  {['✓ 2-minute process', '✓ No account needed', '✓ Upload photos from your phone', '✓ Free, no obligation'].map((item) => (
    <span key={item} className="text-[13px] font-normal text-accent-blue">{item}</span>
  ))}
</div>
```

### Step 8 — CTA Placement Rules

| Section position | CTA type | Notes |
|---|---|---|
| Hero (above fold) | Primary button | Full-width mobile, auto desktop |
| After proof section | Primary button | Repeat after trust is established |
| Bottom of every page | `CTABanner` component | Dark bg, always present |
| Mobile bottom | `MobileStickyBar` | Appears after 300px scroll |
| Desktop fixed | Header "Get a Quote" | Always visible in sticky nav |

> **Constraints:** Do NOT use more than 1 primary CTA per section. Do NOT use "Submit" as button copy. Do NOT use fake countdown timers or unverifiable urgency claims. Do NOT show a native multi-field form — link to Typeform/Tally embed on `/quote`. Do NOT use generic stock photography.

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
