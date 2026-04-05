---
name: before-after-slider
description: "Use when implementing an accessible touch-friendly before/after image comparison slider for renovation portfolio pages. Covers drag handle, keyboard, and touch events for static Next.js export. Do NOT use for general image carousels, lightboxes, or static side-by-side comparisons."
argument-hint: "before image path, after image path, aspect ratio, page section placement"
user-invocable: true
---

# Skill: Before/After Image Slider Component

## Purpose

Implement an accessible, touch-friendly, static-export-compatible Before/After image comparison slider — the highest-converting visual asset for home renovation businesses.

## Context

**Static export constraint:** No server-side code, no API routes. The slider must be a pure client-side React component using `'use client'`.
**Images:** `images.unoptimized: true` — use `<img>` tags with explicit dimensions or `next/image` with `unoptimized` prop.
**No external libraries allowed** without explicit approval — implement with native pointer/touch events and CSS.
**Where to use:** Home page (hero section replacement or below hero), portfolio/project pages.

## How It Works

The slider reveals a "before" image on the left and an "after" image on the right, split by a draggable divider line. The split position is controlled by:
- Mouse drag (desktop)
- Touch drag (mobile)
- Keyboard arrow keys (accessibility)

Implementation uses a single `<div>` overlay technique: the "after" image is full-width underneath, and the "before" image is clipped via `clip-path` or `width` CSS on an overlay container.

## When To Use

- A portfolio or home page section needs an interactive drag-to-reveal comparison between a before and after renovation photo
- User asks to "add a before/after slider", "build an image comparison widget", or "show before and after photos with a draggable divider"
- A `BeforeAfterSlider` component needs to be created, debugged, or extended with accessibility or i18n features
- Touch scroll interference is causing problems on mobile for an existing slider

**Do NOT use for:** static side-by-side image layouts, image carousels/slideshows, lightbox galleries, or any slider that doesn't require a draggable divider between two images.

## Inputs To Collect First

1. Paths to the before and after image files (under `/public/`, `.webp` format preferred)
2. Descriptive alt text for both the before and after images
3. Target page and section (hero replacement, portfolio grid, project detail page, etc.)
4. Desired aspect ratio (default: `4/3`)
5. Whether the slider appears above the fold (determines `loading="eager"` vs `loading="lazy"`)

## Procedure

### Step 1 — Create the Component File

Create `src/components/BeforeAfterSlider.tsx`:

