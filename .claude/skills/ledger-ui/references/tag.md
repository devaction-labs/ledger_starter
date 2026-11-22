# LedgerUI.Components.Tag

Tags: clickable badges that represent an attribute, a filter or an action.

    <.tag href="#">Default</.tag>
    <.tag navigate={~p"/tags/elixir"} color="primary" shape="pill">Elixir</.tag>
    <.tag color="info" variant="bordered" shape="pill" phx-click="filter">Info</.tag>
    <.tag variant="soft" active={tag in @selected} phx-click="toggle" phx-value-tag={tag}>{tag}</.tag>

    <.tag_group>
      <.tag color="neutral">Primary</.tag>
      <.tag color="primary">55</.tag>
    </.tag_group>

With `href`, `navigate` or `patch` a tag is a link; otherwise a button. `as="span"` (or
`static`) renders a non-interactive `<span>`. `removable` draws the `x` of a removable tag
(give `on_remove` to make it act). With `canvas` the tag is the canvas tag: an optional
colour `swatch` and a remove button. Styled only with Tailwind utilities (the colour enters as
`--c`/`--c-on`/`--c-soft`/`--c-ink`, see `LedgerUI.Color`).

## `<.tag>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `light` |
| `variant` | `:string` | `"solid"` | `solid`, `soft`, `bordered`, `outline`, `flat` |
| `tint` | `:string` | `nil` | A CSS colour of its own; overrides `color`. |
| `active` | `:boolean` | `false` | Selected state of a filter chip. |
| `count` | `:integer` | `nil` | A small pill with this number after the label. |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill`, `square` |
| `as` | `:string` | `nil` | `nil`, `span` |
| `static` | `:boolean` | `false` |  |
| `type` | `:string` | `"button"` |  |
| `removable` | `:boolean` | `false` | Draws the `x` of a removable tag. |
| `on_remove` | `:any` | `nil` | An event name or `JS` command for the `x`. |
| `remove_label` | `:string` | `"Remover"` |  |
| `canvas` | `:boolean` | `false` | The canvas `lu-tag` (swatch + remove button). |
| `swatch` | `:string` | `nil` | A CSS colour for the canvas tag's square. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `name`, `value`, `disabled`.

Slots:

- `<:inner_block>` (required)

## `<.tag_group>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
