---
name: photo-upload-form-ux
description: "Use when designing or implementing the quote request funnel for a static Next.js site — including the /quote page structure, embedded Typeform/Tally/Fillout form, photo upload guidance component, WhatsApp fallback, FAQ accordion, or post-submission thank-you page. Do NOT use for native HTML form creation, backend form processing, or non-quote contact pages."
argument-hint: "form tool (Typeform/Tally/Fillout), locale, funnel step to build (page/embed/photo-guide/thank-you/i18n)"
user-invocable: true
---

# Skill: Photo-Upload Form UX for Mobile Quote Funnels

## Purpose

Design and implement the quote request funnel UX for the Garnebo `/quote` page — optimising specifically for mobile users uploading smartphone photos, minimising form friction, and maximising quote form completions.

## Context

**Architecture:** The Garnebo site is a static export (no API routes, no server actions, no backend form processing). All form handling is delegated to a third-party embed: **Typeform, Tally, or Fillout**.
**Primary conversion goal:** Visitor reaches `/quote`, sees embedded form, completes and submits it.
**Mobile reality:** Most users arrive from Google Maps, Instagram, or WhatsApp on their phone. They have renovation photos already in their camera roll. The UX must make uploading those photos feel natural and easy.
**Photo upload purpose:** Garners scope information that allows Garnebo to provide accurate quotes without a site visit.

## Why Photos Matter for Conversion

- Submitting photos signals high intent (visitor is serious)
- Photos allow Garnebo to give a ballpark quote faster
- The photo upload step itself acts as a commitment device — once a user uploads, completion rate rises sharply
- Forms asking for photos outperform 15-field text-only forms in home services (avg +23% quote quality, lower drop-off)

## When To Use

- Building or refining the `/quote` page quote-request funnel for a static Next.js export site
- Embedding a Typeform, Tally, or Fillout form into a Next.js page without a backend
- Adding a photo upload guidance component to help mobile users photograph their renovation space
- Creating a post-submission thank-you page (`/grazie` or `/thank-you`) with WhatsApp fallback
- Writing Italian or English i18n translation keys for the quote funnel

**Do NOT use for:** native `<form>` elements with file inputs (no backend on static export), general multi-field contact forms, or backend API route handlers.

## Inputs To Collect First

1. Which form tool will be used (Typeform, Tally, or Fillout) and the form ID or URL
2. Target locale(s) (Italian, English, or both)
3. Which specific step is being built (page structure, form embed, photo guidance, thank-you page, FAQ, i18n keys)
4. Whether a WhatsApp fallback CTA is required on the quote page

## Procedure

### Step 1 — Page Structure for `/quote`

The quote page (`src/app/[locale]/quote/page.tsx`) should follow this sequence:

```
1. Minimal header (just logo + "Back" link)
2. Trust bar (compact — 3 badges in one line)
3. Page headline + expectation-setting sub-copy
4. "What to photograph" instruction block
5. Embedded form (Typeform/Tally/Fillout) — full width, tall
6. WhatsApp alternative (for users who abandon the form)
7. FAQ accordion (2–3 objection-handling questions)
```

### Step 2 — Quote Page Header (Stripped Navigation)

On conversion pages, remove nav distractions:

