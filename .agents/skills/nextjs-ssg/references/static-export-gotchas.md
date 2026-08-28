# Static Export Gotchas

## What does NOT work with `output: 'export'`

| Feature | Status | Workaround |
|---|---|---|
| `middleware.ts` / `proxy.ts` | Ignored in production | Use `[locale]` segment; CDN redirect for `/` |
| Route Handlers | Only static `GET` at build time | Emit JSON/TXT files; no request-time logic |
| ISR (`revalidate`) | Not supported | Full rebuild on content change |
| `cookies()`, `headers()` | Build error | Remove server-only APIs |
| `searchParams` in pages | Forces dynamic rendering | Client `useSearchParams()` with Suspense |
| Server Actions | Not available | Client-side form handling |
| `next/image` optimization | Needs `unoptimized: true` | Set in next.config.ts |
| `dynamicParams = true` | Not allowed | Return all params from `generateStaticParams` |
| Draft Mode | Requires server | Not available |

For i18n locale routing depth, load `.agents/skills/nextjs-intl/SKILL.md`.

## Async params in Next.js 16

```typescript
// Wrong — Next.js 14 style
export default function Page({ params }: { params: { locale: string } }) {
  const locale = params.locale;
}

// Correct — Next.js 16
export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
}
```

## Missing generateStaticParams

Error: `Page is missing exported function 'generateStaticParams'`

Every dynamic segment (`[locale]`, `[slug]`) MUST export `generateStaticParams` with `output: 'export'`.

## Image handling

Set `unoptimized: true` in `next.config.ts`. Without it, `next/image` fails because the server optimizer is unavailable.
