---
name: nextjs-tailwind-seo
description: "Use when setting up Tailwind CSS, implementing SEO metadata, configuring fonts, or adding structured data in Next.js 15 App Router projects. Covers Tailwind v4 CSS-first config, custom design tokens, generateMetadata, JSON-LD, next-sitemap, OG tags, canonical URLs, and responsive design patterns. Do not use for backend development, non-Tailwind styling, or design/branding decisions."
argument-hint: "SEO goal (metadata, sitemap, JSON-LD), Tailwind customization target (tokens, responsive), or font setup."
user-invocable: false
---

# Tailwind CSS & SEO for Next.js 15

## When To Use

- **Tailwind setup**: Configuring Tailwind CSS v4 with Next.js 15, custom design tokens, PostCSS.
- **Fonts**: Integrating Google Fonts via `next/font/google` with Tailwind CSS variables.
- **Responsive design**: Implementing mobile-first responsive layouts with Tailwind breakpoints.
- **SEO metadata**: Writing `generateMetadata()` for per-page title, description, OG tags, and canonical URLs.
- **Structured data**: Adding JSON-LD schemas (LocalBusiness, WebSite, Service, etc.).
- **Sitemap**: Configuring `next-sitemap` for sitemap.xml and robots.txt generation.
- **OG images**: Setting up Open Graph and Twitter Card meta tags.

Do NOT use for backend API development, non-Tailwind styling (CSS modules, styled-components), or making design/branding decisions.

## Inputs To Collect First

1. **Goal** — what needs to be set up (Tailwind, SEO, fonts, sitemap, or combination)
2. **Design tokens** — custom colors, fonts, spacing values if provided
3. **Site URL** — production base URL for canonical/OG tags and sitemap
4. **Locales** — which locales to include in sitemap and hreflang
5. **Business info** — for JSON-LD schemas (name, address, phone, hours)

## Procedure

### Step 1 — Tailwind CSS v4 Setup

Tailwind v4 uses a CSS-first configuration approach. No `tailwind.config.js` is required for most setups.

**Install dependencies:**

```bash
pnpm add tailwindcss @tailwindcss/postcss postcss
```

**Create `postcss.config.mjs`:**

```javascript
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};

export default config;
```

**Configure `src/app/globals.css`:**

```css
@import "tailwindcss";

@theme {
  /* Custom color tokens */
  --color-primary: #1B3A5C;
  --color-primary-light: #2A5580;
  --color-primary-dark: #0F2640;
  --color-accent: #D4A843;
  --color-accent-light: #E0BF6A;
  --color-neutral-50: #F8F9FA;
  --color-neutral-100: #F1F3F5;
  --color-neutral-200: #E9ECEF;
  --color-neutral-700: #495057;
  --color-neutral-800: #343A40;
  --color-neutral-900: #212529;

  /* Font families — set via CSS variables from next/font */
  --font-sans: var(--font-inter);
  --font-heading: var(--font-inter);

  /* Custom spacing */
  --spacing-section: 5rem;
  --spacing-section-sm: 3rem;

  /* Breakpoints (Tailwind v4 defaults, override if needed) */
  /* --breakpoint-sm: 40rem; */
  /* --breakpoint-md: 48rem; */
  /* --breakpoint-lg: 64rem; */
  /* --breakpoint-xl: 80rem; */
}
```

**Key differences from Tailwind v3:**
- No `tailwind.config.js` needed — configure in CSS via `@theme`
- `@import "tailwindcss"` replaces `@tailwind base; @tailwind components; @tailwind utilities;`
- Custom colors defined as `--color-*` are automatically available as Tailwind classes (e.g., `bg-primary`, `text-accent`)
- PostCSS uses `@tailwindcss/postcss` instead of `tailwindcss` as the plugin

### Step 2 — Google Fonts with next/font

```typescript
// src/app/[locale]/layout.tsx
import { Inter } from 'next/font/google';

const inter = Inter({
  subsets: ['latin', 'latin-ext'],
  display: 'swap',
  variable: '--font-inter',
});

export default async function LocaleLayout({ children, params }: Props) {
  const { locale } = await params;
  setRequestLocale(locale);
  const messages = await getMessages();

  return (
    <html lang={locale} className={inter.variable}>
      <body className="font-sans antialiased text-neutral-800 bg-neutral-50">
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

**How it works:**
1. `Inter({ variable: '--font-inter' })` creates a CSS variable `--font-inter`
2. The `@theme` block maps `--font-sans: var(--font-inter)`
3. Tailwind's `font-sans` class now uses Inter
4. Apply `className={inter.variable}` on `<html>` to scope the variable

### Step 3 — Responsive Design Patterns

Tailwind uses mobile-first breakpoints. Write base styles for mobile, add breakpoint prefixes for larger screens.

**Standard breakpoints (Tailwind v4 defaults):**

| Prefix | Min-width | Target |
|---|---|---|
| _(none)_ | 0px | Mobile (default) |
| `sm:` | 640px | Large phones / small tablets |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Desktop |
| `xl:` | 1280px | Large desktop |
| `2xl:` | 1536px | Extra large |

**Common responsive patterns:**

```tsx
{/* Responsive container */}
<div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">

