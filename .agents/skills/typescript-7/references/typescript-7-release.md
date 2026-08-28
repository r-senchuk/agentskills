# TypeScript 7.0 Reference — July 2026

Use this reference to validate time-sensitive TypeScript 7 adoption decisions.

- [Announcing TypeScript 7.0](https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/) — released July 8, 2026; native Go port; generally 8–12× faster full builds; documents the compatibility package and current API/editor limits.
- [Announcing TypeScript 6.0](https://devblogs.microsoft.com/typescript/announcing-typescript-6-0/) — explains the TypeScript 6 transition release and deprecations that become errors in TypeScript 7.
- [TypeScript 7 changes](https://github.com/microsoft/typescript-go/blob/main/CHANGES.md) — detailed behavioral differences between TypeScript 6 and 7.

## Adoption Facts

- Stable TypeScript 7 installs from the `typescript` package and supplies `tsc`.
- TypeScript 7.0 has no stable programmatic compiler API. The planned API target is TypeScript 7.1.
- `@typescript/typescript6` supplies the TypeScript 6 API and a `tsc6` binary for side-by-side operation.
- TypeScript 7 is intended to be command-line and language-server compatible with TypeScript 6 after TypeScript 6 deprecations are resolved. Its compatibility promise assumes `stableTypeOrdering` and no `ignoreDeprecations` setting.
- Vue, MDX, Astro, Svelte, and Angular template tooling may need TypeScript 6 until their embedding/plugin integrations support TypeScript 7.
