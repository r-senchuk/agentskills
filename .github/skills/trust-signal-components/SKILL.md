---
name: trust-signal-components
description: "Use when designing or implementing trust signal UI components such as compliance badges, legal credentials, guarantee blocks, team modules, shield icons, and trust badge rows for a home services renovation site. Use when user asks to 'add trust badges', 'show credentials', 'add guarantee section', 'display team members', or 'build social proof row'. Covers compliance badge markup, shield/check icon patterns, guarantee block copy, and team card layouts. Do NOT use for hero CTA design, quote form UX, backend analytics, SEO metadata, or generic social proof copywriting unrelated to renovation trust signals."
argument-hint: "trust signal type, target page section, available credentials"
user-invocable: true
---

# Trust Signal UI Components
Design and implement trust signal components (compliance badges, legal credentials, guarantees, team portraits, shield/checkmark iconography) that reduce visitor anxiety and increase quote request conversions for the Garnebo renovation business.

**Trust blockers in home services:** Fear of unlicensed workers, hidden costs, project abandonment, non-compliance with building codes.
**Key Garnebo trust assets:** DM 37/2008 compliance, VAT IT04239601208, Bologna local presence, fixed-price quotes, single project manager contact.

## When To Use

- Adding a horizontal trust badge row below the hero section or on the quote page
- Building a `TrustBlock` section with 3-column compliance/guarantee/local-team cards
- Implementing a `ComplianceBadge` for a specific legal credential (e.g. DM 37/2008)
- Adding a `TeamModule` with staff portraits, names, roles, and bios
- Creating a guarantee statement block or shield icon to reduce pre-conversion anxiety

**Do NOT use for:** CTA button copy and placement (use `cro-home-services`), quote form UX (use `photo-upload-form-ux`), analytics, or creating non-inline SVG icon systems.

## Inputs To Collect First

1. Which trust signal component is needed (badge row, full trust block, compliance badge, team module, or guarantee block)
2. Target page and section placement (hero area, services page, quote page, footer, etc.)
3. Available trust assets (DM 37/2008 certification, VAT number, project count, ratings, team photos)
4. Locale(s) required (Italian, English, or both)

## Procedure

### Step 1 — Trust Signal Inventory

Before building, catalogue available assets:

| Signal type | Asset | Priority |
|---|---|---|
| Legal compliance | DM 37/2008 certification | Critical |
| Business legitimacy | VAT / P.IVA IT04239601208 | High |
| Financial protection | Fixed-price written quote | Critical |
| Local presence | Bologna-based team, local project mgr | High |
| Social proof | Client count, ratings, testimonials | High |
| Quality assurance | Workmanship guarantee / warranty | Medium |

### Step 2 — Trust Icon Component

```tsx
// src/components/TrustIcon.tsx
interface TrustIconProps {
  variant: 'shield' | 'check' | 'star' | 'document' | 'location' | 'lock';
  className?: string;
}

export function TrustIcon({ variant, className = 'h-8 w-8' }: TrustIconProps) {
  const icons = {
    shield: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5}
        strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden="true">
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
      </svg>
    ),
    check: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}
        strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden="true">
        <circle cx="12" cy="12" r="10" />
        <path d="M9 12l2 2 4-4" />
      </svg>
    ),
    location: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5}
        strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden="true">
        <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z" />
        <circle cx="12" cy="10" r="3" />
      </svg>
    ),
    lock: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5}
        strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden="true">
        <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
        <path d="M7 11V7a5 5 0 0110 0v4" />
      </svg>
    ),
  };
  return icons[variant] ?? null;
}
```

### Step 3 — Trust Badge Row (Compact, Above-Fold)

```tsx
// src/components/TrustBadgeRow.tsx
export function TrustBadgeRow() {
  const t = useTranslations('trust');
  const badges = [
    { icon: 'shield' as const, label: t('badge1') },
    { icon: 'check' as const,  label: t('badge2') },
    { icon: 'location' as const, label: t('badge3') },
    { icon: 'lock' as const,   label: t('badge4') },
  ];

  return (
    <div className="flex flex-wrap justify-center gap-x-8 gap-y-4 py-6">
      {badges.map((badge) => (
        <div key={badge.label} className="flex items-center gap-2 text-brand-secondary">
          <TrustIcon variant={badge.icon} className="h-5 w-5 flex-shrink-0 text-accent-sage" />
          <span className="text-[13px] font-normal">{badge.label}</span>
        </div>
      ))}
    </div>
  );
}
```

### Step 4 — Full Trust Block Section

