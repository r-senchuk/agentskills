---
name: nextjs-ssg
description: "Use when scaffolding, configuring, or troubleshooting Next.js 15 App Router projects with static export (output: 'export'). Covers project setup, directory structure, next.config.ts, generateStaticParams, build verification, and static export limitations. Do not use for server-side rendering, API routes, database integration, or non-Next.js frameworks."
argument-hint: "Project path or name, target features (i18n, SEO, etc.), current error or goal."
user-invocable: false
---

# Next.js 15 Static Site Generation (SSG)

## When To Use

- **Scaffold**: Creating a new Next.js 15 project configured for fully static export.
- **Configure**: Setting up `next.config.ts` with `output: 'export'` and related options.
- **Structure**: Designing App Router directory layout for static pages with dynamic segments.
- **Debug**: Fixing build failures related to static export — missing `generateStaticParams`, incompatible features, async params.
- **Verify**: Validating that `pnpm build` produces correct static output in the `out/` directory.

Do NOT use for server-side rendering (SSR), incremental static regeneration (ISR), API route development, database integration, or non-Next.js frameworks.

## Inputs To Collect First

1. **Project path** — where the project lives or should be created
2. **Target features** — which capabilities are needed (i18n, SEO, specific pages)
3. **Existing project?** — new scaffold or modifying an existing Next.js project
4. **Current error** — if debugging, the exact build error message

## Procedure

### Step 1 — Scaffold a New Project

For a brand-new project, use pnpm:

```bash
pnpm create next-app@latest my-app \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --use-pnpm \
  --no-turbopack \
  --import-alias "@/*"
```

Or for manual setup:

```bash
mkdir my-app && cd my-app
pnpm init
pnpm add next@latest react@latest react-dom@latest
pnpm add -D typescript @types/react @types/react-dom @types/node
```

After scaffolding, verify the project runs:

```bash
cd my-app
pnpm dev
```

### Step 2 — Configure next.config.ts for Static Export

Create or update `next.config.ts`:

```typescript
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
```

Key settings:
- `output: 'export'` — generates fully static HTML into `out/`
- `trailingSlash: true` — produces `/about/index.html` instead of `/about.html` (better for static hosting)
- `images.unoptimized: true` — required because `next/image` optimization needs a server

If using next-intl, wrap with the plugin:

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

### Step 3 — App Router Directory Structure

Standard SSG directory layout:

```
src/
├── app/
│   ├── layout.tsx              # Root layout (html, body tags)
│   ├── not-found.tsx           # Global 404 page
│   └── [locale]/
│       ├── layout.tsx          # Locale layout (providers, nav)
│       ├── page.tsx            # Home page
│       ├── about/
│       │   └── page.tsx
│       ├── services/
│       │   └── page.tsx
│       ├── contact/
│       │   └── page.tsx
│       └── blog/
│           ├── page.tsx        # Blog listing
│           └── [slug]/
│               └── page.tsx    # Individual blog post
├── components/
│   ├── Header.tsx
│   ├── Footer.tsx
│   └── ...
└── lib/
    └── ...
```

Every `page.tsx` under a dynamic segment (`[locale]`, `[slug]`) MUST export `generateStaticParams`.

### Step 4 — TypeScript Configuration

`tsconfig.json` for Next.js 15 with strict mode:

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### Step 5 — generateStaticParams for Dynamic Routes

Every dynamic route segment MUST export `generateStaticParams()` when using `output: 'export'`.

**For locale segments:**

```typescript
// src/app/[locale]/layout.tsx or page.tsx
import { routing } from '@/i18n/routing';

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}
```

**For nested dynamic segments (e.g., blog posts):**

```typescript
// src/app/[locale]/blog/[slug]/page.tsx
import { routing } from '@/i18n/routing';

export function generateStaticParams() {
  const slugs = ['first-post', 'second-post', 'third-post'];

  return routing.locales.flatMap((locale) =>
    slugs.map((slug) => ({ locale, slug }))
  );
}
```

**For catch-all routes:**

```typescript
// src/app/[locale]/docs/[...slug]/page.tsx
export function generateStaticParams() {
  return [
    { locale: 'en', slug: ['getting-started'] },
    { locale: 'en', slug: ['guides', 'setup'] },
    { locale: 'it', slug: ['getting-started'] },
  ];
}
```

