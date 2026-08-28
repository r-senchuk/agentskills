# Routing and Message Configuration

## Step 2 — Define routing (`src/i18n/routing.ts`)

```typescript
import { defineRouting } from 'next-intl/routing';

export const routing = defineRouting({
  locales: ['en', 'it'],
  defaultLocale: 'en',
  pathnames: {
    '/': '/',
    '/about': { en: '/about', it: '/chi-siamo' },
    '/services': { en: '/services', it: '/servizi' },
    '/contact': { en: '/contact', it: '/contatti' },
  },
});
```

## Navigation (`src/i18n/navigation.ts`)

**Always import `Link`, `redirect`, `useRouter`, and `usePathname` from here — never from `next/navigation` directly.**

```typescript
import { createNavigation } from 'next-intl/navigation';
import { routing } from './routing';

export const { Link, redirect, usePathname, useRouter, getPathname } =
  createNavigation(routing);
```

Pass logical paths such as `href="/services"`, never locale-prefixed paths like `/en/services`.

## Message loading (`src/i18n/request.ts`)

```typescript
import { getRequestConfig } from 'next-intl/server';
import { hasLocale } from 'next-intl';
import { routing } from './routing';

export default getRequestConfig(async ({ requestLocale }) => {
  let locale = await requestLocale;

  if (!hasLocale(routing.locales, locale)) {
    locale = routing.defaultLocale;
  }

  return {
    locale,
    messages: (await import(`../../messages/${locale}.json`)).default,
  };
});
```

## next.config.ts plugin

```typescript
import type { NextConfig } from 'next';
import createNextIntlPlugin from 'next-intl/plugin';

const withNextIntl = createNextIntlPlugin();

const nextConfig: NextConfig = {
  output: 'export',
  trailingSlash: true,
  images: { unoptimized: true },
};

export default withNextIntl(nextConfig);
```

Custom request path: `createNextIntlPlugin('./src/i18n/request.ts')`.

## Message files (`messages/<locale>.json`)

Create one JSON file per locale with identical key structure. Use flat top-level keys matching page or component names; nest only for logical grouping within a namespace.

## Locale proxy (`src/proxy.ts`) — development only

```typescript
import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

export default createMiddleware(routing);

export const config = {
  matcher: '/((?!api|trpc|_next|_vercel|.*\\..*).*)',
};
```

**Decision tree:**

| Project mode | `src/proxy.ts` |
|---|---|
| `output: 'export'` (production static) | **Do not add** — proxy is unsupported |
| Local dev with locale-prefixed URLs | Add for dev convenience |
| Static host handles `/` → default locale | Skip proxy; configure CDN/host redirect |

For static export, do not use `redirect()` in a root page — redirects require a server. Configure the static host/CDN to redirect `/` to `/${defaultLocale}/`, or link only to locale-prefixed URLs.
