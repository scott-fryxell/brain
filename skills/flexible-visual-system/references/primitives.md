# Primitives Vocabulary

The six primitives are the entire system. Compose them; do not add more categories.

## 1. Module

The base mark placed at each grid position.

- **Shape**: circle, square, triangle, line, arc, half-disc, custom path
- **Weight**: stroke width, or filled vs outlined
- **Anchor**: where the module sits in its cell (center, corner, edge)
- **Orientation**: a default rotation before transformation rules apply

Keep one or two module shapes. A single half-disc rotated four ways already yields a rich system.

## 2. Grid (coordinate system)

The scaffold modules snap to. Lives inside the SVG `viewBox`.

- **Type**: square, rectangular, isometric, triangular, polar/radial, skewed
- **Density**: columns x rows (start 6x6 to 12x12)
- **Cell size**: derived from `viewBox / count`
- **Gutter**: gap between cells (can be zero for tight tessellation)

The grid is fixed scaffolding. Variation comes from what happens _in_ each cell, not from moving the grid.

## 3. Repetition

How the module multiplies across the grid.

- **Tile**: same module in every cell
- **Array**: module repeated along one axis with a step
- **Ring / radial**: instances placed around a center by angle
- **Spiral**: radius + angle both increase per step
- **Recursive subdivision**: cells split into sub-cells, rule re-applied

Repetition is what turns one mark into a field.

## 4. Transformation

Per-instance change applied as the module is placed. This is where most variety lives.

- **Rotate**: by fixed steps (0/90/180/270) or by a rule (angle = f(index))
- **Scale**: uniform or per-axis, often keyed to position
- **Mirror / flip**: along x, y, or a diagonal
- **Shear / skew**: controlled slant
- **Displace**: offset from cell center by a (often seeded) amount

Rule of thumb: transform keyed to **position** reads as structured; transform keyed to **seed** reads as organic. Mix deliberately.

## 5. Color

Palette plus the logic that assigns it.

- **Palette**: 2-5 colors. Pull from project tokens when building design-system assets.
- **Assignment rules**:
  - by cell index (sequential cycling)
  - by position (gradient across the grid, quadrant blocks)
  - by module orientation (rotation maps to hue)
  - by seeded probability (N% chance of accent color)
- **Background**: part of the palette, not an afterthought

Color assignment is itself a rule. Do not pick colors per-cell by hand.

## 6. Randomness (controlled)

Variation you can reproduce.

- **Seeded RNG**: same seed -> same output, always. Never bare `Math.random()`.
- **Jitter range**: bounded offsets (e.g. rotation +-15deg)
- **Probability gates**: a rule fires with probability `p`
- **Quantized random**: pick from a small set (e.g. one of 4 rotations) rather than continuous

Randomness without a seed is not part of a system; it is noise you cannot recover.

## How primitives compose

A minimal but complete system:

```
module:        half-disc
grid:          10 x 10 square
repetition:    tile (one per cell)
transformation: rotate by quantized random {0,90,180,270}, seeded
color:         2-color, accent fires with p=0.2 by seed
randomness:    seed drives both rotation choice and accent gate
```

That is five lines of rules and produces an infinite, coherent poster family.

Add knobs one at a time. If a new knob does not increase usable variety, remove it.
