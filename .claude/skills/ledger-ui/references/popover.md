# LedgerUI.Components.Popover

A card with an arrow next to its trigger (`<.popover>`), for more than a tooltip holds.

    <.popover id="lesson">
      <:trigger><.button variant="primary">Lessons</.button></:trigger>
      <:title>Group Lesson</:title>
      <p class="mt-2">Lorem ipsum dolor sit amet.</p>
    </.popover>

    <.popover id="john" trigger_on="hover" placement="top" width="192px">...</.popover>

Opens and closes from the browser (`LedgerUI.toggle("lesson")`), from the server
(`LedgerUI.close(socket, "lesson")`) or from `open`; a click outside and Esc close it. The
`LedgerUI.Float` hook (`priv/static/ledger_ui/hooks/float.js`) places it (`placement`, `fallbacks` when there
is no room, `offset`), draws the arrow and runs `on_open` / `on_close` (an event name with payload
`%{"id" => id}` to `target`, or a `%JS{}`).

The panel is a `role="dialog"` named by its `:title` or by `label`. `width` is the card's width
(272px by default; `nil` leaves it to its content).

## `<.popover>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `placement` | `:string` | `"right-start"` | `bottom-start`, `bottom`, `bottom-end`, `top-start`, `top`, `top-end`, `left-start`, `left`, `left-end`, `right-start`, `right`, `right-end` |
| `fallbacks` | `:list` | `["bottom", "top"]` |  |
| `offset` | `:integer` | `12` |  |
| `trigger_on` | `:string` | `"click"` | `click`, `hover` |
| `arrow` | `:boolean` | `true` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` | Merged into the card. |
| `width` | `:string` | `"272px"` | The card's width; `nil` for its content's. |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`
- `<:title>`
- `<:trigger>` (required)
