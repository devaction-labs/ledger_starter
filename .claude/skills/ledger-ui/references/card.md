# LedgerUI.Components.Card

The card of the system, styled only with Tailwind utilities: a tray (`bg-tray`, radius 20, 6px
border) whose upper-case title hugs a panel (`bg-panel`, radius 14). `variant="panel"` drops the
tray. Other variants (`default`, `flat`, `bordered`, `outline`, `muted`, `soft`, `filled`, `solid`,
`glow`, `gradient`, `gradient_outline`, plus the aliases `canvas` = `flat` and `page` = `default`)
are plain surfaces; the surface `flat` is the sunken, borderless one (title in a `<b>`, content as given), tinted by
`color` or `gradient`.

    <.card title="Revenue by plan">
      <:actions><.button size="sm" variant="outline" trailing_icon="huge-arrow-up-right">Plans</.button></:actions>
      ...
      <:footer>trailing 12 mo</:footer>
    </.card>

    <.card variant="solid" color="primary"><:title>Primary</:title>Faturamento</.card>
    <.card variant="gradient" gradient="sky-blue">...</.card>

The title is `title="text"` or the `<:title>` slot (markup, `class` allowed); `<:title_extra>` goes
beside it (a badge, a counter). With `canvas` the card is the bare tray and its content is the
parts `card_header/1`, `card_body/1` and `card_footer/1`:

    <.card canvas>
      <.card_header>
        <.card_heading level={3}>Profile</.card_heading>
        <.card_actions>...</.card_actions>
      </.card_header>
      <.card_body>...</.card_body>
      <.card_footer>All changes saved</.card_footer>
    </.card>

`navigate`, `patch` or `href` make the whole card a link (a surface), a row that ends in an arrow.
`size` (`xs`/`sm`/`lg`), `shape="xl"` and `padded={false}` act on the surfaces and the tray root.

## Composed cards (`body`)

`body` turns the card into a header / body / footer composition that is sized, tinted and
rounded by the card itself. Without `body` nothing below applies and the markup is the one above.

    <.card variant="default" body="inset" size="md">
      <:title>Profile</:title>
      <:description>Manage your public details.</:description>
      <:actions><.button size="sm" variant="outline">Edit</.button></:actions>
      <.input name="name" />
      <:footer>All changes saved <.button size="sm">Save</.button></:footer>
    </.card>

  * `variant`: `default` (panel + hairline + shadow, a lighter panel with an inner highlight in dark),
    `muted`, `soft` and `filled` (translucent ink tints, so they adapt to the background under the
    card in light and dark), `outline` (border only, transparent). Any other variant renders as `default`.
  * `body`: `seamless` (one surface, no divider), `divided` (hairline under a lightly tinted header),
    `separated` (tinted header and footer bands, body on the panel, dividers), `inset` (the body is an
    inner panel inside the tinted card; its radius is the card's radius minus the gap, so the corners
    are concentric) and `flush` (like `inset` but the body touches the sides and the bottom).
  * `size` (`xs`, `sm`, `md`, `lg`) sets, through the variables `--card-p` (horizontal padding),
    `--card-py`, `--card-r`, `--card-gap` and the type scale, the padding, radius, gap and typography.
    `card_bleed/1` and `card_table`-like content read `--card-p`.
  * `<:description>` goes under the title. `<:actions>` hang into the header padding: the buttons
    are vertically centred on the first line of the heading without making the header taller and
    their distance to the top and to the side edge is the same. Use `size="xs"` buttons in `xs`/`sm`
    cards and `size="sm"` buttons in `md`/`lg` cards (the sizes the hang is computed for);
    `<:actions placement="start">` puts them before the heading.
  * `<:bleed>` is content that fills the body edge to edge (an image) up to the rounded corners
    (concentric with the card when `inset`); the footer keeps its padding.
    `<.table bleed wrapper={false}>` inside a `card_body padded={false}` bleeds a table.
  * `canvas` with `body` keeps the parts (`card_header/1`, `card_body/1`, `card_footer/1`) as the content:
    the card applies the same treatments to them. `card_header` and `card_footer` take `padded={false}` to be
    sub-sections inside a body.

