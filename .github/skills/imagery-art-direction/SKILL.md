---
name: imagery-art-direction
description: "Use when selecting, sourcing, optimising, placing, or writing alt text for photography and visual assets across a renovation website with static Next.js export. Covers webp conversion, image specifications, and next/image usage. Do NOT use for SVG icon creation, CSS background patterns, or brand logo design."
argument-hint: "image use case (hero/before-after/service-card/team/gallery), source type, target page section"
user-invocable: true
---

# Skill: Imagery Strategy & Art Direction

## Purpose

Guide selection, art direction, optimisation, and placement of photography and visual assets across the Garnebo website — ensuring imagery reinforces brand trust, drives conversions, and never undermines credibility with generic stock photos.

## Context

**Business:** Home renovation project management in Bologna, Italy.
**Brand personality:** Clean, precise, tech-enabled, premium-organised. Think: architect's presentation folder, not a TV home improvement show.
**Image budget constraint:** Static export on S3/CloudFront. All images are pre-built into `/public/`. No dynamic image optimization (CDN image transforms) — `images.unoptimized: true` in `next.config.ts`.
**Primary image format:** `.webp` (best compression + quality ratio for static deployment)

## What Makes an Image On-Brand vs Off-Brand

### ✅ Use These

**Finished interior photography:**
- Completed rooms with natural light
- Empty or minimally furnished spaces (show the work, not furniture)
- Clean lines, fresh plaster, new flooring, bright kitchens
- Bologna-specific character where possible (period ceilings, terrazzo floors)

**Precision action shots:**
- A craftsman's hands applying detail work (tiling grout, sanding, brushwork)
- Measurement tools, spirit levels, clean trowels — precision tools
- Tight crop, shallow depth of field — feels editorial, not stock

