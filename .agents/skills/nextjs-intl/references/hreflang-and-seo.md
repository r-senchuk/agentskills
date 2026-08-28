# Hreflang and SEO

## Hreflang helper

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

  tags.push({
    rel: 'alternate',
    hrefLang: 'x-default',
    href: `${baseUrl}${pathname}`,
  });

  return tags;
}
```

## Use in generateMetadata

```typescript
import type { Metadata } from 'next';
import { getTranslations } from 'next-intl/server';
import { routing } from '@/i18n/routing';

const BASE_URL = 'https://www.example.com';

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: 'metadata' });

  return {
    title: t('title'),
    alternates: {
      languages: Object.fromEntries(
        routing.locales.map((loc) => [loc, `${BASE_URL}/${loc}`])
      ),
    },
  };
}
```

For full metadata templates including OG tags, load `.agents/skills/nextjs-tailwind-seo/SKILL.md`.
