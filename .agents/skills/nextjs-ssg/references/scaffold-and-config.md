# Scaffold and Configuration

## Step 1 — Scaffold a new project

```bash
pnpm create next-app@latest my-app \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --use-pnpm \
  --import-alias "@/*"
```

Manual setup:

```bash
mkdir my-app && cd my-app
pnpm init
pnpm add next@latest react@latest react-dom@latest
pnpm add -D typescript@^7 @types/react @types/react-dom @types/node
```

Verify: `pnpm dev`

## Step 2 — next.config.ts for static export

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
- `output: 'export'` — static HTML in `out/`
- `trailingSlash: true` — `/about/index.html` (better for static hosting)
- `images.unoptimized: true` — required without a server

With next-intl:

```typescript
import createNextIntlPlugin from 'next-intl/plugin';

const withNextIntl = createNextIntlPlugin();

const nextConfig: NextConfig = {
  output: 'export',
  trailingSlash: true,
  images: { unoptimized: true },
};

export default withNextIntl(nextConfig);
```

## Step 3 — Directory structure

```
src/
├── app/
│   ├── not-found.tsx
│   └── [locale]/
│       ├── layout.tsx
│       ├── page.tsx
│       └── blog/[slug]/page.tsx
├── components/
└── lib/
```

Every `page.tsx` under a dynamic segment MUST export `generateStaticParams`.

## Step 4 — TypeScript 7 configuration

Use TypeScript 7 for direct `tsc` checking. Projects with tooling that imports the compiler API must retain `@typescript/typescript6` — follow `.agents/skills/typescript-7/SKILL.md` before upgrading.

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["dom", "esnext"],
    "strict": true,
    "noEmit": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "jsx": "preserve",
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

## Step 7 — Build and verify

```bash
pnpm build
ls -la out/
find out -name "*.html" | head -20
```

Expected: locale directories, `_next/static/`, `index.html` per route.
