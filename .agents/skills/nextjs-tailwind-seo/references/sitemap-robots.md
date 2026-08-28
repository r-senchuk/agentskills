# Sitemap and Robots

Next.js 16 has built-in `app/sitemap.ts` and `app/robots.ts` conventions. **Prefer these for new projects** over the `next-sitemap` npm package.

## Option A: Built-in `app/sitemap.ts` (recommended)

```typescript
// app/sitemap.ts
import type { MetadataRoute } from 'next';
import { routing } from '@/i18n/routing';

const BASE_URL = 'https://www.example.com';

export default function sitemap(): MetadataRoute.Sitemap {
  const pages = ['', '/about', '/services', '/contact'];
  const entries: MetadataRoute.Sitemap = [];

  for (const locale of routing.locales) {
    for (const page of pages) {
      entries.push({
        url: `${BASE_URL}/${locale}${page}`,
        lastModified: new Date(),
        changeFrequency: page === '' ? 'yearly' : 'monthly',
        priority: page === '' ? 1 : 0.8,
        alternates: {
          languages: Object.fromEntries(
            routing.locales.map((loc) => [loc, `${BASE_URL}/${loc}${page}`])
          ),
        },
      });
    }
  }

  return entries;
}
```

## Built-in `app/robots.ts`

```typescript
// app/robots.ts
import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
    },
    sitemap: 'https://www.example.com/sitemap.xml',
  };
}
```

After `pnpm build`, verify `sitemap.xml` and `robots.txt` in `out/` (static export) or the build output.

## Option B: next-sitemap (legacy projects only)

```bash
pnpm add -D next-sitemap
```

```javascript
// next-sitemap.config.js
/** @type {import('next-sitemap').IConfig} */
const config = {
  siteUrl: 'https://www.example.com',
  generateRobotsTxt: true,
  outDir: './out',
  output: 'export',
  trailingSlash: true,
  robotsTxtOptions: {
    policies: [{ userAgent: '*', allow: '/' }],
  },
  exclude: ['/404', '/500'],
};

module.exports = config;
```

```json
{
  "scripts": {
    "build": "next build",
    "postbuild": "next-sitemap --config next-sitemap.config.js"
  }
}
```

For static export, `next-sitemap` must run after `next build` with `outDir: './out'`.