**Critical**: In Next.js 15, `params` is a Promise — always await it:

```typescript
type Props = {
  params: Promise<{ locale: string; slug: string }>;
};

export default async function Page({ params }: Props) {
  const { locale, slug } = await params;
  // ...
}
```

### Step 6 — Root Layout

```typescript
// src/app/layout.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: {
    template: '%s | Site Name',
    default: 'Site Name',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
```

Note: The root layout should NOT include `<html>` or `<body>` tags when using a `[locale]` sub-layout that sets the `lang` attribute. Place `<html>` and `<body>` in the locale layout instead.

### Step 7 — Build and Verify

```bash
# Build the static site
pnpm build

# Verify output
ls -la out/

# Check that locale directories exist
ls out/en/ out/it/

# Verify HTML files were generated
find out -name "*.html" | head -20

# Optional: serve locally to test
pnpm add -D serve
pnpm exec serve out
```

Expected output structure:

```
out/
├── en/
│   ├── index.html
│   ├── about/
│   │   └── index.html
│   └── services/
│       └── index.html
├── it/
│   ├── index.html
│   ├── about/
│   │   └── index.html
│   └── services/
│       └── index.html
├── _next/
│   └── static/
│       ├── chunks/
│       └── css/
└── index.html
```

## Common Gotchas

### What does NOT work with `output: 'export'`

| Feature | Status | Workaround |
|---|---|---|
| `middleware.ts` | ❌ Ignored in production | Handle locale detection via `[locale]` segment + default redirect in root `page.tsx` |
| API Routes (`app/api/`) | ❌ Not generated | Use external API or build-time data fetching |
| ISR (`revalidate`) | ❌ Not supported | Full rebuild on content change |
| `cookies()`, `headers()` | ❌ Build error | Remove server-only APIs |
| `searchParams` in pages | ❌ Forces dynamic rendering | Use client-side `useSearchParams()` with Suspense |
| Server Actions | ❌ Not available | Use client-side form handling |
| `next/image` optimization | ⚠️ Requires `unoptimized: true` | Set in next.config.ts or use custom loader |
| `dynamicParams = true` | ❌ All params must be known at build time | Return all possible params from `generateStaticParams` |
| Draft Mode | ❌ Requires server | Not available in static export |

### Async params in Next.js 15

In Next.js 15, `params` and `searchParams` are Promises. This is a breaking change from Next.js 14:

```typescript
// ❌ Next.js 14 style — WILL BREAK
export default function Page({ params }: { params: { locale: string } }) {
  const locale = params.locale;
}

// ✅ Next.js 15 style — correct
export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
}
```

### Missing generateStaticParams

If you see: `Page is missing exported function 'generateStaticParams'`

Every dynamic route segment (`[param]`) MUST export `generateStaticParams` when using `output: 'export'`. This includes `[locale]` segments — add it to the layout or the first page that uses the param.

### Image handling

Always set `unoptimized: true` in `next.config.ts` when using `output: 'export'`. Without it, `next/image` tries to use the server-based optimizer which doesn't exist in static export.

For responsive images with static export:

```typescript
import Image from 'next/image';

// Use with explicit width/height or fill
<Image
  src="/images/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority
/>
```

## Completion Checks

- [ ] `next.config.ts` has `output: 'export'`, `trailingSlash: true`, `images.unoptimized: true`
- [ ] Every dynamic route segment exports `generateStaticParams()`
- [ ] All page components use async `params` (Next.js 15 convention)
- [ ] No server-only APIs used (`cookies()`, `headers()`, `draftMode()`)
- [ ] No API routes in `app/api/`
- [ ] No `revalidate` exports (ISR is incompatible with static export)
- [ ] `pnpm build` completes without errors
- [ ] `out/` directory contains expected HTML files for all routes and locales
- [ ] TypeScript strict mode enabled in `tsconfig.json`
- [ ] No `searchParams` usage in page components (use client-side `useSearchParams` with Suspense if needed)

## References

- [Next.js Static Exports Guide](https://nextjs.org/docs/app/building-your-application/deploying/static-exports)
- [Next.js App Router Documentation](https://nextjs.org/docs/app)
- [generateStaticParams API Reference](https://nextjs.org/docs/app/api-reference/functions/generate-static-params)
