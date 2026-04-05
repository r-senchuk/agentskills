---
name: floating-sticky-ui
description: "Use when implementing or debugging sticky navigation, floating mobile CTA bars, WhatsApp widgets, scroll-triggered visibility, or z-index layering conflicts on the Garnebo site. Do NOT use for static page layout sections, grid design, or non-fixed component styling."
argument-hint: "component name (header/mobile-bar/whatsapp/sub-nav), issue type (z-index/positioning/scroll-trigger), target breakpoint"
user-invocable: true
---

# Skill: Floating & Sticky UI Elements

## Purpose

Implement and maintain the sticky navigation, floating mobile CTA bar, floating WhatsApp widget, and any other fixed/sticky UI elements on the Garnebo site — ensuring correct `z-index` layering, smooth transitions, scroll-triggered visibility, and no overlap conflicts.

## Context

**Existing floating elements:**
| Component          | File                           | Behaviour                                    | z-index |
|--------------------|--------------------------------|----------------------------------------------|---------|
| `Header`           | `src/components/Header.tsx`    | `sticky top-0` — always visible              | `z-50`  |
| `MobileStickyBar`  | `src/components/MobileStickyBar.tsx` | `fixed bottom-0` — appears after 300px scroll, mobile only | `z-40`  |
| `WhatsAppWidget`   | `src/components/WhatsAppWidget.tsx` | `fixed bottom-6 right-6` — always visible   | `z-50`  |

**Z-index stack (reserved values):**

| Layer          | z-index | Elements                               |
|----------------|---------|----------------------------------------|
| Page content   | auto    | All normal content                     |
| Floating bottom bar | `z-40` | `MobileStickyBar`                 |
| Fixed overlays | `z-50`  | `Header`, `WhatsAppWidget`, modals     |
| Dropdowns      | `z-50`  | Mobile nav slide-out (within Header)   |

**Constraint:** The mobile sticky bar (`z-40`) must not overlap the WhatsApp widget (`z-50`) on desktop. This is resolved by `MobileStickyBar` using `md:hidden`.

## When To Use

- Adding or modifying the sticky header, mobile sticky CTA bar (`MobileStickyBar`), or `WhatsAppWidget` floating button
- A z-index conflict causes elements to overlap incorrectly (e.g. dropdown behind page content, WhatsApp behind sticky bar)
- A scroll-triggered visibility hook needs to be added to any UI element
- A sticky sub-navigation is needed for a long-scroll page (e.g. Services page with section anchors)
- iOS safe-area insets need to be applied to bottom-fixed elements

**Do NOT use for:** static section layout, Tailwind grid patterns, typography changes, or components that are not fixed/sticky/floating.

## Inputs To Collect First

1. Which element is being added or fixed (header, mobile bar, WhatsApp widget, sub-nav, or other)
2. Current z-index value(s) involved if a layering conflict exists
3. Whether the issue is z-index conflict, positioning bug, scroll-trigger threshold, or iOS safe-area
4. Target breakpoints at which the element should be visible or hidden

## Procedure

### Step 1 — Sticky Header

The header uses `sticky top-0` (not `fixed`) so it scrolls with the page until reaching the top, then sticks. This avoids the need to add body padding-top.

```tsx
// Current implementation — DO NOT change the sticky pattern
<header className="sticky top-0 z-50 bg-bg-primary border-b border-accent-sage/30">
  <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
    {/* Logo | Nav links | CTA button | Locale toggle */}
  </div>
</header>
```

**Adding a scroll shadow to the sticky header:**
```tsx
'use client';
import { useEffect, useState } from 'react';

export function Header() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 4);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <header
      className={`sticky top-0 z-50 bg-bg-primary border-b border-accent-sage/30 transition-shadow duration-200
        ${scrolled ? 'shadow-md' : 'shadow-none'}`}
    >
      {/* ... */}
    </header>
  );
}
```

### Step 2 — Mobile Sticky CTA Bar

The existing `MobileStickyBar` component slides in from the bottom after 300px scroll and hides on `md:` breakpoint.

**Key patterns:**
```tsx
// Appear after scroll — translate in/out
className={`fixed bottom-0 left-0 right-0 z-40 ... transition-transform duration-300 md:hidden
  ${visible ? 'translate-y-0' : 'translate-y-full'}`}
```

