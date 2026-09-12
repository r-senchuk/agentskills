---
name: nextjs-tailwind-seo
description: "Use when setting up Tailwind CSS 4.3, implementing SEO metadata, configuring fonts, or adding structured data in Next.js 16.2 App Router projects. Covers Tailwind v4 CSS-first config, custom design tokens, generateMetadata, JSON-LD, built-in app/sitemap.ts and robots.ts, OG tags, canonical URLs, and responsive design patterns. Do not use for backend development, non-Tailwind styling, or design/branding decisions."
argument-hint: "SEO goal (metadata, sitemap, JSON-LD), Tailwind customization target (tokens, responsive), or font setup."
user-invocable: false
license: MIT
compatibility: "Requires Node.js 20.9+, Next.js 16.2.11+ (Active LTS), TypeScript 7.0+, and pnpm."
paths:
  - "**/globals.css"
  - "**/layout.tsx"
  - "**/sitemap.ts"
  - "**/robots.ts"
metadata:
  version: "1.2.0"
  last-updated: "2026-08-28"
---

# Tailwind CSS 4.3 & SEO for Next.js 16.2

## When To Use

- **Tailwind setup**: Configuring Tailwind CSS 4.3 with Next.js 16.2, custom design tokens, PostCSS.
- **Fonts**: Integrating Google Fonts via `next/font/google` with Tailwind CSS variables.
- **Responsive design**: Implementing mobile-first responsive layouts with Tailwind breakpoints.
- **SEO metadata**: Writing `generateMetadata()` for per-page title, description, OG tags, and canonical URLs.
- **Structured data**: Adding JSON-LD schemas (LocalBusiness, WebSite, Service, etc.).
- **Sitemap**: Configuring built-in `app/sitemap.ts` and `app/robots.ts` (preferred) or legacy `next-sitemap` for existing projects.
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

Tailwind v4 uses CSS-first configuration. No `tailwind.config.js` is required for most setups.

```bash
pnpm add tailwindcss @tailwindcss/postcss postcss
```

1. Create `postcss.config.mjs` with `@tailwindcss/postcss` plugin.
2. Add `@import "tailwindcss"` and `@theme { ... }` tokens to `globals.css`.
3. Define custom colors as `--color-*` (available as `bg-*`, `text-*` classes).
4. Map fonts via `--font-sans: var(--font-inter)` after loading with `next/font`.
5. Use `@source inline()` to safelist generated classes in Tailwind 4.3; do not restore v3 `safelist` config.

Key v4 differences: no `tailwind.config.js`, `@import "tailwindcss"` replaces `@tailwind` directives, PostCSS plugin is `@tailwindcss/postcss`.

### Step 2 — Google Fonts with next/font

1. Load font in locale layout: `Inter({ subsets: ['latin'], variable: '--font-inter' })`.
2. Apply `className={inter.variable}` on `<html>`.
3. Map `--font-sans: var(--font-inter)` in `@theme`.
4. Use `font-sans` class on `<body>`.

### Step 3 — Responsive Design Patterns

Mobile-first: base styles for mobile, breakpoint prefixes for larger screens.

| Prefix | Min-width | Target |
|---|---|---|
| _(none)_ | 0px | Mobile (default) |
| `sm:` | 640px | Large phones |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Desktop |
| `xl:` | 1280px | Large desktop |

Common patterns: `max-w-7xl px-4 sm:px-6 lg:px-8`, `grid-cols-1 md:grid-cols-2 lg:grid-cols-3`, `text-3xl sm:text-4xl lg:text-5xl`, `hidden lg:flex` / `lg:hidden`.

### Step 4 — generateMetadata for Per-Page SEO

1. Set `metadataBase` in root layout.
2. Export `generateMetadata()` on every page with title, description, canonical, and `alternates.languages`.
3. Include `openGraph` and `twitter` blocks with absolute image URLs.
4. Use translation namespaces when paired with next-intl.

See [metadata patterns](./references/metadata-patterns.md) for full templates and canonical URL helpers.

### Step 5 — JSON-LD Structured Data

1. Create a reusable `JsonLd` component with `dangerouslySetInnerHTML`.
2. Build schema objects in `src/lib/structured-data.ts` (LocalBusiness, WebSite).
3. Render `<JsonLd data={...} />` in page components.
4. Validate with Google Rich Results Test.

See [JSON-LD schemas](./references/json-ld-schemas.md).

### Step 6 — Sitemap and Robots

**Prefer built-in `app/sitemap.ts` and `app/robots.ts`** for new projects.

1. Export a `MetadataRoute.Sitemap` function with locale-aware URLs and `alternates.languages`.
2. Export `app/robots.ts` pointing to the sitemap URL.
3. Verify `sitemap.xml` and `robots.txt` after `pnpm build`.
4. Use `next-sitemap` only for legacy projects — see reference for config.

See [sitemap and robots](./references/sitemap-robots.md).

### Step 7 — Canonical URL Generation Per Locale

Use `getCanonicalUrl()` and `getAlternateLanguages()` helpers from [metadata patterns](./references/metadata-patterns.md). Wire into every `generateMetadata()` export.

### Step 8 — Favicon and App Icons

Place in `src/app/`:

```
favicon.ico          # 32x32
icon.png             # 512x512
apple-icon.png       # 180x180
opengraph-image.jpg  # 1200x630 default OG
```

Next.js generates `<link>` and `<meta>` tags automatically. No manual `<Head>` needed.

If Tailwind classes, fonts, OG images, or sitemap output fail, see [troubleshooting](./references/troubleshooting.md).

## Completion Checks

- [ ] `@import "tailwindcss"` in `globals.css` with `@theme` tokens
- [ ] `postcss.config.mjs` uses `@tailwindcss/postcss`
- [ ] Custom colors follow `--color-*` naming and work as Tailwind classes
- [ ] Google Font loaded via `next/font/google` with CSS variable on `<html>`
- [ ] `globals.css` imported in root or locale layout
- [ ] `generateMetadata()` on every page with title, description, OG, canonical
- [ ] `alternates.languages` includes all locales for hreflang
- [ ] JSON-LD renders valid schema (test at schema.org / Rich Results Test)
- [ ] Built-in `app/sitemap.ts` used OR legacy `next-sitemap` with `postbuild` script
- [ ] `robots.txt` and `sitemap.xml` appear after build
- [ ] Responsive design uses mobile-first `sm:`, `md:`, `lg:` overrides
- [ ] `favicon.ico` and `icon.png` present in `src/app/`
- [ ] All OG image URLs are absolute (full domain)

## References

- [Metadata patterns](./references/metadata-patterns.md)
- [JSON-LD schemas](./references/json-ld-schemas.md)
- [Sitemap and robots](./references/sitemap-robots.md)
- [Troubleshooting](./references/troubleshooting.md)
- [External documentation](./references/external-links.md)
