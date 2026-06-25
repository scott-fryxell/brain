---
name: realness-design
description: Apply the realness design system — element-first CSS architecture, fluid modular type, base-line grid, blue/red accent tokens, and OS-native dark mode. Use when writing or reviewing CSS for any project in this workspace, styling HTML elements directly, implementing the type scale or spacing system, or deciding how to structure a stylesheet. Pairs with the html, typography, and css-ux-interface-design skills.
metadata:
  category: Design & Frontend
  tags:
    - css
    - design-system
    - typography
    - color
    - layout
---

# Realness Design

Style the platform. Not components — elements.

## The Virtuous Cycle

Semantic element, CSS selector, and microdata attribute all converge on the same thing. No utility classes. No `.author-block` or `.date-display`. The element IS the selector IS the schema.

```html
<address itemscope itemtype="/person" itemid="...">
  <h3 itemprop="name">Scott</h3>
</address>
<time itemprop="datePublished" datetime="2025-04-28">April 28, 2025</time>
```

```css
address[itemscope] { font-style: normal; }
time { font-weight: 300; display: block; }
```

Each layer reinforces the others: correct semantics reduce CSS selectors needed; microdata attributes provide structural hooks without extra classes; element-based CSS rewards using the right element. When you style `time` properly, you use `<time>` properly.

## Architecture

CSS files are named after HTML elements, not components or features. `a`, `article`, `main`, `nav`, `section` — one file per element. The browser's element model is the architecture.

## Spacing: base-line

Everything derives from one unit:

```css
--base-line: 1.333rem;
```

Margins, gaps, padding — all multiples of `base-line`. Not arbitrary pixels, not `rem` guesses. When something feels off, check whether it's a multiple.

## Type: fluid modular scale

Font sizes scale continuously between two breakpoints — no jumps. The scale is mathematically derived (min ratio 1.25, max ratio 1.414):

```
h1: 1.602rem → 2.441rem
h2: 1.424rem → 1.953rem
h3: 1.266rem → 1.563rem
body: 1.125rem → 1.333rem
```

Implementation uses the `between` mixin (slope-intercept form):

```css
font-size: calc(min + (max - min) * (100dvw - pad-begins) / (display-begins - pad-begins));
```

Headings: `font-weight: 300`, `letter-spacing: -0.02em`, `line-height: 1`. Light and tight.

Font: Lato (Light 300, Regular 400, Heavy 800), self-hosted as woff2 subsets with `font-display: swap`.

## Color: two accents, semantic neutrals

Blue and red are the accent pair. They're CSS custom properties so they shift between light and dark mode:

```css
/* light */
--blue: hsl(180, 35%, 32%);
--red:  hsl(0, 35%, 38%);

/* dark */
--blue: hsl(180, 40%, 62%);
--red:  hsl(0, 40%, 62%);
```

Neutral palette uses earth names: `sediment`, `sand`, `gravel`, `rocks`, `boulders`. Surface tokens: `--text`, `--surface`, `--code-surface`.

Brand gradient (headings, key links):

```css
background: linear-gradient(60deg, var(--blue), var(--red));
background-clip: text;
-webkit-background-clip: text;
color: transparent;
```

## Dark mode

`prefers-color-scheme` only. No JS, no class toggling. The OS preference is authoritative.

```css
:root { --blue: hsl(180, 35%, 32%); }
@media (prefers-color-scheme: dark) {
  :root { --blue: hsl(180, 40%, 62%); }
}
```

## Links

```css
a { color: var(--blue); text-decoration: none; }
p > a {
  border-bottom: 0.08vmin solid var(--blue);
  transition: all 0.8s ease-in-out 0.1s;
}
p > a:hover { color: var(--red); }
```

Links inside prose get a subtle bottom border and a blue→red hover transition. Bare `a` elements (nav, UI) get no underline.

## HTML attributes as application state

The more expressive the HTML, the less JavaScript you need. Native HTML attributes carry state that CSS can read directly — no JS toggle, no class manipulation.

```css
/* [open] is set by the browser — CSS responds, no JS */
details[open] > *:not(summary) { animation-name: slideInLeft; }

/* :has() reads DOM state — scroll lock with zero JS */
body:has(dialog[open]) { overflow: hidden; }
```

Prefer native boolean attributes (`open`, `disabled`, `checked`, `hidden`) over JS-managed classes. Prefer `<details>`/`<summary>` for disclosure, `<dialog>` for modals, `<input type="checkbox">` for toggles — each carries state the browser and CSS already understand.

## HTML as the data model

`itemid` is a URL path that serves as storage key, fetch URL, CSS selector, and schema identifier simultaneously. One identifier across every layer.

`itemprop_value()` in `item.js` reads element semantics to extract values — `<time datetime>`, `<img src>`, `<a href>`, `<meta content>` — the element type tells you how to read the data. HTML semantics carry meaning all the way into the data layer, not just the display layer.

When writing HTML: choose the element whose native semantics match the data. The browser, CSS, and any data layer all benefit from the same choice.

## No reset

Don't add a CSS reset or normalize. Style what needs styling. Trust the browser's defaults for what isn't touched.

## Integration

- **html**: choose the right element first — semantics drive the CSS selectors
- **css-ux-interface-design**: clarity, affordance, and interaction decisions
- **typography**: theory and font selection for new projects — for realness projects, the type decisions here are already settled and take precedence over generic typography advice
- **css-motion-systems**: all animation decisions — defer entirely
