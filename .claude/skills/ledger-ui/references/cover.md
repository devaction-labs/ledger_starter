# LedgerUI.Components.Cover

The canvas cover: a wide band in the accent gradient (or a quiet surface) that heads a profile
or a page, with a title on it, or a record's avatar overlapping its lower edge.

    <.cover title="Distribuidora Sertão" />

    <.cover height={110} title="Distribuidora Sertão" subtitle="Cliente desde 2021">
      <:avatar><.avatar name="Distribuidora Sertão" tint="#1a7f4b" size="64" shape="rounded" /></:avatar>
    </.cover>

    <.cover tone="neutral" height={120} />

`tone` is `accent` (the accent gradient, white text) or `neutral` (the sunken surface). `src`
lays a picture over the band. Without `:avatar` the `title` is written on the band, at the
bottom; with it, the avatar overlaps the band's lower edge with the `title` and `subtitle`
beside it. The inner block goes on the band (actions, a badge). Styled only with Tailwind utilities.

## `<.cover>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `tone` | `:string` | `"accent"` | `accent`, `neutral` |
| `height` | `:integer` | `180` | The band's height in pixels. |
| `src` | `:string` | `nil` | A picture that covers the band. |
| `title` | `:string` | `nil` |  |
| `subtitle` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:avatar>` - An avatar that overlaps the band's lower edge.
- `<:inner_block>` - Content on the band.

## `<.cover_card>`

Same as `cover/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `tone` | `:string` | `"accent"` | `accent`, `neutral` |
| `height` | `:integer` | `180` | The band's height in pixels. |
| `src` | `:string` | `nil` | A picture that covers the band. |
| `title` | `:string` | `nil` |  |
| `subtitle` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:avatar>` - An avatar that overlaps the band's lower edge.
- `<:inner_block>` - Content on the band.
