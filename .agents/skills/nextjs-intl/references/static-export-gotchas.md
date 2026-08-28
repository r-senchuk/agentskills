# Static Export Gotchas

## "Unable to find next-intl locale" build error

The component is missing `setRequestLocale(locale)` before calling `useTranslations`. Add it to every page and layout under `[locale]`.

## Proxy not working in production static export

`src/proxy.ts` is unsupported with `output: 'export'`. Handle `/` at the static host/CDN (Netlify `_redirects`, CloudFront redirect rule), or expose only locale-prefixed entry URLs. Do not use Next.js `redirect()` for this fallback.

## Message file not found

Ensure the import path in `request.ts` resolves from `src/i18n/` to project-root `messages/`:

```typescript
messages: (await import(`../../messages/${locale}.json`)).default
```

## Translations not updating in development

Restart the dev server after changing JSON files — the next-intl plugin caches message imports.

## Type safety for translation keys

```typescript
// src/types/next-intl.d.ts
import en from '../../messages/en.json';

type Messages = typeof en;

declare global {
  interface IntlMessages extends Messages {}
}
```

## Localized routes out of sync

When adding or changing routes, update both `src/i18n/routing.ts` pathnames and any `scripts/localized-routes.cjs` (or equivalent) used by the project. Run `pnpm build` to verify all locales generate.
