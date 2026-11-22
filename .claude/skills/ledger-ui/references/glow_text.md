# LedgerUI.Components.GlowText

Text with a living gradient: the colors drift across the letters. Styled only with Tailwind
utilities (a gradient clipped to the text, moved by the `mo-glowtx` keyframes).

    <.glow_text as="h1">Signetum</.glow_text>
    <.glow_text tone="warm">New</.glow_text>

`default` runs from the ink through the accent and the assistant violet; `warm` through amber and
rose. Size it with `style` or a `text-*` class on the call.

## `<.glow_text>`

Renders the gradient text. `as` is the HTML tag.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `tone` | `:string` | `"default"` | `default`, `warm` |
| `as` | `:string` | `"span"` | `span`, `h1`, `h2`, `h3`, `p`, `div` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
