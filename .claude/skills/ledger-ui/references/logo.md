# LedgerUI.Components.Logo

The Ledger UI mark. By default the chart glyph of the design canvas (an axis with a rising
line) on a rounded tile: `tone="accent"` is a tile of the theme accent, `tone="mono"` the `inverse` tile.
`mark="hexagon"` draws the README mark instead: a drop inside a hexagon (the ring follows the
page ink, the drop takes the theme accent, or silver with `tone="mono"`).

    <.logo />
    <.logo size={28} wordmark />
    <.logo tone="mono" size={56} />
    <.logo mark="hexagon" id="hero-logo" size={96} />

The tile is only utilities (`--s` is its side, set inline). With `mark="hexagon"`
and an `id` the drop gets a soft gradient named after it (`<id>-drop`); without one it is flat,
so the markup stays deterministic and logos never borrow each other's gradient.

## `<.logo>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` | Names the gradient of the drop; without one the drop is flat. |
| `mark` | `:string` | `"chart"` | `chart`, `hexagon` |
| `size` | `:integer` | `32` | The side of the mark, in px. |
| `glyph` | `:integer` | `nil` | The chart glyph's side in px (`chart` mark); half of `size` by default. |
| `tone` | `:string` | `"accent"` | `accent`, `mono`, `inverse` - `mono` is an inverse tile; `inverse` the opposite one (for an inverse surface). |
| `gap` | `:string` | `"base"` | `base`, `lg` - Mark to word: `base` is .4em, `lg` 10px (the canvas brand). |
| `wordmark` | `:boolean` | `false` | Adds "Ledger UI" after the mark. |
| `word_size` | `:integer` | `nil` | Size of the word in px (default 0.6 x size, at most 30). |
| `name` | `:string` | `nil` | Your brand's name, written after the mark (it implies `wordmark`) and used as its accessible name. |
| `context` | `:string` | `nil` | A muted line under the `name`: the workspace or the product line. |
| `label` | `:string` | `nil` | The accessible name (the `name`, or "Ledger UI"). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