```tsx
'use client';

import { useCallback, useEffect, useRef, useState } from 'react';

interface BeforeAfterSliderProps {
  beforeSrc: string;
  afterSrc: string;
  beforeAlt: string;
  afterAlt: string;
  /** Initial split position 0–100, default 50 */
  initialPosition?: number;
  /** Aspect ratio as CSS value, e.g. "4/3" or "16/9" */
  aspectRatio?: string;
  className?: string;
}

export function BeforeAfterSlider({
  beforeSrc,
  afterSrc,
  beforeAlt,
  afterAlt,
  initialPosition = 50,
  aspectRatio = '4/3',
  className = '',
}: BeforeAfterSliderProps) {
  const [position, setPosition] = useState(initialPosition);
  const [isDragging, setIsDragging] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  /** Convert a clientX coordinate to a 0–100 position value */
  const clientXToPosition = useCallback((clientX: number): number => {
    const container = containerRef.current;
    if (!container) return position;
    const rect = container.getBoundingClientRect();
    const relativeX = clientX - rect.left;
    return Math.min(100, Math.max(0, (relativeX / rect.width) * 100));
  }, [position]);

  // ── Mouse events ─────────────────────────────────────────────────────────

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsDragging(true);
    setPosition(clientXToPosition(e.clientX));
  };

  useEffect(() => {
    if (!isDragging) return;

    const handleMouseMove = (e: MouseEvent) => {
      setPosition(clientXToPosition(e.clientX));
    };
    const handleMouseUp = () => setIsDragging(false);

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDragging, clientXToPosition]);

  // ── Touch events ─────────────────────────────────────────────────────────

  const handleTouchStart = (e: React.TouchEvent) => {
    setIsDragging(true);
    setPosition(clientXToPosition(e.touches[0].clientX));
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    e.preventDefault(); // prevent scroll interference
    setPosition(clientXToPosition(e.touches[0].clientX));
  };

  const handleTouchEnd = () => setIsDragging(false);

  // ── Keyboard events ───────────────────────────────────────────────────────

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowLeft') setPosition((p) => Math.max(0, p - 2));
    if (e.key === 'ArrowRight') setPosition((p) => Math.min(100, p + 2));
    if (e.key === 'Home') setPosition(0);
    if (e.key === 'End') setPosition(100);
  };

  return (
    <div
      ref={containerRef}
      className={`relative select-none overflow-hidden rounded-lg ${className}`}
      style={{ aspectRatio }}
      aria-label="Before and after image comparison"
    >
      {/* AFTER image — full width, always visible underneath */}
      <img
        src={afterSrc}
        alt={afterAlt}
        className="absolute inset-0 h-full w-full object-cover"
        draggable={false}
      />

      {/* BEFORE image — clipped to the left of the slider position */}
      <div
        className="absolute inset-0 overflow-hidden"
        style={{ width: `${position}%` }}
        aria-hidden="true"
      >
        <img
          src={beforeSrc}
          alt={beforeAlt}
          className="absolute inset-0 h-full object-cover"
          style={{ width: containerRef.current?.offsetWidth ?? '100%' }}
          draggable={false}
        />
      </div>

      {/* Labels */}
      <div
        className="pointer-events-none absolute left-3 top-3 rounded-md bg-black/50 px-2.5 py-1"
        aria-hidden="true"
      >
        <span className="text-[13px] font-semibold uppercase tracking-wider text-white">
          Before
        </span>
      </div>
      <div
        className="pointer-events-none absolute right-3 top-3 rounded-md bg-black/50 px-2.5 py-1"
        aria-hidden="true"
      >
        <span className="text-[13px] font-semibold uppercase tracking-wider text-white">
          After
        </span>
      </div>

      {/* Divider line */}
      <div
        className="pointer-events-none absolute inset-y-0 w-0.5 bg-white shadow-[0_0_8px_rgba(0,0,0,0.4)]"
        style={{ left: `${position}%`, transform: 'translateX(-50%)' }}
        aria-hidden="true"
      />

      {/* Drag handle — the interactive element */}
      <div
        role="slider"
        aria-label="Image comparison slider"
        aria-valuenow={Math.round(position)}
        aria-valuemin={0}
        aria-valuemax={100}
        tabIndex={0}
        className={`absolute inset-y-0 flex cursor-col-resize items-center justify-center
          focus:outline-none focus-visible:ring-2 focus-visible:ring-white`}
        style={{ left: `${position}%`, transform: 'translateX(-50%)', width: '44px' }}
        onMouseDown={handleMouseDown}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        onKeyDown={handleKeyDown}
      >
        {/* Handle circle */}
        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white shadow-lg">
          {/* Left/right chevrons */}
          <svg
            viewBox="0 0 24 24"
            fill="none"
            className="h-5 w-5 text-brand-primary"
            aria-hidden="true"
          >
            <path
              d="M15 18l-6-6 6-6"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M9 6l6 6-6 6"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </div>
      </div>
    </div>
  );
}
```

### Step 2 — Fix Image Width Bug

The "before" image needs its natural width preserved inside the clipped container. Replace the inline `style` on the before `<img>` with a ref measurement:

```tsx
// More robust version — measures container width on mount and resize
const [containerWidth, setContainerWidth] = useState<number | undefined>(undefined);

useEffect(() => {
  const container = containerRef.current;
  if (!container) return;
  const ro = new ResizeObserver((entries) => {
    setContainerWidth(entries[0].contentRect.width);
  });
  ro.observe(container);
  return () => ro.disconnect();
}, []);

// Then use containerWidth in the before <img>:
<img
  src={beforeSrc}
  alt={beforeAlt}
  className="absolute inset-0 h-full object-cover"
  style={{ width: containerWidth ? `${containerWidth}px` : '100%' }}
  draggable={false}
/>
```

### Step 3 — Usage in a Page Section

```tsx
// src/app/[locale]/page.tsx
import { BeforeAfterSlider } from '@/components/BeforeAfterSlider';

// Inside HomePage:
<section className="px-4 py-16 sm:px-6 md:py-24 lg:px-8">
  <div className="mx-auto max-w-5xl">
    <p className="text-center text-[13px] font-semibold uppercase tracking-wider text-accent-sage">
      Our Work
    </p>
    <h2 className="mt-3 text-center text-[26px] font-semibold text-brand-primary md:text-[36px]">
      See the Garnebo Difference
    </h2>
    <div className="mt-10 grid gap-6 md:grid-cols-2">
      <BeforeAfterSlider
        beforeSrc="/projects/living-room-before.webp"
        afterSrc="/projects/living-room-after.webp"
        beforeAlt="Living room before renovation — worn flooring and dated walls"
        afterAlt="Living room after renovation — new parquet and fresh plaster"
        aspectRatio="4/3"
      />
      <BeforeAfterSlider
        beforeSrc="/projects/bathroom-before.webp"
        afterSrc="/projects/bathroom-after.webp"
        beforeAlt="Bathroom before renovation — old tiles and fixtures"
        afterAlt="Bathroom after renovation — modern tiling and fittings"
        aspectRatio="4/3"
      />
    </div>
    <p className="mt-6 text-center text-[13px] font-light text-accent-blue">
      Drag the slider to compare · All photos from real Garnebo projects in Bologna
    </p>
  </div>
</section>
```

