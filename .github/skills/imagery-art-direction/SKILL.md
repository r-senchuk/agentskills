---
name: imagery-art-direction
description: "Use when selecting, sourcing, optimizing, placing, or writing alt text for photography and visual assets on a renovation website with static Next.js export. Use when user asks to 'add hero image', 'optimize photos', 'write alt text', 'choose renovation photos', or 'set up next/image'. Covers Unsplash sourcing, next/image sizing, WebP conversion, focal-point cropping, and WCAG alt text patterns. Do NOT use for SVG icons, CSS background patterns, logo design, video embeds, or non-photography illustration work."
argument-hint: "image use case, source type, target page section"
user-invocable: true
---

# Imagery Strategy and Art Direction

Guide selection, art direction, optimisation, and placement of photography and visual assets across the Garnebo website. Imagery must reinforce brand trust and drive conversions. Static export on S3/CloudFront: `images.unoptimized: true`, all images pre-built into `/public/`, primary format `.webp`.

**Brand personality:** Clean, precise, tech-enabled, premium-organised. Think architect's presentation folder — not a TV home improvement show.

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

1. **Real Garnebo project photos** — request from client (highest trust value)
2. **Commissioned photography** — hire a local architectural photographer for a half-day shoot
3. **Licensed stock** — Unsplash/Pexels (free), Getty/Shutterstock (paid). Search: "renovated apartment Bologna", "Italian interior renovation", "parquet flooring install"
4. **AI-generated** — only as placeholder, never in production without disclosure

### Step 2 — Image Specifications

| Use case | Min dimensions | Aspect ratio | Format | Max file size |
|---|---|---|---|---|
| Hero background | 2400x1600 px | 3:2 / 16:9 | `.webp` | 400 KB |
| Before/After pair | 1200x900 px | 4:3 | `.webp` | 200 KB each |
| Service card thumbnail | 800x600 px | 4:3 | `.webp` | 100 KB |
| Team portrait | 400x400 px | 1:1 | `.webp` | 60 KB |
| Project gallery | 1200x900 px | 4:3 or 3:2 | `.webp` | 150 KB each |

### Step 3 — Image Optimisation Workflow

Since `images.unoptimized: true` disables Next.js optimization, images must be manually pre-optimised:

```bash
# Convert JPEG/PNG to WebP
cwebp -q 82 input.jpg -o output.webp

# Resize first:
convert input.jpg -resize 1200x900^ -gravity center -extent 1200x900 resized.jpg

# Batch convert /public/projects/
for f in public/projects/raw/*.jpg; do
  filename=$(basename "$f" .jpg)
  cwebp -q 82 "$f" -o "public/projects/${filename}.webp"
done
```

### Step 4 — Implementing Images in Components

**Hero background (static export compatible):**
```tsx
import Image from 'next/image';

<Image
  src="/hero-finished-apartment.webp"
  alt="Renovated apartment with new parquet flooring in Bologna"
  fill
  priority
  sizes="100vw"
  className="object-cover object-center z-0"
  unoptimized
/>
```

**Service card image:**
```tsx
<div className="aspect-[4/3] overflow-hidden rounded-t-lg">
  <img
    src="/services/cosmetic-painting.webp"
    alt="Interior painting — smooth plaster finish on living room walls"
    className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
    loading="lazy"
    width={800}
    height={600}
  />
</div>
```

### Step 5 — Alt Text Standards

```
Bad:   alt="photo1.jpg"
Bad:   alt="renovation"
Bad:   alt="before"

Good:  alt="Living room before renovation — worn parquet flooring and dated wallpaper"
Good:  alt="Same living room after Garnebo renovation — new engineered oak flooring and fresh white plaster"
Good:  alt="Tiler applying precision grout to 60x60cm porcelain tiles in a Bologna bathroom"
Good:  alt="Marco Bianchi, Garnebo Project Manager, on-site at a completed renovation in Bolognina"
```

**Formula:**
- Before photo: `[Room type] before renovation — [key before-state details]`
- After photo: `[Room type] after Garnebo renovation — [key improvements]`
- Action shot: `[Who] doing [what] [where]`
- Team: `[Full name], [role at Garnebo]`

### Step 6 — File Naming Convention

Use `kebab-case`. No Italian accents (breaks some S3 configs). No spaces.

```
/public/
  projects/
    via-indipendenza-before.webp
    via-indipendenza-after.webp
  services/
    cosmetic-painting.webp
  team/
    marco-bianchi.webp
  testimonials/
    marco-b-avatar.webp
```

### Step 7 — On-Brand vs Off-Brand Reference

**Use:** Finished interiors with natural light. Empty/minimally furnished spaces. Precision action shots (hands on tile, trowel, level). Before/After pairs from same angle. Approachable team portraits.

**Never use:** Generic hardhat/safety vest photos. Blueprint close-ups. Thumbs up/handshake poses. Dark or cluttered job sites. Images with watermarks. Very dark photos.

### Step 8 — Responsive Image Hints

```tsx
<Image sizes="100vw" ... />                              // full-width
<Image sizes="(min-width: 768px) 50vw, 100vw" ... />    // 2-col grid
<Image sizes="(min-width: 1024px) 33vw, (min-width: 768px) 50vw, 100vw" ... />  // 3-col
```

> **Constraints:** Do NOT add uncompressed JPEG/PNG to `/public/`. Do NOT use `next/image` without `unoptimized` prop on static export. Do NOT use generic contractor stock (hi-vis, hardhats). Do NOT forget `width` and `height` on `<img>` tags. Always use `priority` on hero/LCP image. Always provide meaningful alt text.

## Completion Checks

- [ ] All images in `/public/` are in `.webp` format
- [ ] File dimensions meet the minimum spec for the use case
- [ ] File size is within the limit for the use case
- [ ] `priority` on all hero/LCP images; `loading="lazy"` on all below-fold images
- [ ] `unoptimized` prop on every `next/image` component
- [ ] Alt text is descriptive and follows the prescribed formula (not a filename or "renovation")
- [ ] No generic contractor stock photography (hardhats, blueprints, handshakes)
- [ ] File names use kebab-case with no accented characters, spaces, or uppercase
- [ ] Before/after pairs shot from identical angle, focal length, and time-of-day lighting

## References

- [Next.js — next/image component](https://nextjs.org/docs/app/api-reference/components/image)
- [Unsplash — Free high-resolution photos](https://unsplash.com/)
- [MDN — Responsive images](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content/HTML_images#responsive_images)
- [WebAIM — Alt text guide](https://webaim.org/techniques/alttext/)
