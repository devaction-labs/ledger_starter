# LedgerUI.Components.Typography

Ledger UI's type scale: headings, running text, text links, inline code and keyboard keys.

    <.heading level={1}>Heading H1</.heading>
    <.heading level={1} size="title">Financeiro</.heading>
    <.heading display={2}>Display 2</.heading>

    <.text size="lg" color="subtle">Contas a pagar e a receber.</.text>
    <.text as="span" mono color="ink">R$ 3.120,50</.text>
    <.text as="span" size="lg" weight="semibold" gradient="sky-blue">Gradient</.text>
    <.text_link href="#" decoration_color="info" decoration_style="wavy">Tattooine</.text_link>

    Press <.kbd>Ctrl</.kbd> + <.kbd>K</.kbd>, or run <.inline_code>mix test</.inline_code>.

Sizes, weights and colours are Tailwind utilities that read the design tokens (`text-ink`,
`text-muted`...), so they follow the theme. Every attr left at `nil` emits nothing and the text
inherits.

Colours: `default` inherits, `ink`/`fg` are the primary text, `neutral` is `ink-2`, `muted`,
`subtle`/`faint` the secondary and meta greys, `primary` the accent text, and
`success`/`warning`/`error`/`info`/`secondary` the signal colours.

`text` defaults `weight` to `nil` (inherit); an explicit `"normal"` sets `font-weight:400`.
A `gradient` paints the glyphs with the named gradient (bold unless `weight` says otherwise) and
makes `color` moot. `style` and `class` are for layout and one-off tweaks (a `style` always wins).

## `<.heading>`

A heading, `<h1>` to `<h6>`. `display` renders the display headings (an `<h1>` unless `level`
says otherwise); `size` sets the type size apart from the level; `size="title"` is the page
title (34/40, semibold, ink).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `level` | `:integer` | `nil` | `nil`, `1`, `2`, `3`, `4`, `5`, `6` |
| `size` | `:string` | `nil` | `nil`, `2xl`, `3xl`, `base`, `lg`, `sm`, `title`, `xl` |
| `display` | `:integer` | `nil` | `nil`, `1`, `2`, `3`, `4`, `5` |
| `weight` | `:string` | `nil` | `nil`, `normal`, `light`, `medium`, `semibold`, `bold` |
| `color` | `:string` | `"default"` | `default`, `error`, `faint`, `fg`, `info`, `ink`, `muted`, `neutral`, `primary`, `secondary`, `subtle`, `success`, `warning` |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.text>`

A run of text, a paragraph unless `as` says otherwise.

`meta` is the 12.5px meta/help line, `lead` the line under a page title.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `as` | `:string` | `"p"` | `p`, `span`, `div`, `strong`, `em`, `small` |
| `size` | `:string` | `"inherit"` | `inherit`, `xs`, `xs-plus`, `sm`, `base`, `lg`, `xl`, `meta`, `lead` |
| `weight` | `:string` | `nil` | `nil`, `normal`, `light`, `medium`, `semibold`, `bold` |
| `color` | `:string` | `"default"` | `default`, `error`, `faint`, `fg`, `info`, `ink`, `muted`, `neutral`, `primary`, `secondary`, `subtle`, `success`, `warning` |
| `mono` | `:boolean` | `false` |  |
| `gradient` | `:string` | `nil` | `nil`, `sky-blue`, `green-fuchsia`, `fuchsia-pink`, `amber-orange`, `purple-indigo` |
| `decoration` | `:string` | `nil` | `nil`, `underline`, `overline`, `line-through`, `none` |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.text_link>`

A link inside running text, underlined (1px) in a theme colour and style. It keeps the weight
of the text around it. With `href`, `navigate` or `patch`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `decoration_color` | `:string` | `"current"` | `current`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `decoration_style` | `:string` | `"solid"` | `solid`, `wavy`, `double`, `dotted`, `dashed` |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `target`, `rel`, `replace`.

Slots:

- `<:inner_block>` (required)

## `<.inline_code>`

Code inside running text: mono 12.5px on the fill colour, in the primary text colour.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.kbd>`

A keyboard key.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"raised"` | `raised`, `flat`, `dark` - `flat` has no shadow, on the sunken fill; `dark` is for dark surfaces (tooltip, toast). |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.typography>`

Same as `text/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `as` | `:string` | `"p"` | `p`, `span`, `div`, `strong`, `em`, `small` |
| `size` | `:string` | `"inherit"` | `inherit`, `xs`, `xs-plus`, `sm`, `base`, `lg`, `xl`, `meta`, `lead` |
| `weight` | `:string` | `nil` | `nil`, `normal`, `light`, `medium`, `semibold`, `bold` |
| `color` | `:string` | `"default"` | `default`, `error`, `faint`, `fg`, `info`, `ink`, `muted`, `neutral`, `primary`, `secondary`, `subtle`, `success`, `warning` |
| `mono` | `:boolean` | `false` |  |
| `gradient` | `:string` | `nil` | `nil`, `sky-blue`, `green-fuchsia`, `fuchsia-pink`, `amber-orange`, `purple-indigo` |
| `decoration` | `:string` | `nil` | `nil`, `underline`, `overline`, `line-through`, `none` |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
