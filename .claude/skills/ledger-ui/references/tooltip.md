# LedgerUI.Components.Tooltip

A short hint around a trigger (`<.tooltip>`).

    <.tooltip id="save-tip" text="Save the draft">
      <.button>Save</.button>
    </.tooltip>

    <.tooltip id="top-start" text="Top Start" color="success" placement="top-start">
      <.button variant="outline">Top Start</.button>
    </.tooltip>

    <.tooltip id="profile" trigger="click">
      <.button>Content</.button>
      <:content><div class="p-3">...</div></:content>
    </.tooltip>

The trigger is the inner block (or, with a `<:trigger>` slot, the slot, and the inner block is
the hint: `<.tooltip id="t"><:trigger><.button>Save</.button></:trigger>Save the draft</.tooltip>`); the hint floats next to it (`placement`, 12 values) in any
`color`. The `LedgerUI.Float` hook (`priv/static/ledger_ui/hooks/float.js`) shows it on hover/focus,
click or never (`manual`), after `delay` ms, optionally following the cursor, and flips it when
there is no room. `LedgerUI.open/close/toggle("id")` show and hide it, `open` drives it from the
server. `on_open` / `on_close` take an event name (payload `%{"id" => id}`, sent to `target`) or a `%JS{}`.

## `<.tooltip>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `text` | `:string` | `nil` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `light`, `dark`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `placement` | `:string` | `"top"` | `top`, `top-start`, `top-end`, `right`, `right-start`, `right-end`, `bottom`, `bottom-start`, `bottom-end`, `left`, `left-start`, `left-end` |
| `delay` | `:integer` | `0` |  |
| `duration` | `:integer` | `300` |  |
| `follow_cursor` | `:string` | `nil` | `nil`, ``, `both`, `horizontal`, `vertical`, `initial` |
| `arrow` | `:boolean` | `true` |  |
| `interactive` | `:boolean` | `nil` |  |
| `open` | `:boolean` | `false` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `tip_class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `trigger`, `content`.

Slots:

- `<:content>`
- `<:inner_block>` (required)
- `<:trigger>` - The element the hint hangs from; the inner block is then the hint.

## `<.tooltip_tip>`

Only the bubble of a tooltip, in the page flow: no trigger, no hook, no floating. For previews
and for hints you place yourself.

    <.tooltip_tip arrow="bottom">Search <.kbd variant="dark">⌘K</.kbd></.tooltip_tip>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `color` | `:string` | `"neutral"` | `neutral`, `light`, `dark`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `size` | `:string` | `"sm"` | `sm`, `md` - `sm` is the 12px hint of `tooltip/1`; `md` the larger 12.5px one (more padding, a deeper shadow). |
| `arrow` | `:string` | `nil` | `nil`, `top`, `bottom`, `left`, `right` - The side the arrow is drawn on (it points away from the bubble); no arrow by default. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
