# LedgerUI.Components.Mask

Crops its content to one of nine mask shapes: `squircle`, `reuleaux-triangle`, `diamond`,
`hexagon`, `hexagon-2`, `octagon`, `star`, `star-2` and `heart`.

    <.mask shape="heart" src="/images/avatar.jpg" alt="Jane" size="64" />
    <.mask shape="hexagon" size="56"><span>JD</span></.mask>
    <.mask shape="star" label="Favorite" size="32" />

With `src` it renders the masked image; otherwise a block holding the inner content. The block
keeps its inner content readable by screen readers; give it a `label` when the shape itself
carries the meaning (`role="img"` and `aria-label`). The size is `size` (pixels, or an
`LedgerUI.Components.Avatar` size name); paint it with `style="background: ..."`.

It is drawn with the face of the avatar (`LedgerUI.Components.Avatar`), so it is styled only with
Tailwind utilities.

## `<.mask>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `shape` | `:string` | `"squircle"` | `squircle`, `reuleaux-triangle`, `diamond`, `hexagon`, `hexagon-2`, `octagon`, `star`, `star-2`, `heart` |
| `src` | `:string` | `nil` |  |
| `alt` | `:string` | `""` |  |
| `label` | `:string` | `nil` | Names a block mask for assistive technology. |
| `size` | `:string` | `"64"` | Pixels or an avatar size name. |
| `style` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`
