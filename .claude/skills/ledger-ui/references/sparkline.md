# LedgerUI.Components.Sparkline

The canvas's sparkline: a line with a soft fill under it, drawn on the server from a list of
numbers (the highest at the top), so it renders without JavaScript. Styled only with Tailwind
utilities; the line draws in once on mount (the area fades in, the end dot pops).

    <.sparkline id="bb" values={[8, 12, 9, 14, 11, 16]} />
    <.sparkline id="itau" values={@balances} color="primary" />

`color="primary"` draws it in the accent, `neutral` (default) in the ink. The SVG stretches to
the width of its box (`preserveAspectRatio="none"`); the box gets its size from `class`/`style`.
`variant="backdrop"` is the faded panel at the right of a `kpi_card` (it positions itself
absolutely inside the card body). `id` names the gradient of the fill and must be unique on the page.

## `<.sparkline>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  | Names the gradient of the fill, so it must be unique. |
| `values` (required) | `:list` |  | Numbers for the line. |
| `color` | `:string` | `"neutral"` | `neutral`, `primary` |
| `variant` | `:string` | `"inline"` | `inline`, `backdrop` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
