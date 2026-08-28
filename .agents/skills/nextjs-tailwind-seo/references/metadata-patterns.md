# generateMetadata Patterns

## Per-page metadata with next-intl

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

## Root layout metadataBase template

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

## Canonical URL helpers

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