```tsx
// src/app/[locale]/quote/page.tsx
import { getTranslations, setRequestLocale } from 'next-intl/server';
import { Link } from '@/i18n/navigation';
import { QuoteForm } from '@/components/QuoteForm';
import { TrustBadgeRow } from '@/components/TrustBadgeRow';
import { FAQAccordion } from '@/components/FAQAccordion';

export default async function QuotePage({ params }: Props) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations('quote');

  return (
    <>
      {/* Stripped nav */}
      <div className="border-b border-accent-sage/30 bg-bg-primary px-4 py-4">
        <div className="mx-auto flex max-w-5xl items-center justify-between">
          <Link href="/" className="text-xl font-bold uppercase tracking-wider text-brand-primary">
            GARNEBO
          </Link>
          <Link href="/" className="text-[13px] font-normal text-accent-blue hover:text-brand-primary">
            ← {t('backToSite')}
          </Link>
        </div>
      </div>

      {/* Trust bar */}
      <div className="border-b border-accent-sage/20 bg-bg-white">
        <div className="mx-auto max-w-3xl">
          <TrustBadgeRow />
        </div>
      </div>

      {/* Page heading */}
      <section className="px-4 pb-8 pt-12 sm:px-6">
        <div className="mx-auto max-w-2xl text-center">
          <h1 className="text-[26px] font-bold leading-tight text-brand-primary md:text-[36px]">
            {t('heading')}
          </h1>
          <p className="mt-4 text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
            {t('subheading')}
          </p>
        </div>
      </section>

      {/* Photo guidance block */}
      <PhotoUploadGuide />

      {/* Embedded form */}
      <section className="px-4 pb-12 sm:px-6">
        <div className="mx-auto max-w-2xl">
          <QuoteForm />
        </div>
      </section>

      {/* WhatsApp fallback */}
      <section className="border-t border-accent-sage/20 bg-bg-white px-4 py-12 sm:px-6">
        <div className="mx-auto max-w-2xl text-center">
          <p className="text-[16px] font-normal text-brand-secondary">
            {t('preferWhatsapp')}
          </p>
          <a
            href="https://wa.me/393517443151"
            target="_blank"
            rel="noopener noreferrer"
            className="mt-4 inline-flex items-center gap-2 text-[16px] font-semibold text-brand-primary underline underline-offset-4 hover:text-accent-blue transition-colors"
          >
            {t('whatsappCta')}
          </a>
        </div>
      </section>

      {/* FAQ */}
      <section className="px-4 py-12 sm:px-6">
        <div className="mx-auto max-w-2xl">
          <h2 className="text-[20px] font-semibold text-brand-primary md:text-[24px]">
            {t('faqHeading')}
          </h2>
          <div className="mt-6 space-y-0">
            {quoteFAQs.map((faq) => (
              <FAQAccordion key={faq.q} question={faq.q} answer={faq.a} />
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
```

### Step 3 — Photo Upload Guidance Block

This is the highest-impact UX addition for mobile photo uploads. Show users exactly what to photograph before they hit the form:

```tsx
// src/components/PhotoUploadGuide.tsx
export function PhotoUploadGuide() {
  const t = useTranslations('quote.photoGuide');

  const tips = [
    {
      icon: '📸',
      title: t('tip1Title'),   // "Wide room shot"
      body: t('tip1Body'),     // "Stand in the doorway. Capture the whole room."
    },
    {
      icon: '🔍',
      title: t('tip2Title'),   // "Close-up of the problem"
      body: t('tip2Body'),     // "Cracked tiles, peeling paint, damaged areas."
    },
    {
      icon: '📐',
      title: t('tip3Title'),   // "Include a measurement if possible"
      body: t('tip3Body'),     // "A tape measure or phone for scale helps us quote accurately."
    },
  ];

  return (
    <section className="bg-bg-white px-4 py-10 sm:px-6">
      <div className="mx-auto max-w-2xl">
        <p className="text-center text-[13px] font-semibold uppercase tracking-wider text-accent-sage">
          {t('eyebrow')}   {/* "Before you start" */}
        </p>
        <h2 className="mt-3 text-center text-[20px] font-semibold text-brand-primary md:text-[24px]">
          {t('heading')}   {/* "3 photos that help us quote faster" */}
        </h2>
        <div className="mt-8 grid gap-4 sm:grid-cols-3">
          {tips.map((tip) => (
            <div key={tip.title} className="flex flex-col items-center rounded-lg bg-bg-primary/50 p-5 text-center">
              <span className="text-3xl" role="img" aria-hidden="true">{tip.icon}</span>
              <h3 className="mt-3 text-[16px] font-semibold text-brand-primary">{tip.title}</h3>
              <p className="mt-2 text-[13px] font-normal leading-relaxed text-brand-secondary">{tip.body}</p>
            </div>
          ))}
        </div>
        <p className="mt-6 text-center text-[13px] font-light text-accent-blue">
          {t('footnote')}  {/* "2–3 photos from your camera roll are enough. Quality doesn't matter." */}
        </p>
      </div>
    </section>
  );
}
```

### Step 4 — Typeform Embed Component

Typeform, Tally, and Fillout all provide embed codes. The pattern for static-export-compatible embedding:

