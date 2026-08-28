# Page Components and Locale Switcher

## Locale layout (`src/app/[locale]/layout.tsx`)

```typescript
import { NextIntlClientProvider } from 'next-intl';
import { hasLocale } from 'next-intl';
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

  if (!hasLocale(routing.locales, locale)) {
    notFound();
  }

  setRequestLocale(locale);
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

## Server page pattern

```typescript
import { useTranslations } from 'next-intl';
import { setRequestLocale } from 'next-intl/server';

export default async function HomePage({ params }: Props) {
  const { locale } = await params;
  setRequestLocale(locale);

  const t = useTranslations('home');

  return (
    <main>
      <h1>{t('hero.title')}</h1>
      <p>{t('hero.subtitle')}</p>
    </main>
  );
}
```

## Client component pattern

```typescript
'use client';

import { useTranslations } from 'next-intl';

export function HeroSection() {
  const t = useTranslations('home.hero');
  return (
    <section>
      <h1>{t('title')}</h1>
      <p>{t('subtitle')}</p>
    </section>
  );
}
```

## Rich text and interpolation

```typescript
t('greeting', { name: 'Roman' });

t.rich('terms', {
  link: (chunks) => <a href="/terms">{chunks}</a>,
});
```

## setRequestLocale (required for static export)

Every page and layout under `[locale]` that uses translations in a server component MUST call `setRequestLocale(locale)` before any `useTranslations`, `getTranslations`, or `getMessages`:

- Locale must come from `params`, not a hardcoded string
- Call in every `page.tsx` and `layout.tsx` under `[locale]`
- Without this, static generation fails with "Unable to find next-intl locale"

## Locale switcher

```typescript
'use client';

import { useLocale } from 'next-intl';
import { usePathname, useRouter } from '@/i18n/navigation';
import { routing } from '@/i18n/routing';

export function LocaleSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  return (
    <div>
      {routing.locales.map((loc) => (
        <button
          key={loc}
          onClick={() => router.replace(pathname, { locale: loc })}
          disabled={loc === locale}
        >
          {loc}
        </button>
      ))}
    </div>
  );
}
```

Must use `useRouter` and `usePathname` from `@/i18n/navigation`, not `next/navigation`.
