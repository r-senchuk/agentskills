---
name: nextjs-intl
description: "Use when setting up, configuring, or troubleshooting next-intl internationalization in Next.js 15 App Router projects, especially with static export. Covers defineRouting, locale routing, message files, translations, locale switcher, hreflang generation, and static export compatibility. Do not use for next-i18next, server-side-only i18n, or non-Next.js i18n solutions."
argument-hint: "Locales to support, default locale, current error or i18n goal, whether using static export."
user-invocable: false
---

# next-intl with Next.js 15 App Router

## When To Use

- **Setup**: Installing and configuring next-intl in a Next.js 15 App Router project.
- **Routing**: Configuring locale routing with `defineRouting`, localized pathnames, and `[locale]` segments.
- **Translations**: Creating message files, using `useTranslations()`, and structuring translation namespaces.
- **Static export**: Making next-intl work with `output: 'export'` — `setRequestLocale`, `generateStaticParams`, locale detection without middleware.
- **Components**: Building locale switcher, language selector, and locale-aware navigation.
- **SEO**: Generating hreflang tags and locale-specific metadata from the routing config.

Do NOT use for `next-i18next` (Pages Router only), server-side-only i18n at request time, or non-Next.js i18n libraries.

## Inputs To Collect First

1. **Locales** — which locales to support (e.g., `['en', 'it']`)
2. **Default locale** — the primary language (e.g., `'en'`)
3. **Static export?** — whether the project uses `output: 'export'`
4. **Localized pathnames?** — whether URLs should be translated (e.g., `/en/about` vs `/it/chi-siamo`)
5. **Existing setup** — new installation or modifying an existing next-intl config

## Procedure

### Step 1 — Install next-intl

```bash
pnpm add next-intl
```

### Step 2 — Define Routing Configuration

Create `src/i18n/routing.ts`:

```typescript
import { defineRouting } from 'next-intl/routing';

export const routing = defineRouting({
  locales: ['en', 'it'],
  defaultLocale: 'en',
  // Optional: localized pathnames
  pathnames: {
    '/': '/',
    '/about': {
      en: '/about',
      it: '/chi-siamo',
    },
    '/services': {
      en: '/services',
      it: '/servizi',
    },
    '/contact': {
      en: '/contact',
      it: '/contatti',
    },
  },
});
```

Create navigation utilities in `src/i18n/navigation.ts`:

```typescript
import { createNavigation } from 'next-intl/navigation';
import { routing } from './routing';

export const { Link, redirect, usePathname, useRouter, getPathname } =
  createNavigation(routing);
```

### Step 3 — Configure Message Loading

Create `src/i18n/request.ts`:

```typescript
import { getRequestConfig } from 'next-intl/server';
import { routing } from './routing';

export default getRequestConfig(async ({ requestLocale }) => {
  let locale = await requestLocale;

  // Validate that the incoming locale is supported
  if (!locale || !routing.locales.includes(locale as any)) {
    locale = routing.defaultLocale;
  }

  return {
    locale,
    messages: (await import(`../../messages/${locale}.json`)).default,
  };
});
```

### Step 4 — Configure next.config.ts with next-intl Plugin

```typescript
import type { NextConfig } from 'next';
import createNextIntlPlugin from 'next-intl/plugin';

const withNextIntl = createNextIntlPlugin();

const nextConfig: NextConfig = {
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
};

export default withNextIntl(nextConfig);
```

The plugin automatically discovers `src/i18n/request.ts`. To use a custom path:

```typescript
const withNextIntl = createNextIntlPlugin('./src/i18n/request.ts');
```

### Step 5 — Create Message Files

Create `messages/en.json`:

```json
{
  "metadata": {
    "title": "Company Name",
    "description": "Your company description"
  },
  "navigation": {
    "home": "Home",
    "about": "About",
    "services": "Services",
    "contact": "Contact"
  },
  "home": {
    "hero": {
      "title": "Welcome to Our Company",
      "subtitle": "We build great things",
      "cta": "Get a Quote"
    }
  },
  "about": {
    "title": "About Us",
    "description": "Learn about our company"
  },
  "common": {
    "readMore": "Read more",
    "learnMore": "Learn more",
    "backToHome": "Back to home"
  }
}
```

