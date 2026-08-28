# Dynamic Routes and Layouts

## generateStaticParams — locale segments

```typescript
import { routing } from '@/i18n/routing';

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}
```

## Nested dynamic segments

```typescript
export function generateStaticParams() {
  const slugs = ['first-post', 'second-post'];

  return routing.locales.flatMap((locale) =>
    slugs.map((slug) => ({ locale, slug }))
  );
}
```

## Catch-all routes

```typescript
export function generateStaticParams() {
  return [
    { locale: 'en', slug: ['getting-started'] },
    { locale: 'en', slug: ['guides', 'setup'] },
    { locale: 'it', slug: ['getting-started'] },
  ];
}
```

## Async params (Next.js 16)

```typescript
type Props = {
  params: Promise<{ locale: string; slug: string }>;
};

export default async function Page({ params }: Props) {
  const { locale, slug } = await params;
}
```

## Root layout rules

When all routes are under `[locale]`, `app/[locale]/layout.tsx` is the root layout and MUST render `<html>` and `<body>`. Do not also create `app/layout.tsx` for the same tree.

```typescript
export default async function RootLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;

  return (
    <html lang={locale}>
      <body>{children}</body>
    </html>
  );
}
```

## Image handling

Always set `images.unoptimized: true` in `next.config.ts`. Use explicit `width`/`height` or `fill` on `next/image`.
