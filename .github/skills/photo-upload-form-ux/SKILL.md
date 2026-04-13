---
name: photo-upload-form-ux
description: "Use when designing or implementing a quote request funnel for a static Next.js site, including the quote page, embedded form, photo upload guidance, WhatsApp fallback, FAQ, or thank-you page. Do NOT use for native HTML forms, backend form processing, or non-quote contact pages."
argument-hint: "form tool, locale, funnel step to build"
user-invocable: true
---

# Photo-Upload Form UX for Mobile Quote Funnels

Design and implement the quote request funnel UX for the Garnebo `/quote` page — optimising for mobile users uploading smartphone photos, minimising form friction, and maximising completions.

**Architecture:** Static export (no API routes, no backend). All form handling delegated to third-party embed: Typeform, Tally, or Fillout. Most users arrive from Google Maps/Instagram/WhatsApp with renovation photos already in their camera roll.

**Why photos matter:** Submitting photos signals high intent. The photo upload step acts as a commitment device — completion rate rises sharply once a user uploads. Forms with photo steps outperform 15-field text-only forms in home services.

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

### Step 1 — Page Structure for /quote

The quote page follows this sequence:
1. Minimal header (just logo + "Back" link — remove nav distractions)
2. Trust bar (compact — 3 badges in one line)
3. Page headline + expectation-setting sub-copy
4. "What to photograph" instruction block
5. Embedded form (full width, tall)
6. WhatsApp alternative (for users who abandon the form)
7. FAQ accordion (2–3 objection-handling questions)

```tsx
// src/app/[locale]/quote/page.tsx
export default async function QuotePage({ params }: Props) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations('quote');

  return (
    <>
      {/* Stripped nav */}
      <div className="border-b border-accent-sage/30 bg-bg-primary px-4 py-4">
        <div className="mx-auto flex max-w-5xl items-center justify-between">
          <Link href="/" className="text-xl font-bold uppercase tracking-wider text-brand-primary">GARNEBO</Link>
          <Link href="/" className="text-[13px] font-normal text-accent-blue hover:text-brand-primary">
            ← {t('backToSite')}
          </Link>
        </div>
      </div>
      <TrustBadgeRow />
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
      <PhotoUploadGuide />
      <section className="px-4 pb-12 sm:px-6">
        <div className="mx-auto max-w-2xl"><QuoteForm /></div>
      </section>
      {/* WhatsApp fallback */}
      <section className="border-t border-accent-sage/20 bg-bg-white px-4 py-12 sm:px-6">
        <div className="mx-auto max-w-2xl text-center">
          <p className="text-[16px] font-normal text-brand-secondary">{t('preferWhatsapp')}</p>
          <a href="https://wa.me/393517443151" target="_blank" rel="noopener noreferrer"
            className="mt-4 inline-flex items-center gap-2 text-[16px] font-semibold text-brand-primary underline underline-offset-4 hover:text-accent-blue transition-colors">
            {t('whatsappCta')}
          </a>
        </div>
      </section>
    </>
  );
}
```

### Step 2 — Photo Upload Guidance Block

Highest-impact UX addition: show users exactly what to photograph before the form.

```tsx
// src/components/PhotoUploadGuide.tsx
export function PhotoUploadGuide() {
  const t = useTranslations('quote.photoGuide');
  const tips = [
    { icon: '📸', title: t('tip1Title'), body: t('tip1Body') },
    { icon: '🔍', title: t('tip2Title'), body: t('tip2Body') },
    { icon: '📐', title: t('tip3Title'), body: t('tip3Body') },
  ];

  return (
    <section className="bg-bg-white px-4 py-10 sm:px-6">
      <div className="mx-auto max-w-2xl">
        <p className="text-center text-[13px] font-semibold uppercase tracking-wider text-accent-sage">
          {t('eyebrow')}
        </p>
        <h2 className="mt-3 text-center text-[20px] font-semibold text-brand-primary md:text-[24px]">
          {t('heading')}
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
        <p className="mt-6 text-center text-[13px] font-light text-accent-blue">{t('footnote')}</p>
      </div>
    </section>
  );
}
```

### Step 3 — Form Embed Component

**Tally (iframe approach):**
```tsx
'use client';
export function QuoteForm() {
  return (
    <iframe
      data-tally-src="https://tally.so/embed/YOUR_FORM_ID?alignLeft=1&hideTitle=1&transparentBackground=1&dynamicHeight=1"
      loading="lazy" width="100%" height="500" frameBorder={0} marginHeight={0} marginWidth={0}
      title="Request a renovation quote" className="w-full" style={{ minHeight: '500px' }}
    />
  );
}
```

**Typeform:**
```tsx
'use client';
import { useEffect } from 'react';
const FORM_ID = 'your-typeform-id';
export function QuoteForm() {
  useEffect(() => {
    const script = document.createElement('script');
    script.src = 'https://embed.typeform.com/next/embed.js';
    script.async = true;
    document.body.appendChild(script);
    return () => { document.body.removeChild(script); };
  }, []);
  return <div data-tf-live={FORM_ID} style={{ minHeight: '600px', width: '100%' }} />;
}
```

### Step 4 — Form Question Order

Optimal order for commitment and completion:
1. **Service type** — "What do you need?" (radio, low effort)
2. **Room/area** — "Which room(s)?" (multi-select)
3. **Photo upload** — "Add 2–3 photos from your phone" (commitment device)
4. **Brief description** — "Anything specific?" (optional free text)
5. **Contact info** — Name, phone/WhatsApp (last — after commitment established)

> Photo step BEFORE contact info removes "why are they asking for my number?" anxiety.

### Step 5 — Confirmation Page (Post-Submit)

Configure the form tool to redirect to `/[locale]/grazie` or `/[locale]/thank-you` after submission.

```tsx
// src/app/[locale]/grazie/page.tsx
<section className="px-4 py-24 text-center">
  <div className="mx-auto max-w-md">
    <div className="text-5xl">✅</div>
    <h1 className="mt-6 text-[26px] font-bold text-brand-primary">{t('thankYouHeading')}</h1>
    <p className="mt-4 text-[16px] font-normal leading-relaxed text-brand-secondary">{t('thankYouBody')}</p>
    <Link href="/" className="mt-8 inline-block ...">{t('backToHome')}</Link>
  </div>
</section>
```

### Step 6 — Italian Translation Keys

```json
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

> **Constraints:** Do NOT build a native HTML form with file upload — static export has no backend. Do NOT ask for contact details before the photo upload step. Do NOT show full site navigation on `/quote` — remove exit paths. Do NOT use `iframe` with a fixed height for dynamic embeds — use `dynamicHeight` options. Do NOT index `/quote` — use `robots: 'noindex'` in `generateMetadata`.

## Completion Checks

- [ ] `/quote` page uses stripped navigation (logo + back link only)
- [ ] `TrustBadgeRow` appears directly below the stripped header
- [ ] `PhotoUploadGuide` appears before the embedded form
- [ ] Embedded form uses dynamic height configuration
- [ ] Form question order puts contact info AFTER the photo upload step
- [ ] WhatsApp fallback link present with `target="_blank" rel="noopener noreferrer"`
- [ ] `generateMetadata` returns `robots: 'noindex'` for the quote page
- [ ] Post-submit redirect URL configured in the form tool to the thank-you page
- [ ] Thank-you page exists with expected delivery time and WhatsApp option
- [ ] All visible strings use `useTranslations` or `getTranslations` — no hardcoded copy

## References

No external references required.