Create `messages/it.json` with the same structure but Italian translations.

**Namespace convention**: Use flat top-level keys that match page or component names. Nest only for logical grouping within a namespace.

### Step 6 — Middleware (Development Only)

Create `src/middleware.ts`:

```typescript
import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

export default createMiddleware(routing);

export const config = {
  matcher: ['/', '/(en|it)/:path*'],
};
```

**Critical for static export**: Middleware runs in `pnpm dev` but is completely ignored when building with `output: 'export'`. In production, locale detection must be handled differently:

- The root `page.tsx` should redirect to the default locale
- Or configure your static host to redirect `/` → `/en/`

Root redirect approach:

```typescript
// src/app/page.tsx
import { redirect } from 'next/navigation';
import { routing } from '@/i18n/routing';

export default function RootPage() {
  redirect(`/${routing.defaultLocale}`);
}
```

### Step 7 — Locale Layout with Provider

```typescript
// src/app/[locale]/layout.tsx
import { NextIntlClientProvider, useMessages } from 'next-intl';
import { notFound } from 'next/navigation';
import { setRequestLocale, getMessages } from 'next-intl/server';
import { routing } from '@/i18n/routing';

type Props = {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
};

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export default async function LocaleLayout({ children, params }: Props) {
  const { locale } = await params;

  // Validate locale
  if (!routing.locales.includes(locale as any)) {
    notFound();
  }

  // Enable static rendering
  setRequestLocale(locale);

  // Load messages for client provider
  const messages = await getMessages();

  return (
    <html lang={locale}>
      <body>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

### Step 8 — Page Components with Translations

**Server component pattern:**

```typescript
// src/app/[locale]/page.tsx
import { useTranslations } from 'next-intl';
import { setRequestLocale } from 'next-intl/server';

type Props = {
  params: Promise<{ locale: string }>;
};

export default async function HomePage({ params }: Props) {
  const { locale } = await params;
  setRequestLocale(locale);

  // useTranslations works in server components after setRequestLocale
  const t = useTranslations('home');

  return (
    <main>
      <h1>{t('hero.title')}</h1>
      <p>{t('hero.subtitle')}</p>
    </main>
  );
}
```

**Client component pattern:**

```typescript
'use client';

import { useTranslations } from 'next-intl';

export function HeroSection() {
  const t = useTranslations('home.hero');

  return (
    <section>
      <h1>{t('title')}</h1>
      <p>{t('subtitle')}</p>
      <button>{t('cta')}</button>
    </section>
  );
}
```

**Rich text and interpolation:**

```typescript
// messages/en.json
// "greeting": "Hello, {name}!"
// "terms": "By signing up, you agree to our <link>terms</link>."

const t = useTranslations('common');

// Interpolation
t('greeting', { name: 'Roman' });

// Rich text
t.rich('terms', {
  link: (chunks) => <a href="/terms">{chunks}</a>,
});
```

### Step 9 — setRequestLocale for Static Export

**This is the critical piece for `output: 'export'` compatibility.**

Every page and layout under `[locale]` that uses `useTranslations` or `getTranslations` in a server component MUST call `setRequestLocale(locale)` at the top of the component:

```typescript
import { setRequestLocale } from 'next-intl/server';

export default async function AboutPage({ params }: Props) {
  const { locale } = await params;
  setRequestLocale(locale);  // MUST be called before any translation function

  const t = useTranslations('about');
  // ...
}
```

Without this call, next-intl cannot determine the active locale during static generation and the build will fail.

**Rules:**
- Call `setRequestLocale` in every `page.tsx` and `layout.tsx` under `[locale]`
- Call it before any `useTranslations`, `getTranslations`, or `getMessages`
- The locale value must come from `params`, not from a hardcoded string
- Both server components and async components need this call

### Step 10 — Locale Switcher Component

```typescript
'use client';

import { useLocale } from 'next-intl';
import { usePathname, useRouter } from '@/i18n/navigation';
import { routing } from '@/i18n/routing';

const localeLabels: Record<string, string> = {
  en: 'English',
  it: 'Italiano',
};