{/* Responsive grid */}
<div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">

{/* Responsive text */}
<h1 className="text-3xl font-bold sm:text-4xl lg:text-5xl xl:text-6xl">

{/* Responsive spacing */}
<section className="py-12 sm:py-16 lg:py-20">

{/* Hide/show at breakpoints */}
<nav className="hidden lg:flex">         {/* Desktop nav */}
<button className="lg:hidden">           {/* Mobile menu button */}

{/* Responsive flex direction */}
<div className="flex flex-col gap-8 lg:flex-row lg:items-center">
```

### Step 4 — generateMetadata for Per-Page SEO

```typescript
// src/app/[locale]/page.tsx
import type { Metadata } from 'next';
import { getTranslations } from 'next-intl/server';
import { routing } from '@/i18n/routing';

const BASE_URL = 'https://www.example.com';

type Props = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: 'metadata' });

  const url = `${BASE_URL}/${locale}`;

  return {
    title: t('home.title'),
    description: t('home.description'),
    alternates: {
      canonical: url,
      languages: Object.fromEntries(
        routing.locales.map((loc) => [loc, `${BASE_URL}/${loc}`])
      ),
    },
    openGraph: {
      title: t('home.title'),
      description: t('home.description'),
      url,
      siteName: t('siteName'),
      locale,
      type: 'website',
      images: [
        {
          url: `${BASE_URL}/images/og-home.jpg`,
          width: 1200,
          height: 630,
          alt: t('home.title'),
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: t('home.title'),
      description: t('home.description'),
      images: [`${BASE_URL}/images/og-home.jpg`],
    },
  };
}
```

**Template pattern for the root layout:**

```typescript
// src/app/layout.tsx
export const metadata: Metadata = {
  metadataBase: new URL('https://www.example.com'),
  title: {
    template: '%s | Company Name',
    default: 'Company Name — Tagline',
  },
  robots: {
    index: true,
    follow: true,
  },
};
```

### Step 5 — JSON-LD Structured Data

Create a reusable JSON-LD component:

```typescript
// src/components/JsonLd.tsx
type JsonLdProps = {
  data: Record<string, unknown>;
};

export function JsonLd({ data }: JsonLdProps) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
```

**LocalBusiness schema:**

```typescript
// src/lib/structured-data.ts
export function buildLocalBusinessJsonLd(info: {
  name: string; description: string; url: string;
  phone: string; email: string;
  address: { street: string; city: string; region: string; postalCode: string; country: string };
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'LocalBusiness',
    name: info.name, description: info.description, url: info.url,
    telephone: info.phone, email: info.email,
    address: {
      '@type': 'PostalAddress',
      streetAddress: info.address.street,
      addressLocality: info.address.city,
      addressRegion: info.address.region,
      postalCode: info.address.postalCode,
      addressCountry: info.address.country,
    },
  };
}

export function buildWebSiteJsonLd(name: string, url: string) {
  return { '@context': 'https://schema.org', '@type': 'WebSite', name, url };
}
```

**Use in a page:**

```typescript
import { JsonLd } from '@/components/JsonLd';
import { buildLocalBusinessJsonLd } from '@/lib/structured-data';

export default async function HomePage({ params }: Props) {
  const { locale } = await params;
  setRequestLocale(locale);

  const businessData = buildLocalBusinessJsonLd({
    name: 'Company Name',
    description: 'Company description',
    url: 'https://www.example.com',
    phone: '+1-555-0100',
    email: 'info@example.com',
    address: {
      street: '123 Main St',
      city: 'City',
      region: 'State',
      postalCode: '12345',
      country: 'US',
    },
  });

  return (
    <>
      <JsonLd data={businessData} />
      <main>{/* page content */}</main>
    </>
  );
}
```

### Step 6 — next-sitemap Configuration

```bash
pnpm add -D next-sitemap
```

Create `next-sitemap.config.js` in the project root:

```javascript
/** @type {import('next-sitemap').IConfig} */
const config = {
  siteUrl: 'https://www.example.com',
  generateRobotsTxt: true,
  outDir: './out',
  // For static export, generate sitemap from the out/ directory
  output: 'export',
  trailingSlash: true,
  robotsTxtOptions: {
    policies: [
      {
        userAgent: '*',
        allow: '/',
      },
    ],
  },
  // Exclude non-page paths
  exclude: ['/404', '/500'],
};

module.exports = config;
```

Add the postbuild script to `package.json`:

```json
{
  "scripts": {
    "build": "next build",
    "postbuild": "next-sitemap --config next-sitemap.config.js"
  }
}
```

After `pnpm build`, the `out/` directory will contain:
- `sitemap.xml` — all pages across all locales
- `sitemap-0.xml` — individual sitemap (if paginated)
- `robots.txt` — with sitemap reference

### Step 7 — Canonical URL Generation Per Locale

```typescript
// src/lib/url.ts
import { routing } from '@/i18n/routing';

const BASE_URL = 'https://www.example.com';

export function getCanonicalUrl(locale: string, pathname: string = ''): string {
  const cleanPath = pathname.startsWith('/') ? pathname : `/${pathname}`;
  return `${BASE_URL}/${locale}${cleanPath === '/' ? '' : cleanPath}`;
}

export function getAlternateLanguages(pathname: string = '') {
  return Object.fromEntries(
    routing.locales.map((locale) => [
      locale,
      getCanonicalUrl(locale, pathname),
    ])
  );
}
```

Use in metadata:

```typescript
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { locale } = await params;

  return {
    alternates: {
      canonical: getCanonicalUrl(locale, '/about'),
      languages: getAlternateLanguages('/about'),
    },
  };
}
```

### Step 8 — Favicon and App Icons

Place icons in `src/app/`:

```
src/app/
├── favicon.ico          # 32x32 .ico
├── icon.png             # 512x512 .png (or icon.svg)
├── apple-icon.png       # 180x180 for Apple devices
└── opengraph-image.jpg  # 1200x630 default OG image
```

Next.js automatically generates the appropriate `<link>` and `<meta>` tags from these files. No manual `<Head>` configuration needed.

## Common Gotchas

### Tailwind classes not applying

1. Ensure `postcss.config.mjs` uses `@tailwindcss/postcss` (not `tailwindcss`)
2. Ensure `globals.css` starts with `@import "tailwindcss"`
3. Ensure `globals.css` is imported in your root or locale layout
4. With Turbopack, restart the dev server after PostCSS config changes

### Custom colors not available as classes

In Tailwind v4, custom colors must use the `--color-*` naming convention in `@theme`:
```css
@theme {
  --color-brand: #1B3A5C;  /* ✅ Available as bg-brand, text-brand */
}
```

### next/font variable not applied

The font's CSS variable must be applied to a parent element (usually `<html>`):
```tsx
<html className={inter.variable}>  {/* ✅ Required */}
```

And referenced in `@theme`:
```css
@theme {
  --font-sans: var(--font-inter);  /* Maps Tailwind's font-sans to Inter */
}
```

### OG images not showing on social platforms

- OG images must be absolute URLs (include full `https://...` domain)
- Recommended size: 1200×630px
- Test with [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/) and [Twitter Card Validator](https://cards-dev.twitter.com/validator)

### next-sitemap not finding pages

For static export, `next-sitemap` should run after `next build`. Set `outDir: './out'` in the config and use the `postbuild` script.


### Step 9 — Troubleshoot Common Issues

**Tailwind classes not applying**
- Ensure `globals.css` starts with `@import "tailwindcss"` (Tailwind v4 CSS-first, no `tailwind.config.ts`).
- Verify `globals.css` is imported in the root layout `app/layout.tsx`.

**`@theme` custom tokens not available as utilities**
- Token names must follow `--color-*`, `--font-*`, `--spacing-*` convention for auto-mapped utilities.
- Check for typos in the token name vs the utility class used.

**`generateMetadata` not showing in `<head>`**
- Only works in Server Components. If the file has `'use client'` at the top, move metadata to a separate server-side parent.

**JSON-LD not indexed by Google**
- Use `<script type="application/ld+json">` inside a Server Component, not a Client Component.
- Validate at https://search.google.com/test/rich-results.

**`next-sitemap` generating 404 paths**
- Ensure `generateStaticParams` is defined for all dynamic routes before running `next build`.

## Completion Checks

- [ ] `@import "tailwindcss"` in `globals.css` with `@theme` tokens
- [ ] `postcss.config.mjs` uses `@tailwindcss/postcss`
- [ ] Custom colors follow `--color-*` naming and work as Tailwind classes
- [ ] Google Font loaded via `next/font/google` with CSS variable
- [ ] Font variable applied to `<html>` element and mapped in `@theme`
- [ ] `globals.css` imported in root or locale layout
- [ ] `generateMetadata()` on every page with title, description, OG, canonical
- [ ] `alternates.languages` includes all locales for hreflang
- [ ] JSON-LD `<script>` tags render valid schema (test at schema.org validator)
- [ ] `next-sitemap` installed with `postbuild` script in `package.json`
- [ ] `robots.txt` and `sitemap.xml` appear in `out/` after build
- [ ] Responsive design tested: mobile-first classes with `sm:`, `md:`, `lg:` overrides
- [ ] `favicon.ico` and `icon.png` present in `src/app/`
- [ ] All OG image URLs are absolute (full domain)

## References

- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs)
- [Tailwind v4 Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
- [Next.js Metadata API](https://nextjs.org/docs/app/api-reference/functions/generate-metadata)
- [Next.js Static File Conventions (icons)](https://nextjs.org/docs/app/api-reference/file-conventions/metadata)
- [next-sitemap Documentation](https://github.com/iamvishnusankar/next-sitemap)
- [Schema.org LocalBusiness](https://schema.org/LocalBusiness)
- [Google Structured Data Testing Tool](https://search.google.com/test/rich-results)
