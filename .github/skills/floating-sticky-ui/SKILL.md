---
name: floating-sticky-ui
description: "Use when implementing or debugging sticky navigation, floating mobile CTA bars, WhatsApp widgets, scroll-triggered visibility, or z-index layering conflicts on the Garnebo site. Do NOT use for static page layout sections, grid design, or non-fixed component styling."
argument-hint: "component name (header/mobile-bar/whatsapp/sub-nav), issue type (z-index/positioning/scroll-trigger), target breakpoint"
user-invocable: true
---

# Floating and Sticky UI Elements

Implement and maintain the sticky navigation, floating mobile CTA bar, floating WhatsApp widget, and any other fixed/sticky UI elements on the Garnebo site. Ensures correct `z-index` layering, smooth transitions, scroll-triggered visibility, and no overlap conflicts.

**Z-index stack (reserved values):**

| Layer | z-index | Elements |
|---|---|---|
| Floating bottom bar | `z-40` | `MobileStickyBar` |
| Fixed overlays | `z-50` | `Header`, `WhatsAppWidget`, modals |
| Modals/toasts | `z-[60]+` | Drawers, notifications |

**Never use `z-[9999]`** — it breaks the layering system.

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
<header className="sticky top-0 z-50 bg-bg-primary border-b border-accent-sage/30">
  <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
    {/* Logo | Nav links | CTA button | Locale toggle */}
  </div>
</header>
```

**Adding a scroll shadow:**
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
    <header className={`sticky top-0 z-50 bg-bg-primary border-b border-accent-sage/30 transition-shadow duration-200
      ${scrolled ? 'shadow-md' : 'shadow-none'}`}>
      {/* ... */}
    </header>
  );
}
```

### Step 2 — Mobile Sticky CTA Bar

The existing `MobileStickyBar` slides in from the bottom after 300px scroll and hides on `md:` breakpoint.

**Key pattern:**
```tsx
className={`fixed bottom-0 left-0 right-0 z-40 ... transition-transform duration-300 md:hidden
  ${visible ? 'translate-y-0' : 'translate-y-full'}`}
```

**iOS home indicator clearance — add to `globals.css`:**
```css
@layer utilities {
  .pb-safe {
    padding-bottom: max(12px, env(safe-area-inset-bottom));
  }
}
```

Then use `pb-safe pt-3 px-4` on `MobileStickyBar`.

### Step 3 — WhatsApp Floating Widget

The `WhatsAppWidget` is positioned `bottom-6 right-6`. On mobile the sticky bar occupies the bottom, so WhatsApp must clear it.

**Fix mobile positioning conflict:**
```tsx
className="group fixed z-50 flex h-14 w-14 items-center justify-center rounded-full bg-[#25D366] shadow-lg transition-transform hover:scale-110
  bottom-[76px] right-4
  md:bottom-6 md:right-6"
```

Or use a CSS custom property:
```css
:root {
  --sticky-bar-height: 60px;
}
@layer utilities {
  .bottom-above-sticky {
    bottom: calc(var(--sticky-bar-height) + 1rem);
  }
}
```

### Step 4 — Sticky Sub-Navigation (Services Page)

```tsx
'use client';
import { useEffect, useRef, useState } from 'react';

interface ServiceSubNavProps {
  items: { id: string; label: string }[];
}

export function ServiceSubNav({ items }: ServiceSubNavProps) {
  const [activeId, setActiveId] = useState(items[0]?.id ?? '');
  const [stuck, setStuck] = useState(false);
  const navRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const sentinel = navRef.current;
    if (!sentinel) return;
    const observer = new IntersectionObserver(
      ([entry]) => setStuck(!entry.isIntersecting),
      { threshold: 1, rootMargin: '-56px 0px 0px 0px' }
    );
    observer.observe(sentinel);
    return () => observer.disconnect();
  }, []);

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
      const offset = 112; // header + sub-nav height
      const top = el.getBoundingClientRect().top + window.scrollY - offset;
      window.scrollTo({ top, behavior: 'smooth' });
    }
  };

  return (
    <div ref={navRef}
      className={`sticky top-[56px] z-40 bg-bg-white border-b transition-shadow duration-200
        ${stuck ? 'shadow-sm border-accent-sage/30' : 'border-transparent'}`}>
      <nav className="flex gap-6 overflow-x-auto py-3 scrollbar-none px-4 sm:px-6 lg:px-8" aria-label="Service categories">
        {items.map((item) => (
          <button key={item.id} onClick={() => scrollTo(item.id)}
            className={`flex-shrink-0 text-[13px] font-semibold uppercase tracking-wider transition-colors
              ${activeId === item.id ? 'text-brand-primary border-b-2 border-brand-primary pb-1' : 'text-brand-secondary hover:text-brand-primary pb-1'}`}>
            {item.label}
          </button>
        ))}
      </nav>
    </div>
  );
}
```

### Step 5 — Scroll-Triggered Visibility Hook

```tsx
'use client';
import { useEffect, useState } from 'react';

function useScrollTrigger(threshold: number = 300) {
  const [triggered, setTriggered] = useState(false);

  useEffect(() => {
    const onScroll = () => setTriggered(window.scrollY > threshold);
    onScroll(); // check on mount
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, [threshold]);

  return triggered;
}
```

### Step 6 — Common Issues and Fixes

| Issue | Cause | Fix |
|---|---|---|
| WhatsApp hidden behind sticky bar on mobile | Both using `bottom-6` | Use `bottom-[76px]` on mobile for WhatsApp |
| Dropdown behind page content | Missing `z-50` | Add `z-50 relative` to dropdown wrapper |
| Sticky sub-nav cuts off section heading | Offset not accounting for sub-nav height | Increase `offset` in `scrollTo()` |
| Sticky header not working in Safari | Parent has `overflow: hidden` | Remove `overflow-hidden` from layout ancestors |
| Mobile sticky bar causes content jump | No bottom padding on body content | Add `pb-16 md:pb-0` to `<main>` element |

> **Constraints:** Do NOT use `position: fixed` for the main header — use `sticky`. Do NOT remove `md:hidden` from `MobileStickyBar`. Do NOT use `z-[9999]`. Do NOT listen to `scroll` without `{ passive: true }`. Do NOT forget `pointer-events-none` on elements with `opacity-0`. Always clean up event listeners in `useEffect` returns.

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
