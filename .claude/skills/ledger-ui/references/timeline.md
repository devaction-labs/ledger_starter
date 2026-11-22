# LedgerUI.Components.Timeline

Events down a line, each marked by a filled, outlined, icon or avatar point.

    <.timeline marker="icon" size="lg">
      <.timeline_item title="NF-e autorizada" description="Protocolo 129 2611" time="14:02" color="success">
        <:point><.icon name="check" size="sm" /></:point>
      </.timeline_item>
    </.timeline>

The items can come from a list or a stream through `rows` and the `:item` slot, which gets
`{dom_id, row}` (given a stream, the list renders with `phx-update="stream"` and needs an `id`):

    <.timeline id="events" rows={@streams.events}>
      <:item :let={{id, event}}>
        <.timeline_item id={id} title={event.title} time={event.ago} color={event.color} />
      </:item>
    </.timeline>

`variant="canvas"` is a list of `timeline_event`s, each with a boxed icon tile, a title over a
subtitle and the time at the right.

Styled only with Tailwind utilities. The marker look (`solid`, `outline`, `icon`, `avatar`, `dot`)
belongs to the whole line, so it is set on the timeline with `marker` (the root carries
`data-lu-marker` and the items read it through `group-data-[lu-marker=...]/tl:`); the item's
`variant` only decides what its point holds. `loop` plays the canvas loop (`mo-stg`): each item
fades in, stays and leaves, staggered by its own `--dl` delay (`style="--dl:0.6s"`).

## `<.timeline>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `line_space` | `:boolean` | `false` | Leaves a gap between the points and the line. |
| `size` | `:string` | `"md"` | `md`, `lg`, `xl`, `2xl` |
| `density` | `:string` | `"default"` | `default`, `compact` |
| `variant` | `:string` | `"line"` | `line`, `canvas` |
| `marker` | `:string` | `"solid"` | `solid`, `outline`, `icon`, `avatar`, `dot` - The look of the points of a `line` timeline. |
| `loop` | `:boolean` | `false` | The canvas loop (`mo-stg`): the items fade in one after the other, forever. |
| `items` | `:list` | `[]` | Points as data, before the inner block: maps with `:title` and optionally `:time`, `:description`, `:color`, `:variant` (`solid`, `outline`, `icon`, `avatar`) and `:ping`, one `timeline_item/1` each. |
| `id` | `:string` | `nil` | Required with a stream. |
| `rows` | `:any` | `nil` | A list or a stream of rows rendered by the `:item` slot. |
| `row_id` | `:any` | `nil` | A function from a row to its DOM id, for a plain list. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`
- `<:item>` - Renders one row; gets `{dom_id, row}`.

## `<.timeline_item>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` | `:string` | `nil` |  |
| `time` | `:string` | `nil` |  |
| `description` | `:string` | `nil` |  |
| `color` | `:string` | `"neutral"` | `accent`, `dark`, `error`, `info`, `neutral`, `primary`, `secondary`, `success`, `warning` |
| `variant` | `:string` | `"solid"` | `solid`, `outline`, `icon`, `avatar` |
| `point_class` | `:any` | `nil` |  |
| `ping` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:details>` - The description with markup; replaces `description`.
- `<:inner_block>`
- `<:point>` - What the point shows, usually an icon.

## `<.timeline_event>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` | `:string` | `nil` |  |
| `subtitle` | `:string` | `nil` |  |
| `time` | `:string` | `nil` |  |
| `tone` | `:string` | `"default"` | `acc`, `default`, `info`, `neg`, `pos`, `warn` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>` - The icon inside the tile.
- `<:inner_block>` - Free content after the title and the subtitle.

## `<.timeline_day>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