```tsx
// src/components/TrustBlock.tsx
export function TrustBlock({ heading, items }: TrustBlockProps) {
  return (
    <section className="bg-bg-white px-4 py-16 sm:px-6 md:py-24 lg:px-8">
      <div className="mx-auto max-w-5xl">
        <h2 className="text-center text-[26px] font-semibold text-brand-primary md:text-[36px]">
          {heading}
        </h2>
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {items.map((item) => (
            <div key={item.title} className="flex flex-col items-start gap-4 rounded-lg bg-bg-primary/50 p-6 md:p-8">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-accent-sage/20">
                <TrustIcon variant={item.icon} className="h-6 w-6 text-brand-primary" />
              </div>
              <div>
                <h3 className="text-[20px] font-semibold text-brand-primary">{item.title}</h3>
                <p className="mt-2 text-[16px] font-normal leading-relaxed text-brand-secondary">{item.body}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
```

### Step 5 — Compliance Badge

```tsx
// src/components/ComplianceBadge.tsx
export function ComplianceBadge({ code, label, description }: ComplianceBadgeProps) {
  return (
    <div className="flex items-start gap-4 rounded-lg border border-accent-sage/30 bg-bg-white p-5">
      <div className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-md bg-bg-dark text-white">
        <span className="text-center text-[10px] font-bold uppercase leading-tight tracking-wide">{code}</span>
      </div>
      <div>
        <p className="text-[16px] font-semibold text-brand-primary">{label}</p>
        <p className="mt-1 text-[13px] font-normal leading-relaxed text-brand-secondary">{description}</p>
      </div>
    </div>
  );
}
```

### Step 6 — Team Module

```tsx
// src/components/TeamModule.tsx
export function TeamMember({ name, role, bio, imageSrc }: TeamMemberProps) {
  return (
    <div className="flex flex-col items-center text-center sm:flex-row sm:items-start sm:gap-6 sm:text-left">
      <img src={imageSrc} alt={name}
        className="h-24 w-24 flex-shrink-0 rounded-full object-cover shadow-sm" />
      <div className="mt-4 sm:mt-0">
        <p className="text-[20px] font-semibold text-brand-primary">{name}</p>
        <p className="text-[13px] font-normal uppercase tracking-wider text-accent-sage">{role}</p>
        <p className="mt-3 text-[16px] font-normal leading-relaxed text-brand-secondary">{bio}</p>
      </div>
    </div>
  );
}
```

### Step 7 — Guarantee Statement Block

```tsx
<div className="rounded-lg bg-bg-dark px-8 py-10 text-center">
  <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-white/10">
    <TrustIcon variant="shield" className="h-8 w-8 text-white" />
  </div>
  <h3 className="mt-4 text-[20px] font-semibold text-white md:text-[24px]">Our Promise</h3>
  <p className="mx-auto mt-3 max-w-md text-[16px] font-normal leading-relaxed text-white/80">
    If the final cost exceeds our written quote for reasons within our control,
    Garnebo covers the difference. Full stop.
  </p>
</div>
```

### Step 8 — Placement Guide and Translation Keys

**Placement:**

| Location | Recommended signals |
|---|---|
| Hero section | Micro-copy badges: "Free · No obligation · 24h response" |
| Below hero | 3–4 badge row: certified, fixed price, local, insured |
| Services page | DM 37/2008 badge near electrical/plumbing services |
| Quote page | Privacy/GDPR note |
| Footer | VAT number, registered address, certifications |

**Translation keys:**
```json
{ "trust": { "badge1": "Certificato DM 37/2008", "badge2": "Preventivo a prezzo fisso", "badge3": "Team locale a Bologna", "badge4": "100% in regola" } }
```

> **Constraints:** Do NOT use generic shield icons without specific legal context. Do NOT invent credentials that don't exist. Do NOT use green (#00FF00) — use brand `accent-sage`. Do NOT place trust blocks only at the bottom. Do NOT use icon libraries (Font Awesome, Hero Icons via npm) — inline SVG only. ALWAYS provide `aria-hidden="true"` on decorative SVG icons.

## Completion Checks

- [ ] All SVG icons are inline and carry `aria-hidden="true"`
- [ ] `TrustBadgeRow` uses `flex-wrap` and renders correctly at 375 px viewport
- [ ] `ComplianceBadge` `code` matches a real credential (e.g. DM 37/2008, VAT IT04239601208)
- [ ] Team portrait images use `rounded-full object-cover` with descriptive alt text
- [ ] All colour classes use brand token utilities — no arbitrary hex
- [ ] At least one trust signal appears above the fold on mobile
- [ ] Translation keys added to both `messages/it.json` and `messages/en.json`
- [ ] No invented credentials

## References

- [Local implementation notes](./references/local-implementation-notes.md)
- [Nielsen Norman Group — Trust and Credibility](https://www.nngroup.com/articles/trust-and-credibility-guidelines-for-the-web/)
- [MDN — ARIA: img role](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/img_role)
- [Tailwind CSS — Flex utilities](https://tailwindcss.com/docs/flex)
- [Google Fonts — Icon fonts](https://fonts.google.com/icons)