The storage stat is plain composition (the figure and the bar are ordinary markup and `progress/1`):

    <.card body="seamless">
      <:title>Storage</:title>
      <:actions><.button size="sm" variant="ghost" icon="more-h" aria-label="More" /></:actions>
      <p class="m-0 font-display text-3xl font-semibold">32 GB <span class="text-sm font-normal text-muted">of 100 GB</span></p>
      <.progress value={32} class="mt-3" />
    </.card>

## `<.card>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"tray"` | `tray`, `panel`, `default`, `flat`, `canvas`, `page`, `bordered`, `outline`, `muted`, `soft`, `filled`, `solid`, `glow`, `gradient`, `gradient_outline` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg` - Padding of a surface. |
| `color` | `:string` | `"primary"` | `nil`, `primary`, `secondary`, `info`, `success`, `warning`, `error` - Tint of `soft`, `filled`, `solid`, `glow`. |
| `gradient` | `:string` | `"purple-indigo"` | `nil`, `amber-orange`, `fuchsia-pink`, `green-fuchsia`, `purple-indigo`, `sky-blue` |
| `shape` | `:string` | `"rounded"` | `rounded`, `xl` |
| `padded` | `:boolean` | `true` |  |
| `canvas` | `:boolean` | `false` | The bare tray: the content is `card_header/1`, `card_body/1`, `card_footer/1`. |
| `body` | `:string` | `nil` | `nil`, `seamless`, `divided`, `separated`, `inset`, `flush` - Turns on the composed card (see the moduledoc): how header, body and footer relate. `nil` is the card of old. |
| `divider` | `:string` | `"full"` | `full`, `inset` - Reserved (see `body`). |
| `highlight` | `:boolean` | `true` | Reserved (see `body`). |
| `navigate` | `:string` | `nil` |  |
| `patch` | `:string` | `nil` |  |
| `href` | `:string` | `nil` |  |
| `arrow` | `:boolean` | `true` | The chevron of a link card. |
| `body_padded` | `:boolean` | `true` | `false` drops the body panel's 16px padding. |
| `body_class` | `:any` | `nil` | Classes of the body panel (the tray). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `target`, `rel`, `download`, `replace`, `method`.

Slots:

- `<:actions>` - attrs: `placement` - At the end of the header (`placement="start"`: before the heading, composed only).
- `<:bleed>` - Composed cards (`body`): content that fills the body edge to edge (an image).
- `<:description>` - Composed cards (`body`): muted text under the title.
- `<:footer>`
- `<:inner_block>`
- `<:title>` - attrs: `class` - The heading as markup (`title="text"` is the same as text).
- `<:title_extra>` - Beside the title (a badge, a counter).

## `<.card_header>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg`, `xl` - `lg` and `xl` are taller. |
| `padded` | `:boolean` | `true` | `false` drops the padding (a sub-section inside a body). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.card_heading>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `size` | `:string` | `"base"` | `base`, `lg`, `xl` |
| `level` | `:integer` | `2` | `1`, `2`, `3`, `4`, `5`, `6` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.card_subheading>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.card_actions>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.card_body>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `padded` | `:boolean` | `true` | `false` drops the 16px padding (tables, media). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.card_footer>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `align` | `:string` | `nil` | `nil`, `start`, `center`, `end`, `between` |
| `padded` | `:boolean` | `true` | `false` drops the padding (a sub-section inside a body). |
| `size` | `:string` | `nil` | `nil`, `xs`, `sm`, `md`, `lg` - Reserved: no styles in the design. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.card_bleed>`

Content that bleeds to the card's edges (negative margin of the padding `--card-p`, 16px).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
