# Troubleshooting

## Tailwind classes not applying

1. Ensure `postcss.config.mjs` uses `@tailwindcss/postcss` (not `tailwindcss`)
2. Ensure `globals.css` starts with `@import "tailwindcss"`
3. Ensure `globals.css` is imported in your root or locale layout
4. With Turbopack, restart the dev server after PostCSS config changes

## Custom colors not available as classes

In Tailwind v4, custom colors must use the `--color-*` naming convention in `@theme`:

```css
@theme {
  --color-brand: #1B3A5C;  /* Available as bg-brand, text-brand */
}
```

## next/font variable not applied

The font's CSS variable must be applied to a parent element (usually `<html>`):

```tsx
<html className={inter.variable}>
```

And referenced in `@theme`:

```css
@theme {
  --font-sans: var(--font-inter);
}
```

## OG images not showing on social platforms

- OG images must be absolute URLs (include full `https://...` domain)
- Recommended size: 1200×630px
- Test with Facebook Sharing Debugger and Twitter Card Validator (see external-links.md)

## next-sitemap not finding pages

For static export, `next-sitemap` should run after `next build`. Set `outDir: './out'` in the config and use the `postbuild` script. Prefer built-in `app/sitemap.ts` for new projects instead.
