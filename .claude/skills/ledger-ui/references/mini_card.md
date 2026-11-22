# LedgerUI.Components.MiniCard

The canvas's mini card: a small card for a shortcut (an icon box over a bold label) or for a
short figure (a faint label over a mono value).

    <.mini_card icon="huge-invoice-01" tone="accent" label="Novo pedido" navigate={~p"/pedidos/novo"} />
    <.mini_card label="A receber" value="R$ 41,2 mil" />

With `href`, `navigate` or `patch` the card is a link and ends in an arrow. The inner block
goes under the label. `surface="card"` draws it as a card (rounded 16px, a hairline and a soft
shadow) with a rounded icon avatar (a row of shortcuts) instead of the default panel. Styled only
with Tailwind utilities.

## `<.mini_card>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `value` | `:string` | `nil` | A short figure: the label becomes a caption over it. |
| `icon` | `:string` | `nil` |  |
| `tone` | `:string` | `"neutral"` | `accent`, `error`, `info`, `neutral`, `success`, `warning` |
| `surface` | `:string` | `"panel"` | `panel`, `card` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`.

Slots:

- `<:inner_block>` - Extra content under the label.