**Improving: Add `pb-safe` for iOS home indicator:**
```tsx
// Add to globals.css:
@layer utilities {
  .pb-safe {
    padding-bottom: max(12px, env(safe-area-inset-bottom));
  }
}

// In MobileStickyBar, replace py-3 with:
className="... pb-safe pt-3 px-4"
```

**Improving: Show immediately on mobile without scroll requirement** (for high-bounce pages):
```tsx
// Change threshold from 300 to 0, or always show
const [visible, setVisible] = useState(true); // always visible
// Or show immediately on /quote page entry points:
const [visible, setVisible] = useState(window.scrollY > 0 || pathname === '/');
```

### Step 3 — WhatsApp Floating Widget

The existing `WhatsAppWidget` is positioned `bottom-6 right-6`. On mobile, the sticky bar occupies the bottom, so the WhatsApp icon must clear it.

**Fix desktop/mobile positioning conflict:**
```tsx
<a
  href={href}
  target="_blank"
  rel="noopener noreferrer"
  aria-label="WhatsApp"
  className="group fixed z-50 flex h-14 w-14 items-center justify-center rounded-full bg-[#25D366] shadow-lg transition-transform hover:scale-110
    bottom-6 right-6
    md:bottom-6 md:right-6"
    {/* On mobile, the sticky bar is ~60px tall. WhatsApp sits above it: */}
    {/* Add: bottom-[76px] on mobile (60px bar + 16px gap) */}
>
```

**Correct version with mobile clearance:**
```tsx
className="group fixed z-50 flex h-14 w-14 items-center justify-center rounded-full bg-[#25D366] shadow-lg transition-transform hover:scale-110
  bottom-[76px] right-4
  md:bottom-6 md:right-6"
```

Or use CSS custom property for dynamic clearance:
```css
/* In globals.css */
:root {
  --sticky-bar-height: 60px;
}

@layer utilities {
  .bottom-above-sticky {
    bottom: calc(var(--sticky-bar-height) + 1rem);
  }
}
```

### Step 4 — Sub-Navigation (Services Page)

Sticky secondary navigation for service categories (currently missing, recommended for Services page):

```tsx
// src/components/ServiceSubNav.tsx
'use client';

import { useEffect, useRef, useState } from 'react';

interface ServiceSubNavProps {
  items: { id: string; label: string }[];
}

export function ServiceSubNav({ items }: ServiceSubNavProps) {
  const [activeId, setActiveId] = useState(items[0]?.id ?? '');
  const [stuck, setStuck] = useState(false);
  const navRef = useRef<HTMLDivElement>(null);

  // Detect when sub-nav sticks
  useEffect(() => {
    const sentinel = navRef.current;
    if (!sentinel) return;
    const observer = new IntersectionObserver(
      ([entry]) => setStuck(!entry.isIntersecting),
      { threshold: 1, rootMargin: '-56px 0px 0px 0px' } // 56px = header height
    );
    observer.observe(sentinel);
    return () => observer.disconnect();
  }, []);

  // Scroll spy
  useEffect(() => {
    const onScroll = () => {
      for (const item of [...items].reverse()) {
        const el = document.getElementById(item.id);
        if (el && el.getBoundingClientRect().top <= 120) {
          setActiveId(item.id);
          break;
        }
      }
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, [items]);

  const scrollTo = (id: string) => {
    const el = document.getElementById(id);
    if (el) {
      const offset = 112; // header (56px) + sub-nav (56px)
      const top = el.getBoundingClientRect().top + window.scrollY - offset;
      window.scrollTo({ top, behavior: 'smooth' });
    }
  };

  return (
    <div
      ref={navRef}
      className={`sticky top-[56px] z-40 bg-bg-white border-b transition-shadow duration-200
        ${stuck ? 'shadow-sm border-accent-sage/30' : 'border-transparent'}`}
    >
      <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
        <nav className="flex gap-6 overflow-x-auto py-3 scrollbar-none" aria-label="Service categories">
          {items.map((item) => (
            <button
              key={item.id}
              onClick={() => scrollTo(item.id)}
              className={`flex-shrink-0 text-[13px] font-semibold uppercase tracking-wider transition-colors
                ${activeId === item.id
                  ? 'text-brand-primary border-b-2 border-brand-primary pb-1'
                  : 'text-brand-secondary hover:text-brand-primary pb-1'
                }`}
            >
              {item.label}
            </button>
          ))}
        </nav>
      </div>
    </div>
  );
}
```