**Before/After pairs:**
- Same angle, same framing, same time-of-day lighting
- Must show dramatic transformation (if improvement is subtle, don't use it)
- Minimum 1200×900px, ideally 2400×1800px for retina

**Team portraits:**
- Approachable, confident, natural lighting
- Clean background or on-site (finished space)
- Not posed with tools for the camera — candid-ish
- Consistent cropping for all team photos (headshot or 3/4 portrait)

**Project documentation:**
- Progress photos showing organisation: clean site, material staging, professional setup
- Finished product shots from multiple angles

### ❌ Never Use These

- **Generic hardhat/safety vest photos** — contractor cliché, signals low-end
- **Blueprint/plan close-up photos** — overused, meaningless for residential clients
- **Thumbs up / handshake / high-five** — feels fake and cheap
- **Overly diverse stock people** — not authentic for a local Bologna business
- **Cluttered or messy job sites** — even if "real", it creates anxiety
- **Computer-generated renders without disclosure** — misleading
- **Images with visible watermarks** from stock sites
- **Very dark photos** — creates distrust and unease; all imagery should feel light/clean
- **Before photos that are too dramatic** (flood damage, black mold) — creates fear, not inspiration

## When To Use

- Choosing or briefing photography for the hero, project portfolio, team portrait, or service card sections
- Converting source images to `.webp` format and resizing them for static export
- Writing descriptive alt text for renovation before/after, action shot, or team photography
- Implementing images in components with correct `next/image` props for static export (`unoptimized`, `priority`, `sizes`)
- Determining whether a proposed image is on-brand or off-brand for the renovation business

**Do NOT use for:** SVG icon design, CSS gradient backgrounds, brand logo work, or component layout decisions.

## Inputs To Collect First

1. Image use case (hero background, before/after pair, service card thumbnail, team portrait, project gallery)
2. Whether real project photos are available or stock/AI placeholders will be used
3. Target page and section placement
4. Whether the image is above the fold (determines `priority` attribute and `loading` strategy)

## Procedure

### Step 1 — Image Sourcing Hierarchy

1. **Real Garnebo project photos** (highest trust value) — request from client
2. **Commissioned photography** — hire a local architectural photographer for a half-day shoot
3. **Licensed stock photography** — Unsplash (free), Pexels (free), Getty/Shutterstock (paid)
   - Search terms: "renovated apartment Bologna", "Italian interior renovation", "modern renovation kitchen", "parquet flooring install"
   - Filter: license allows commercial use
4. **AI-generated imagery** — only as placeholder, never in production without disclosure

### Step 2 — Image Specifications

| Use case               | Min dimensions  | Aspect ratio | Format | Max file size |
|------------------------|----------------|--------------|--------|---------------|
| Hero background        | 2400×1600 px   | 3:2 / 16:9   | `.webp` | 400 KB       |
| Before/After pair      | 1200×900 px    | 4:3          | `.webp` | 200 KB each  |
| Service card thumbnail | 800×600 px     | 4:3          | `.webp` | 100 KB       |
| Team portrait          | 400×400 px     | 1:1          | `.webp` | 60 KB        |
| Project gallery        | 1200×900 px    | 4:3 or 3:2   | `.webp` | 150 KB each  |
| Logo / wordmark        | Vector          | N/A          | `.svg`  | <10 KB       |
| Favicon                | 32×32, 180×180 | 1:1          | `.ico`/`.png` | <5 KB |

### Step 3 — Image Optimisation Workflow

Since `images.unoptimized: true` disables Next.js optimization, images must be manually pre-optimised:

```bash
# Convert JPEG/PNG to WebP (requires cwebp or imagemagick)
cwebp -q 82 input.jpg -o output.webp

# With imagemagick:
convert input.jpg -quality 82 -define webp:method=6 output.webp

# Resize to target dimensions first:
convert input.jpg -resize 1200x900^ -gravity center -extent 1200x900 resized.jpg
```

**Batch script for `/public/projects/` folder:**
```bash
for f in public/projects/raw/*.jpg; do
  filename=$(basename "$f" .jpg)
  cwebp -q 82 "$f" -o "public/projects/${filename}.webp"
done
```

### Step 4 — Implementing Images in Components

**Hero background (static export compatible):**
```tsx
import Image from 'next/image';

// Always use unoptimized for static export
<Image
  src="/hero-finished-apartment.webp"
  alt="Renovated apartment with new parquet flooring in Bologna"
  fill
  priority        // LCP image — always priority
  sizes="100vw"
  className="object-cover object-center z-0"
  unoptimized     // Required for static export
/>
```

**Service card image:**
```tsx
<div className="aspect-[4/3] overflow-hidden rounded-t-lg">
  <img
    src="/services/cosmetic-painting.webp"
    alt="Interior painting and wall finishing — smooth plaster finish on living room walls"
    className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
    loading="lazy"
    width={800}
    height={600}
  />
</div>
```

**Team portrait:**
```tsx
<img
  src="/team/project-manager-marco.webp"
  alt="Marco Bianchi — Garnebo Project Manager"
  className="h-24 w-24 rounded-full object-cover object-top shadow-sm"
  width={96}
  height={96}
  loading="lazy"
/>
```

### Step 5 — Alt Text Standards

Alt text for renovation photography must be descriptive and conversion-aware:

```
❌ Bad:  alt="photo1.jpg"
❌ Bad:  alt="renovation"
❌ Bad:  alt="before"

✅ Good: alt="Living room before renovation — worn parquet flooring and dated wallpaper"
✅ Good: alt="Same living room after Garnebo renovation — new engineered oak flooring and fresh white plaster"
✅ Good: alt="Tiler applying precision grout to 60×60cm porcelain tiles in a Bologna bathroom"
✅ Good: alt="Marco Bianchi, Garnebo Project Manager, on-site at a completed renovation in Bolognina"
```

**Formula:**
- Decorative only (no content value): `alt=""`
- Before photo: `[Room type] before renovation — [key before-state details]`
- After photo: `[Room type] after Garnebo renovation — [key improvements]`
- Action shot: `[Who] doing [what] [where]`
- Team: `[Full name], [role at Garnebo]`

### Step 6 — File Naming Convention

```
/public/
  hero_bacgnrtndyhctn.webp          ← existing (hash suffix to bust cache)
  projects/
    via-indipendenza-before.webp
    via-indipendenza-after.webp
    mazzini-bathroom-before.webp
    mazzini-bathroom-after.webp
  services/
    cosmetic-painting.webp
    flooring-installation.webp
    interior-design.webp
  team/
    marco-bianchi.webp
    lucia-ferrari.webp
  testimonials/
    marco-b-avatar.webp
```

Use `kebab-case`. Include a descriptor. Avoid spaces. No Italian accents in filenames (breaks some S3 configs).

### Step 7 — Responsive Image Hints

Even with `unoptimized: true`, provide `sizes` for `next/image` to set correct `srcset` hints:

```tsx
{/* Full-width image */}
<Image sizes="100vw" ... />

{/* 2-column grid on desktop */}
<Image sizes="(min-width: 768px) 50vw, 100vw" ... />

{/* 3-column grid on desktop */}
<Image sizes="(min-width: 1024px) 33vw, (min-width: 768px) 50vw, 100vw" ... />
```

### Step 8 — Aspect Ratio Enforcement

Prevent layout shift by always declaring aspect ratios on image containers:

```tsx
{/* CSS aspect-ratio (preferred) */}
<div className="aspect-[4/3] overflow-hidden rounded-lg">
  <img className="h-full w-full object-cover" ... />
</div>

{/* Or explicit padding trick (legacy) */}
<div className="relative w-full pb-[75%]">  {/* 75% = 3/4 = 4:3 ratio */}
  <img className="absolute inset-0 h-full w-full object-cover" ... />
</div>
```

## Art Direction Notes for Photography Briefs

When briefing a photographer:

**Hero shoot:**
> Shoot the completed apartment with morning natural light from the east-facing windows. No furniture in frame. Focus on the floor-to-ceiling continuity. Shoot from the doorway at standing eye height. Aim for a slightly left-of-centre composition to leave breathing room for text overlay on the left.

**Before/After pairs:**
> Lock the tripod position for both shots. Same focal length (35mm or 50mm equivalent). Wait for the same time of day. Frame to show the full room — do not crop the ceiling.

**Action shots:**
> Capture the craftsman in focused work — not looking at the camera. Tight crop on the hands and the material (tile, brush, floor). Available light only. Clean background — no visible brand names or logos on packaging.

## Constraints & Anti-Patterns

- **DO NOT** add uncompressed JPEG/PNG to `/public/` — always convert to `.webp` first
- **DO NOT** use `next/image` without the `unoptimized` prop — it will fail on static export
- **DO NOT** use stock photos of workers in hi-vis vests or hardhats — brand mismatch
- **DO NOT** use images wider than 2400px — unnecessary file size for this use case
- **DO NOT** forget `width` and `height` attributes on `<img>` tags — prevents Cumulative Layout Shift
- **DO NOT** use `loading="eager"` on below-the-fold images — hurts LCP and performance
- **ALWAYS** use `priority` on the hero/LCP image
- **ALWAYS** provide meaningful alt text — never empty or filename-based

## Invocation Examples

- "What kind of photos should we use on the home page hero?"
- "Write alt text for the before/after photos of the Mazzini bathroom project"
- "What's the correct file size limit for service card thumbnails?"
- "How should I implement the hero image to work with static export?"
- "We have 15 project photos — which are best for the before/after slider?"
- "Write a photography brief for the Garnebo hero shoot"

## Completion Checks

- [ ] All images placed in `/public/` are in `.webp` format — no uncompressed JPEG or PNG
- [ ] File dimensions meet the minimum spec for the use case (hero ≥2400×1600, before/after ≥1200×900, service card ≥800×600, team portrait ≥400×400)
- [ ] File size is within the limit for the use case (hero ≤400 KB, before/after ≤200 KB each, service card ≤100 KB, team portrait ≤60 KB)
- [ ] `priority` prop present on all hero/LCP images; `loading="lazy"` on all below-fold images
- [ ] `unoptimized` prop included on every `next/image` component (required for static export)
- [ ] Alt text follows the prescribed formula and is descriptive (not a filename or "renovation")
- [ ] No generic contractor stock photography (hardhats, blueprints, handshakes) used
- [ ] File names use kebab-case with no accented characters, spaces, or uppercase letters
- [ ] Before/after pairs shot from identical angle, focal length, and time-of-day lighting

## References

No external references required.
