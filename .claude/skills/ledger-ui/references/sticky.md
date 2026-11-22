# LedgerUI.Components.Sticky

A block that sticks to the top of the page and takes classes while the page is scrolled: a header
that gets an edge, a bar that gets a shadow.

    <.sticky id="page-bar" stuck_class="shadow-md">...</.sticky>

The hook `LedgerUI.Sticky` (`priv/static/ledger_ui/hooks/sticky.js`) adds `stuck_class` and sets
`data-stuck` once the page is scrolled past `offset` pixels, and takes them off when it is back.
The block is `sticky top-0`; without a `stuck_class` it draws a 1px bottom line while stuck.

## Preview

`preview` draws the canvas picture of the behavior: a frame with the `:header` slot on a
translucent bar and the content scrolling under it (`body_class` / `body_style` go to the content, for
the scrolling animation). No hook. For the documentation and the showcase only.

    <.sticky id="demo" preview body_class="animate-[mo-scroll_8s_ease-in-out_infinite]" body_style="--sy:-160px">
      <:header>Orders today</:header>
      <i style="width:90%"></i>
    </.sticky>

## `<.sticky>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `offset` | `:integer` | `0` | Pixels the page scrolls before the block counts as stuck. |
| `stuck_class` | `:string` | `nil` | Classes added while stuck. Without it the hook draws a 1px bottom line. |
| `preview` | `:boolean` | `false` | The canvas picture of a sticky header. |
| `body_class` | `:string` | `nil` | With `preview`: extra classes of the content. |
| `body_style` | `:string` | `nil` | With `preview`: the style of the content. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:header>` - With `preview`: the content of the bar.
- `<:inner_block>` (required)