**Usage on Services page:**
```tsx
// Add `id` props to each ServiceCard section
<section id="cosmetic-painting">
  <ServiceCard ... />
</section>

// Above the sections:
<ServiceSubNav
  items={[
    { id: 'cosmetic-painting', label: t('subnav.cosmetic') },
    { id: 'flooring',          label: t('subnav.flooring') },
    { id: 'design',            label: t('subnav.design') },
  ]}
/>
```

### Step 5 — Scroll-Triggered Element Visibility Pattern

Generic pattern for any element that should appear/disappear based on scroll position:

```tsx
'use client';
import { useEffect, useState } from 'react';

function useScrollTrigger(threshold: number = 300) {
  const [triggered, setTriggered] = useState(false);

  useEffect(() => {
    const onScroll = () => setTriggered(window.scrollY > threshold);
    // Check immediately on mount
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, [threshold]);

  return triggered;
}

// Usage:
export function SomeFloatingElement() {
  const visible = useScrollTrigger(400);

  return (
    <div className={`fixed bottom-8 right-8 transition-all duration-300
      ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4 pointer-events-none'}`}>
      {/* content */}
    </div>
  );
}
```

### Step 6 — Z-Index Management

When adding a new fixed/sticky element, always declare its z-index relative to the stack:

```tsx
// Layering from bottom to top:
// z-10  → Background overlays (hero gradient)
// z-20  → Hero text content
// z-40  → Mobile sticky bar
// z-50  → Header, WhatsApp widget
// z-[60] → Modals, drawers (if ever added)
// z-[70] → Toasts, notifications
```

**Never use `z-[9999]`** — it breaks the layering system and is a code smell.

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| WhatsApp widget hidden behind sticky bar on mobile | Both using same `bottom-6` | Use `bottom-[76px]` on mobile for WhatsApp |
| Dropdown menu appears behind page content | Missing `z-50` on dropdown container | Add `z-50 relative` to dropdown wrapper |
| Sticky sub-nav cuts off section heading when scrolled to | Offset not accounting for sub-nav height | Increase `offset` in `scrollTo()` to include sub-nav height |
| Sticky header not working in Safari | CSS `position: sticky` needs parent to not have `overflow: hidden` | Remove `overflow-hidden` from layout ancestors |
| Mobile sticky bar causes content jump | No bottom padding on body content | Add `pb-16 md:pb-0` to the `<main>` element |

## Constraints & Anti-Patterns

- **DO NOT** use `position: fixed` for the main header — use `sticky` (avoids layout shift and body padding)
- **DO NOT** remove `md:hidden` from `MobileStickyBar` — it must never show on desktop where the header CTA is visible
- **DO NOT** use `z-[9999]` or similar arbitrary huge values — maintain the z-index ladder
- **DO NOT** listen to `scroll` events without `{ passive: true }` — causes janky scroll on mobile
- **DO NOT** forget `pointer-events-none` on hidden elements with `opacity-0` — invisible elements can block clicks
- **ALWAYS** clean up event listeners in `useEffect` return functions
- **ALWAYS** check both locales after adding/modifying sticky elements (Italian text may be longer)

## Invocation Examples

- "Add a scroll shadow to the sticky header"
- "Fix the WhatsApp button overlapping the mobile sticky bar"
- "Create a sticky sub-navigation for the Services page"
- "Make the sticky bar appear immediately on mobile instead of after scrolling"
- "Add a scroll-to-top button that appears after 500px scroll"
- "Fix z-index conflict between the dropdown menu and the page content"

## Completion Checks

- [ ] Z-index follows the declared stack: `z-40` mobile bar, `z-50` header and WhatsApp, `z-[60]+` modals
- [ ] No `z-[9999]` or arbitrary large z-index values introduced
- [ ] `MobileStickyBar` has `md:hidden` — never visible on desktop
- [ ] All `window.addEventListener('scroll', …)` calls use `{ passive: true }`
- [ ] Elements hidden with `opacity-0` also carry `pointer-events-none`
- [ ] Every `useEffect` that adds an event listener returns a cleanup that removes it
- [ ] WhatsApp widget clears the mobile sticky bar on mobile (`bottom-[76px]` or CSS custom property)
- [ ] Header uses `sticky top-0` (not `position: fixed`) — no body padding-top required
- [ ] iOS home indicator cleared via `env(safe-area-inset-bottom)` on bottom-fixed bars
- [ ] Both `it` and `en` locales verified — Italian nav text length does not break header layout

## References

No external references required.
