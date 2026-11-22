# LedgerUI.Components.Divider

A 1px separator in the `line` colour, horizontal or vertical, with optional centred or
left-aligned text.

    <.divider />
    <.divider>ou continue com</.divider>
    <.divider align="left">Entrega</.divider>
    <div class="flex items-center gap-2.5"><span>Day</span><.divider orientation="vertical" /><span>Month</span></div>

A horizontal divider without text is an `<hr>` 1px high in the `line` colour. With text it is a
row of two lines around the text (`align="center"`) or the text followed by one line
(`align="left"`), the text being a small uppercase label. A vertical divider is a 1px column,
18px high unless you pass `style="height:40px"` or an `h-*` class. Styled only with Tailwind
utilities.

## `<.divider>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `orientation` | `:string` | `"horizontal"` | `horizontal`, `vertical` |
| `align` | `:string` | `"center"` | `center`, `left` - Where a horizontal divider's text sits. |
| `label` | `:string` | `nil` | The text, as an attribute instead of the inner block. |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`