**Typeform:**
```tsx
// src/components/QuoteForm.tsx
'use client';

import { useEffect } from 'react';

const FORM_ID = 'your-typeform-id'; // e.g. 'aB1cD2eF'

export function QuoteForm() {
  useEffect(() => {
    // Load Typeform embed script
    const script = document.createElement('script');
    script.src = 'https://embed.typeform.com/next/embed.js';
    script.async = true;
    document.body.appendChild(script);
    return () => {
      document.body.removeChild(script);
    };
  }, []);

  return (
    <div
      data-tf-live={FORM_ID}
      style={{ minHeight: '600px', width: '100%' }}
    />
  );
}
```

**Tally (simpler, iframe approach):**
```tsx
// src/components/QuoteForm.tsx
'use client';

export function QuoteForm() {
  return (
    <iframe
      data-tally-src={`https://tally.so/embed/YOUR_FORM_ID?alignLeft=1&hideTitle=1&transparentBackground=1&dynamicHeight=1`}
      loading="lazy"
      width="100%"
      height="500"
      frameBorder={0}
      marginHeight={0}
      marginWidth={0}
      title="Request a renovation quote"
      className="w-full"
      style={{ minHeight: '500px' }}
    />
  );
}
```

**Fillout:**
```tsx
// src/components/QuoteForm.tsx
'use client';

import { useEffect } from 'react';

export function QuoteForm() {
  useEffect(() => {
    const script = document.createElement('script');
    script.src = 'https://server.fillout.com/embed/v1/';
    script.async = true;
    document.body.appendChild(script);
    return () => document.body.removeChild(script);
  }, []);

  return (
    <div
      style={{ width: '100%', height: '600px' }}
      data-fillout-id="your-fillout-id"
      data-fillout-embed-type="standard"
      data-fillout-inherit-parameters
      data-fillout-dynamic-resize
    />
  );
}
```

### Step 5 — Form UX Design Principles for Photo Uploads

When configuring the form inside Typeform/Tally/Fillout:

**Question order (optimised for commitment + completion):**
1. **Service type** — "What do you need?" (radio, low effort, establishes scope)
2. **Room/area** — "Which room(s)?" (multi-select, low effort)
3. **Photo upload** — "Add 2–3 photos from your phone" (MOBILE: this triggers camera roll picker)
4. **Brief description** — "Anything specific you'd like us to know?" (optional free text)
5. **Contact info** — Name, phone/WhatsApp (last — after commitment is established)

**Form UX principles:**
- Photo step BEFORE contact info (removes "why are they asking for my phone number?" anxiety)
- Mark contact fields as "We'll call you to discuss" to reduce resistance
- One question per screen/step (Typeform does this natively)
- Progress indicator visible throughout
- "Optional" label on non-essential fields

### Step 6 — Mobile-Specific Form Configuration

In Typeform/Tally settings:
- Enable **"Mobile-optimised"** mode
- Set **file upload** step to accept `image/*` (not just `application/pdf`)
- Set **max file size** to 20MB per photo (smartphone images can be 5–12MB each)
- Allow **multiple file upload** in one step (minimum 1, prompt for up to 5)
- Use **"From camera roll"** phrasing in Italian: "Dalla tua galleria foto"

### Step 7 — Quote Page Meta & SEO

```tsx
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: 'quote' });
  return {
    title: t('metaTitle'),      // "Get Your Free Renovation Quote | Garnebo Bologna"
    description: t('metaDesc'), // "Request a free renovation quote in 2 minutes. Upload photos..."
    robots: 'noindex',          // Quote pages should not be indexed (prevents duplicate leads)
  };
}
```

### Step 8 — Confirmation State (Post-Submit)

Configure the form tool to redirect to a thank-you URL after submission:

```
Redirect URL: https://garnebo.com/{locale}/grazie   (or /en/thank-you)
```

Create a minimal thank-you page:
```tsx
// src/app/[locale]/grazie/page.tsx  (for Italian)
// Confirm submission, set expectations, offer WhatsApp for urgent questions
<section className="px-4 py-24 text-center">
  <div className="mx-auto max-w-md">
    <div className="text-5xl">✅</div>
    <h1 className="mt-6 text-[26px] font-bold text-brand-primary">
      {t('thankYouHeading')}  {/* "Richiesta ricevuta!" */}
    </h1>
    <p className="mt-4 text-[16px] font-normal leading-relaxed text-brand-secondary">
      {t('thankYouBody')}     {/* "Ti contatteremo entro 24 ore..." */}
    </p>
    <Link href="/" className="mt-8 inline-block ... ">
      {t('backToHome')}
    </Link>
  </div>
