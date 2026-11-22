# LedgerUI.Components.Skeleton

Loading placeholder that mirrors the final layout. Styled only with Tailwind utilities; the
size comes from `class` (a block is 12px high until a `h-*` class says otherwise).

    <.skeleton class="h-3 w-40" animation="wave" />
    <.skeleton shape="circle" class="size-10" />

    <.skeleton_group label="Loading orders">
      <.skeleton class="w-3/5" />
    </.skeleton_group>

`skeleton_group` with `loop` and a `:loaded` slot plays the canvas loop: the placeholder, then the
content that arrives, in turn (CSS only).

`animation={nil}` (or `"none"`) draws a still block; `tag="span"` draws a span (inside a flex
column). `shape` is the corner: the base block has the small radius, so `"rounded"` (or `nil`)
keeps it.

## `<.skeleton>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `animation` | `:string` | `"wave"` | `nil`, `wave`, `pulse`, `none` |
| `variant` | `:string` | `"canvas"` | `canvas`, `lineone` |
| `shape` | `:string` | `nil` | `nil`, `rounded`, `pill`, `circle`, `square`, `lg` |
| `tag` | `:string` | `"div"` | `div`, `span` - The element drawn. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.skeleton_group>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` | `:string` | `"Loading…"` | Read by screen readers; not drawn. |
| `loop` | `:boolean` | `false` | The canvas loop (`lu-sw-a`/`lu-sw-b`): the placeholder, then the `:loaded` content, forever (demos). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
- `<:loaded>` - With `loop`: the content that replaces the placeholder.
