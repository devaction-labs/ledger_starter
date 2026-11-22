# LedgerUI.Components.Container

Page containers: `container_fixed/1` centers its content up to the `xl` breakpoint (1280px),
`container_fluid/1` fills the width. Both keep a 24px gutter.

    <.container_fixed>
      <h1>Title</h1>
    </.container_fixed>

The sizing is plain utilities (width 100%, a 24px gutter, `max-w-*` and `mx-auto` for the fixed
one), so a `class` or a `style` of the caller only adds layout to it.

## Preview

`preview` draws the canvas diagram of a container instead of a real one: a hatched bar with
the accent span that shows the width of a `size` (`sm` 640px, `md` 768px, `lg` 1024px, `xl` 1280px,
`2xl` 1536px, `prose` 68ch, `full` 100%). `label` and `width` override the text and the span width;
the slot is ignored. For the documentation and the showcase only.

    <.container_fixed preview size="lg" class="flex-1" />

## `<.container_fixed>`

A centered container, as wide as the `xl` breakpoint at most.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `preview` | `:boolean` | `false` | The canvas diagram of a container. |
| `size` | `:string` | `nil` | `nil`, `2xl`, `full`, `lg`, `md`, `prose`, `sm`, `xl` - With `preview`: the size drawn. |
| `label` | `:string` | `nil` | With `preview`: the text of the bar. |
| `width` | `:string` | `nil` | With `preview`: the width of the bar. |
| `loop` | `:boolean` | `false` | With `preview`: the span breathes between narrow and wide (`--w` is the wide end). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.container_fluid>`

A container as wide as its parent.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `preview` | `:boolean` | `false` | The canvas diagram of a container. |
| `size` | `:string` | `nil` | `nil`, `2xl`, `full`, `lg`, `md`, `prose`, `sm`, `xl` - With `preview`: the size drawn. |
| `label` | `:string` | `nil` | With `preview`: the text of the bar. |
| `width` | `:string` | `nil` | With `preview`: the width of the bar. |
| `loop` | `:boolean` | `false` | With `preview`: the span breathes between narrow and wide (`--w` is the wide end). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.container>`

A centered container with a gutter, sized by `size`.

    <.container size="lg">...</.container>
    <.container size="prose" class="py-10">...</.container>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `size` | `:string` | `nil` | `nil`, `full`, `2xl`, `lg`, `md`, `prose`, `sm`, `xl` - The widest the content gets: `sm` 640px, `md` 768px, `lg` 1024px, `xl` 1280px, `2xl` 1536px, `prose` 68ch, `full` the parent's width. Without it, as `container_fixed/1`. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`
