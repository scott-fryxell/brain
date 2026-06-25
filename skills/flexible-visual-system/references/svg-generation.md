# SVG Generation (vanilla)

Build SVG ourselves as strings or DOM. No p5, no svg.js. The patterns below are the whole toolkit.

## Coordinate system = viewBox = grid

Treat the `viewBox` as the math space. Pick a clean size so cell math stays integer-friendly.

```js
const size = 1000; // viewBox is 0 0 1000 1000
const cols = 10;
const rows = 10;
const cell = size / cols; // 100 units per cell

function cell_xy(col, row) {
  return { x: col * cell, y: row * cell };
}
```

Render units, not pixels. The SVG scales to any display.

## Building the SVG shell

```js
function svg(inner, size) {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${size} ${size}">${inner}</svg>`;
}
```

Append module markup into `inner` as you walk the grid.

## Placing a module per cell

```js
function tile(size, cols, draw_module) {
  const cell = size / cols;
  let inner = "";
  for (let row = 0; row < cols; row++) {
    for (let col = 0; col < cols; col++) {
      const x = col * cell;
      const y = row * cell;
      inner += draw_module({ x, y, cell, col, row });
    }
  }
  return svg(inner, size);
}
```

`draw_module` returns the SVG for one cell. That keeps the module rule isolated.

## Transform composition

Use the `transform` attribute. Order matters: SVG applies right-to-left, so `translate` first puts the origin at the cell, then `rotate` spins around it.

```js
function half_disc({ x, y, cell, deg, fill }) {
  const r = cell / 2;
  const cx = x + r;
  const cy = y + r;
  // rotate around the cell center
  return `<g transform="translate(${cx} ${cy}) rotate(${deg})">
    <path d="M ${-r} 0 A ${r} ${r} 0 0 1 ${r} 0 Z" fill="${fill}"/>
  </g>`;
}
```

To rotate about an arbitrary point without nesting, use `rotate(deg cx cy)`.

## Seeded RNG (mulberry32)

Reproducibility is non-negotiable. Same seed -> same art.

```js
function rng(seed) {
  let a = seed >>> 0;
  return function () {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// quantized pick (e.g. one of four rotations)
function pick(rand, list) {
  return list[Math.floor(rand() * list.length)];
}
```

Thread one `rand` through the whole render. The seed is the art's address.

## Putting it together: a generator

```js
function generate({ seed, size = 1000, cols = 10, palette }) {
  const rand = rng(seed);
  const cell = size / cols;
  let inner = "";
  for (let row = 0; row < cols; row++) {
    for (let col = 0; col < cols; col++) {
      const x = col * cell;
      const y = row * cell;
      const deg = pick(rand, [0, 90, 180, 270]); // transformation rule
      const accent = rand() < 0.2; // color rule (seeded gate)
      const fill = accent ? palette.accent : palette.fg;
      inner += half_disc({ x, y, cell, deg, fill });
    }
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${size} ${size}">
    <rect width="${size}" height="${size}" fill="${palette.bg}"/>${inner}</svg>`;
}
```

`generate({ seed: 42, palette })` is fully reproducible.

## Export to a file

```js
import { writeFile } from "node:fs/promises";

const markup = generate({ seed: 42, palette });
await writeFile("out/poster-42.svg", markup);
```

Filename should carry the seed so a keeper is traceable back to its rules.

## Polar / radial grids

When the grid is radial instead of square, compute positions from angle + radius:

```js
function ring_xy(center, radius, i, count) {
  const a = (i / count) * Math.PI * 2;
  return { x: center + Math.cos(a) * radius, y: center + Math.sin(a) * radius };
}
```

Same module + transform rules apply; only the placement math changes.

## Performance notes

- For contact sheets, render many small SVGs rather than one giant one.
- Keep node counts sane: a 50x50 tile is 2500 nodes, fine; 500x500 is not.
- Strings are faster to assemble than DOM for batch export; use DOM when the playground needs interactivity.