export function LocaleSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  function onLocaleChange(nextLocale: string) {
    router.replace(pathname, { locale: nextLocale });
  }

  return (
    <div>
      {routing.locales.map((loc) => (
        <button
          key={loc}
          onClick={() => onLocaleChange(loc)}
          disabled={loc === locale}
          aria-label={`Switch to ${localeLabels[loc]}`}
        >
          {localeLabels[loc]}
        </button>
      ))}
    </div>
  );
}
```

### Step 11 — Hreflang Generation

Generate hreflang tags from the routing config for SEO:

```typescript
// src/lib/hreflang.ts
import { routing } from '@/i18n/routing';

type HreflangEntry = {
  rel: 'alternate';
  hrefLang: string;
  href: string;
};

export function generateHreflangTags(
  pathname: string,
  baseUrl: string
): HreflangEntry[] {
  const tags: HreflangEntry[] = routing.locales.map((locale) => {
    const localePath = locale === routing.defaultLocale
      ? pathname
      : `/${locale}${pathname}`;

    return {
      rel: 'alternate',
      hrefLang: locale,
      href: `${baseUrl}${localePath}`,
    };
  });

  // x-default points to default locale
  tags.push({
    rel: 'alternate',
    hrefLang: 'x-default',
    href: `${baseUrl}${pathname}`,
  });

  return tags;
}
```

Use in `generateMetadata`:

```typescript
import { generateHreflangTags } from '@/lib/hreflang';

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: 'metadata' });

  return {
    title: t('title'),
    alternates: {
      languages: Object.fromEntries(
        routing.locales.map((loc) => [
          loc,
          `${BASE_URL}/${loc}`,
        ])
      ),
    },
  };
}
```

## Common Gotchas

### "Unable to find next-intl locale" build error

The component is missing `setRequestLocale(locale)` before calling `useTranslations`. Add it to every page and layout under `[locale]`.

### Middleware not working in production static export

Middleware is completely ignored with `output: 'export'`. Handle locale detection via:
1. Root `page.tsx` that redirects to `/${defaultLocale}`
2. Static host configuration (e.g., Netlify `_redirects`, Cloudflare redirect rules)

### Message file not found

Ensure the import path in `request.ts` correctly resolves. With `src/` directory:
```typescript
messages: (await import(`../../messages/${locale}.json`)).default
```

The `../../` goes up from `src/i18n/` to the project root where `messages/` lives.

### Translations not updating in development

If translations don't update after changing JSON files, restart the dev server. The next-intl plugin caches message imports.

### Type safety for translation keys

For type-safe translations, create a global type declaration:

```typescript
// src/types/next-intl.d.ts
import en from '../../messages/en.json';

type Messages = typeof en;

declare global {
  interface IntlMessages extends Messages {}
}
```

## Completion Checks

- [ ] `pnpm add next-intl` installed
- [ ] `src/i18n/routing.ts` exists with `defineRouting` and all supported locales
- [ ] `src/i18n/request.ts` exists with `getRequestConfig` and correct message import path
- [ ] `src/i18n/navigation.ts` exists with `createNavigation`
- [ ] `next.config.ts` uses `createNextIntlPlugin` wrapper
- [ ] `messages/` directory has a JSON file for every locale in `routing.locales`
- [ ] All JSON files have identical key structure
- [ ] `src/middleware.ts` exists for development routing
- [ ] `app/[locale]/layout.tsx` includes `NextIntlClientProvider`, `setRequestLocale`, and `generateStaticParams`
- [ ] Every page under `[locale]` calls `setRequestLocale(locale)` before translations
- [ ] Every page under `[locale]` uses async `params` pattern (Next.js 15)
- [ ] Locale switcher component uses `useRouter` and `usePathname` from `@/i18n/navigation`
- [ ] `pnpm build` succeeds with all locales generated in `out/`

## References

- [next-intl App Router Getting Started](https://next-intl.dev/docs/getting-started/app-router)
- [next-intl Static Rendering](https://next-intl.dev/docs/getting-started/app-router/with-i18n-routing#static-rendering)
- [next-intl defineRouting API](https://next-intl.dev/docs/routing#define-routing)
- [next-intl Navigation APIs](https://next-intl.dev/docs/routing/navigation)
