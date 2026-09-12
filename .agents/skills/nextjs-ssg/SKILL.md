---
name: nextjs-ssg
description: "Use when scaffolding, configuring, or troubleshooting Next.js 16 App Router projects with static export (output: 'export'). Covers project setup, directory structure, next.config.ts, generateStaticParams, build verification, and static export limitations. Use when user asks to 'create static Next.js site', 'set up Next.js static export', 'fix Next.js build errors', or 'configure next.config.ts for SSG'. Do not use for server-side rendering, API routes, database integration, or non-Next.js frameworks."
argument-hint: "Project path or name, target features (i18n, SEO, etc.), current error or goal."
user-invocable: false
license: MIT
compatibility: "Requires Node.js 20.9+, Next.js 16.2.11+ (Active LTS), TypeScript 7.0+, and pnpm."
paths:
  - "next.config.*"
  - "**/app/**"
  - "tsconfig.json"
metadata:
  author: "Roman Senchuk"
  version: "1.4.0"
  last-updated: "2026-08-28"
---

# Next.js 16.2 Static Site Generation (SSG)

## When To Use

- **Scaffold**: Creating a new Next.js 16 project configured for fully static export.
- **Configure**: Setting up `next.config.ts` with `output: 'export'` and related options.
- **Structure**: Designing App Router directory layout for static pages with dynamic segments.
- **Debug**: Fixing build failures — missing `generateStaticParams`, incompatible features, async params.
- **Verify**: Validating that `pnpm build` produces correct static output in `out/`.

Related skills:
- i18n setup → `.agents/skills/nextjs-intl/SKILL.md`
- SEO/Tailwind/fonts → `.agents/skills/nextjs-tailwind-seo/SKILL.md`
- TypeScript 7 upgrade → `.agents/skills/typescript-7/SKILL.md`

Do NOT use for server-side rendering (SSR), incremental static regeneration (ISR), API route development, database integration, or non-Next.js frameworks.

## Inputs To Collect First

1. **Project path** — where the project lives or should be created
2. **Target features** — which capabilities are needed (i18n, SEO, specific pages)
3. **Existing project?** — new scaffold or modifying an existing Next.js project
4. **Current error** — if debugging, the exact build error message

## Procedure

### Step 1 — Scaffold a New Project

Use `pnpm create next-app@latest` with `--typescript --tailwind --eslint --app --src-dir --use-pnpm --import-alias "@/*"`. Verify with `pnpm dev`.

See [scaffold and config](./references/scaffold-and-config.md) for manual setup commands.

### Step 2 — Configure next.config.ts for Static Export

Set `output: 'export'`, `trailingSlash: true`, `images.unoptimized: true`. Wrap with `createNextIntlPlugin()` when using next-intl.

### Step 3 — App Router Directory Structure

Use `src/app/[locale]/` for localized sites. Every dynamic segment must export `generateStaticParams`. See directory layout in [scaffold and config](./references/scaffold-and-config.md).

### Step 4 — TypeScript 7 Configuration

Enable strict mode in `tsconfig.json`. Before upgrading projects with compiler-API tooling, follow `.agents/skills/typescript-7/SKILL.md`.

### Step 5 — generateStaticParams for Dynamic Routes

Export `generateStaticParams()` for every `[locale]`, `[slug]`, and catch-all segment. Use async `params: Promise<{...}>` in page components (Next.js 16).

See [dynamic routes](./references/dynamic-routes.md) for locale, nested, and catch-all patterns.

### Step 6 — Root Layout

`app/[locale]/layout.tsx` renders `<html>` and `<body>` when all routes are localized. Do not duplicate with `app/layout.tsx` in the same tree.

### Step 7 — Build and Verify

Run `pnpm build`. Confirm `out/` contains expected locale directories, HTML files, and `_next/static/`.

For incompatible features and common build errors, see [static export gotchas](./references/static-export-gotchas.md).

## Completion Checks

- [ ] `next.config.ts` has `output: 'export'`, `trailingSlash: true`, `images.unoptimized: true`
- [ ] Every dynamic route segment exports `generateStaticParams()`
- [ ] All page components use async `params` (Next.js 16 convention)
- [ ] No server-only APIs used (`cookies()`, `headers()`, `draftMode()`)
- [ ] Any Route Handler is a request-independent `GET` handler that emits a static file
- [ ] No `revalidate` exports (ISR is incompatible with static export)
- [ ] `pnpm build` completes without errors
- [ ] `out/` directory contains expected HTML files for all routes and locales
- [ ] TypeScript strict mode enabled in `tsconfig.json`
- [ ] No `searchParams` usage in page components (use client-side `useSearchParams` with Suspense if needed)

## References

- [Scaffold and configuration](./references/scaffold-and-config.md)
- [Dynamic routes and layouts](./references/dynamic-routes.md)
- [Static export gotchas](./references/static-export-gotchas.md)
- [External documentation](./references/external-links.md)