</section>
```

## Quote Form FAQ Content

Suggested FAQ items for the quote page:

| Q | A |
|---|---|
| "How long does it take to get a quote?" | "We typically respond within 24 hours on business days. Urgent? Message us on WhatsApp." |
| "Do I need to be at home for the quote?" | "No. Photos are enough for an initial estimate. We'll arrange a brief site visit only if needed for complex work." |
| "Is the quote really free?" | "Always. There is no obligation and no fee for our initial estimate." |
| "What if I don't know what I want yet?" | "Tell us what's bothering you about the space. We'll suggest options." |

## Translation Keys Required

```json
// messages/it.json — add under "quote":
{
  "quote": {
    "heading": "Richiedi un preventivo gratuito",
    "subheading": "Carica 2-3 foto e ti risponderemo entro 24 ore.",
    "backToSite": "Torna al sito",
    "preferWhatsapp": "Preferisci scrivere su WhatsApp?",
    "whatsappCta": "Inviaci un messaggio →",
    "faqHeading": "Domande frequenti",
    "metaTitle": "Preventivo Gratuito Ristrutturazioni | Garnebo Bologna",
    "metaDesc": "Richiedi un preventivo in 2 minuti. Carica le foto dal telefono.",
    "photoGuide": {
      "eyebrow": "Prima di iniziare",
      "heading": "3 foto per un preventivo più preciso",
      "tip1Title": "Foto dell'ambiente intero",
      "tip1Body": "Mettiti sulla porta e fotografa tutta la stanza.",
      "tip2Title": "Dettaglio del problema",
      "tip2Body": "Crepe, distacchi, mattonelle rotte — fotografali da vicino.",
      "tip3Title": "Con un riferimento di misura",
      "tip3Body": "Un metro o il tuo telefono nell'inquadratura ci aiuta a stimare le dimensioni.",
      "footnote": "Bastano 2-3 foto dal tuo telefono. La qualità non deve essere perfetta."
    }
  }
}
```

## Constraints & Anti-Patterns

- **DO NOT** build a native HTML form with file upload — static export has no backend to receive it
- **DO NOT** ask for contact details before the photo upload step — inverts commitment psychology
- **DO NOT** show the full site navigation on the `/quote` page — it distracts and creates exit paths
- **DO NOT** use `iframe` with a fixed height for dynamic form embeds — use `dynamicHeight` options
- **DO NOT** index the `/quote` page — use `robots: 'noindex'` in `generateMetadata`
- **DO NOT** use emojis as the only way to distinguish tip cards — pair with text for screen readers
- **ALWAYS** provide a WhatsApp fallback on the quote page — some users will not complete forms

## Invocation Examples

- "Build the quote page with a Tally form embed"
- "Create the photo upload guidance component for the quote page"
- "Write the FAQ content for the quote page"
- "How should I structure the quote form to maximise photo upload completion?"
- "Create a thank-you page for after the quote form is submitted"
- "Add the Italian translations for the quote page"

## Completion Checks

- [ ] `/quote` page uses stripped navigation (logo + back link only — full site nav removed)
- [ ] `TrustBadgeRow` component appears directly below the stripped header
- [ ] `PhotoUploadGuide` component appears before the embedded form — not after
- [ ] Embedded form uses dynamic height configuration (`dynamicHeight=1`, `data-fillout-dynamic-resize`, etc.)
- [ ] Form question order puts contact info AFTER the photo upload step
- [ ] WhatsApp fallback `<a>` link present below the form section with `target="_blank" rel="noopener noreferrer"`
- [ ] `generateMetadata` returns `robots: 'noindex'` for the quote page
- [ ] Post-submit redirect URL configured in the form tool to point to the thank-you page
- [ ] Thank-you page (`/grazie` or `/thank-you`) exists with expected delivery time and WhatsApp option
- [ ] All visible strings on the page use `useTranslations` or `getTranslations` — no hardcoded copy

## References

No external references required.
