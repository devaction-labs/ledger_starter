# LedgerUI.Components.ScrollArea

A box that scrolls with a thin scrollbar (6px, transparent track). For long menus, lists in a
card, the body of a panel. The height comes from `class` or an inline `style`.

    <.scroll_area style="max-height:16rem">...</.scroll_area>
    <.scroll_area focusable label="Release notes" style="max-height:16rem">...</.scroll_area>

`stick_bottom` keeps a list that grows at its end (a chat) scrolled to its last item, unless the
reader scrolled up: it mounts the `LedgerUI.ScrollBottom` hook (needs a stable `id`).

## `variant`

  * `"plain"` (default): the bare scrolling box.
  * `"panel"`: the canvas card that scrolls: border, background and radius of a panel.
  * `"preview"`: the canvas picture of a scroll area: a frame that clips the content and
    draws the scrollbar thumb (vertical or horizontal, animated) according to `orientation`;
    `scrollbar` `hover` fades the thumb out and `hidden` takes it away. The content is
    whatever the slot holds (the canvas wraps it in an animated `animate-[mo-scroll_…]` /
    `animate-[mo-scrollx_…]`). For the documentation and the showcase only.

## `<.scroll_area>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"plain"` | `plain`, `panel`, `preview` |
| `orientation` | `:string` | `"vertical"` | `both`, `horizontal`, `vertical` |
| `scrollbar` | `:string` | `"hover"` | `always`, `hidden`, `hover` |
| `focusable` | `:boolean` | `false` |  |
| `label` | `:string` | `nil` |  |
| `id` | `:string` | `nil` |  |
| `stick_bottom` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
