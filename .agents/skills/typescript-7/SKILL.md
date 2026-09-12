---
name: typescript-7
description: "Use when adopting, configuring, or troubleshooting TypeScript 7.0 in a Node.js, React, or Next.js project. Covers the native compiler, TypeScript 6 migration, compiler-API compatibility, side-by-side installation, tsconfig cleanup, and validation. Do not use for general TypeScript language design or projects that must remain on TypeScript 5 or earlier."
argument-hint: "Project path, package manager, current TypeScript version, affected tooling, upgrade goal or error."
user-invocable: false
license: MIT
compatibility: "Requires Node.js 20.9+, TypeScript 7.0+, optional @typescript/typescript6 for API consumers."
paths:
  - "tsconfig.json"
  - "package.json"
  - "**/*.ts"
  - "**/*.tsx"
metadata:
  author: "Roman Senchuk"
  version: "1.1.0"
  last-updated: "2026-08-28"
---

# TypeScript 7 Adoption

## When To Use

- Upgrade a project from TypeScript 6 to the native TypeScript 7 compiler.
- Diagnose TypeScript 7 errors after a dependency, editor, or CI upgrade.
- Configure TypeScript 7 alongside TypeScript 6 when a tool imports the compiler API.
- Prepare a Next.js 16 project to use TypeScript 7 for direct type-checking.
- Fix Next.js 16 `pnpm build` or `tsc --noEmit` failures after a TypeScript major upgrade.
- Validate a static-export Next.js project (`.agents/skills/nextjs-ssg/SKILL.md`) after bumping `typescript` to 7.x.

Do NOT use for a feature-design discussion about TypeScript syntax, a project that
must retain TypeScript 5 or earlier, or a tooling integration that requires a
stable TypeScript compiler API today.

## Inputs To Collect First

1. **Project and package manager** — repository path and whether it uses pnpm,
   npm, or yarn; use its existing package manager.
2. **Current state** — `typescript` version, `tsconfig.json`, package scripts,
   and the exact compiler or build error.
3. **Toolchain** — editor extensions and tools that may import `typescript`
   (for example, linters, framework plugins, template-language tooling, or custom
   compiler scripts).
4. **Acceptance criteria** — direct `tsc` only, editor support, CI, or all of
   these; record a baseline build/type-check time when performance matters.

## Procedure

### Step 1 — Assess Compatibility Before Changing Dependencies

Inspect the installed graph and configuration before editing files:

```bash
pnpm why typescript
pnpm exec tsc --version
pnpm exec tsc --noEmit
```

Run the project's existing type-check, lint, and build commands. Search its
dependencies and scripts for compiler-API users:

```bash
rg -n 'typescript|tsserver|typescript-eslint|ts-morph|ts\.createProgram' \
  package.json pnpm-lock.yaml yarn.lock package-lock.json . 2>/dev/null
```

TypeScript 7.0 does not expose a stable programmatic compiler API. Treat a
dependency that imports `typescript`, embedded-language tooling (Vue, MDX, Astro,
Svelte), and Angular template checking as a compatibility boundary until that tool
explicitly supports TypeScript 7. Keep TypeScript 6 for that consumer rather than
forcing an upgrade.

### Step 2 — Clear the TypeScript 6 Transition Debt

First run the project on the latest TypeScript 6 release without
`"ignoreDeprecations": "6.0"`. Resolve every resulting deprecation and then
confirm the project type-checks cleanly. TypeScript 7 makes those former
deprecations hard errors.

Inspect for obsolete module resolution and module formats, import assertions
(`asserts { ... }`, now `with { ... }`), and scripts that invoke `tsc file.ts` in
a directory containing `tsconfig.json`. Use `tsc --ignoreConfig file.ts` only when
bypassing the project configuration is intentional.

Do not change compiler options merely to silence an error. Preserve the project's
module/runtime contract and make the smallest compatible configuration change.

### Step 3 — Select a Deployment Shape

For a project without compiler-API consumers, install TypeScript 7 normally:

```bash
pnpm add -D typescript@^7.0.2
pnpm exec tsc --version
pnpm exec tsc --noEmit
```

For a project that needs TypeScript 6's API while using TypeScript 7 for direct
type-checking, use the official compatibility package and an npm alias:

```json
{
  "devDependencies": {
    "@typescript/native": "npm:typescript@^7.0.2",
    "typescript": "npm:@typescript/typescript6@^6.0.2"
  }
}
```

This arrangement exposes TypeScript 7 as `tsc` and TypeScript 6 as `tsc6`; run
both deliberately. Keep the alias until every API-dependent tool has a released,
tested TypeScript 7 integration. Do not substitute the old native-preview package
for a stable 7.0 install.

### Step 4 — Validate the Compiler, Tooling, and Framework

Use the repository's package manager and scripts. A typical Next.js flow is:

```bash
pnpm exec tsc --noEmit
pnpm build
pnpm lint
```

If the compatibility installation is in use, also validate the API-dependent
tooling through its normal script and, when useful, run:

```bash
pnpm exec tsc6 --noEmit
```

For editor verification, use a TypeScript 7-capable language server. If a project
uses an unsupported language-service plugin, disable TypeScript 7 in the editor
and retain TypeScript 6 there while using TypeScript 7 for the CLI. Never report a
TypeScript 7 migration as complete based only on a faster `tsc` run.

### Step 5 — Record the Result and Roll Back Safely

Record the TypeScript version, package-file changes, commands run, compatibility
exceptions, and before/after timings where captured. If a blocking incompatibility
is found, restore the prior lockfile-compatible dependency state using the
repository's normal package-manager workflow; keep the deprecation fixes that are
safe independently. Do not remove TypeScript 6 compatibility just because the
main `tsc` command succeeds.

## Completion Checks

- [ ] The installed TypeScript 7 version and direct `tsc --version` output are recorded.
- [ ] TypeScript 6 deprecations are resolved without `ignoreDeprecations`.
- [ ] `pnpm exec tsc --noEmit` succeeds with TypeScript 7.
- [ ] The normal build, lint, and CI-relevant checks succeed.
- [ ] Every compiler-API consumer is either verified on TypeScript 7 or deliberately retained on TypeScript 6.
- [ ] Embedded-language and Angular template tooling remain on TypeScript 6 unless their TypeScript 7 support is verified.
- [ ] The chosen editor language server is verified or a TypeScript 6 fallback is documented.

## References

- [TypeScript 7 release and migration reference](./references/typescript-7-release.md)