### Step 4 — Localise Label Strings

The "Before" / "After" labels should be translated:

```tsx
// Accept labels as props instead of hardcoding:
interface BeforeAfterSliderProps {
  // ...existing props...
  beforeLabel?: string;  // defaults to "Before"
  afterLabel?: string;   // defaults to "After"
}

// In the component:
const { beforeLabel = 'Before', afterLabel = 'After' } = props;
```

Then pass from the page using `useTranslations`:
```tsx
const t = await getTranslations('portfolio');
<BeforeAfterSlider
  beforeLabel={t('before')}
  afterLabel={t('after')}
  // ...
/>
```

### Step 5 — Performance: Lazy Loading

Images in the slider should lazy-load unless in the viewport:

```tsx
<img
  src={afterSrc}
  alt={afterAlt}
  loading="lazy"  // Remove this only for above-the-fold sliders
  className="absolute inset-0 h-full w-full object-cover"
  draggable={false}
/>
```

For sliders above the fold (e.g. hero replacement), use `loading="eager"` or omit the attribute.

### Step 6 — Multiple Sliders on One Page

If using multiple sliders, each manages its own state independently — no global state needed. The component is fully self-contained.

## Prevent Scroll Interference on Mobile

The `e.preventDefault()` in `handleTouchMove` prevents the page from scrolling while the user is dragging the slider. However, this requires the event listener to be non-passive. React's synthetic `onTouchMove` is passive by default in some environments.

If scroll interference occurs, use a `useEffect` with a direct DOM listener:

```tsx
useEffect(() => {
  const container = containerRef.current;
  if (!container) return;

  const onTouchMove = (e: TouchEvent) => {
    if (isDragging) e.preventDefault();
  };

  container.addEventListener('touchmove', onTouchMove, { passive: false });
  return () => container.removeEventListener('touchmove', onTouchMove);
}, [isDragging]);
```

## Image File Requirements

| Property        | Requirement                                     |
|-----------------|-------------------------------------------------|
| Format          | `.webp` preferred (best compression + quality)  |
| Dimensions      | At least 1200×900 for 4:3 ratio (2× for retina)|
| Before/After pair | Must be same angle, same framing, same time of day lighting |
| File location   | `/public/projects/<project-name>-before.webp`  |
| Alt text        | Descriptive: room type + what changed           |

## Constraints & Anti-Patterns

- **DO NOT** use third-party slider libraries (react-before-after-slider, etc.) without checking bundle impact on static export
- **DO NOT** use `next/image` with `fill` prop inside the slider — the clipping technique requires `<img>` with explicit `style.width`
- **DO NOT** forget `draggable={false}` on images — without it, browsers start a native image drag instead of the slider drag
- **DO NOT** place the slider inside a container with `overflow: hidden` set at a level above — it will clip the drag handle
- **DO NOT** hardcode "Before" / "After" strings — use translation keys
- **ALWAYS** provide descriptive `alt` text on both images (screen readers announce both)
- **ALWAYS** implement keyboard support (`ArrowLeft`/`ArrowRight`) for accessibility
- **ALWAYS** add `role="slider"` with `aria-valuenow` to the drag handle

## Invocation Examples

- "Add a before/after slider to the home page"
- "Create a portfolio section with 2 before/after comparison sliders"
- "Build a BeforeAfterSlider component that works on mobile"
- "Why is my before/after slider causing scroll issues on iPhone?"
- "Make the slider labels show 'Prima' and 'Dopo' in Italian"

## Completion Checks

- [ ] `BeforeAfterSlider.tsx` exists in `src/components/` with `'use client'` directive
- [ ] Mouse drag, touch drag, and keyboard (`ArrowLeft`/`ArrowRight`/`Home`/`End`) all move the slider
- [ ] `role="slider"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax` present on the drag handle element
- [ ] `draggable={false}` on both `<img>` elements to prevent native browser image drag
- [ ] `ResizeObserver` used to track `containerWidth` — before-image width does not break on resize
- [ ] Before/After label strings accepted as props (`beforeLabel`, `afterLabel`) — not hardcoded English strings
- [ ] `loading="lazy"` on below-fold sliders; `loading="eager"` (or omitted) on above-fold sliders
- [ ] Non-passive `touchmove` listener used via `useEffect` if scroll interference occurs on mobile
- [ ] Component renders without horizontal scroll at 375 px viewport width
- [ ] Both `it` and `en` label strings display without layout overflow

## References

No external references required.
