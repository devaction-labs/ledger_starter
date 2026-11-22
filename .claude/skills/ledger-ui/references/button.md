# LedgerUI.Components.Button

Buttons, styled only with Tailwind utilities: `button/1` (which also covers the icon-only, top bar
(`appearance="topbar"`) and round "go" (`appearance="go"`) buttons), `button_group/1` and
`insight_button/1`.

    <.button>Export report</.button>
    <.button color="primary" variant="soft" size="sm">Save</.button>
    <.button color="error" variant="outline" shape="pill">Delete</.button>
    <.button color="primary" variant="soft" icon="huge-sparkles" aria-label="IA" />
    <.button navigate={~p"/orders"} variant="ghost">Orders</.button>
    <.button color="primary" loading={@saving}>Saving</.button>
    <.button canvas size="sm" appearance="primary">Confirm</.button>
    <.button variant="outline" icon="huge-bell" pip aria-label="Notifications" />

    <.button_group shape="pill">
      <.button variant="outline" size="sm">Day</.button>
      <.button variant="outline" size="sm">Week</.button>
    </.button_group>

    <.button canvas appearance="topbar" icon="notification-03" pip aria-label="Notifications" />
    <.button canvas appearance="go" icon="arrow-right" aria-label="Send" />

The colour enters as four local variables (`--c`, `--c-on`, `--c-soft`, `--c-ink`, see
`LedgerUI.Color`) and each variant only reads those: 10 colours x 9 variants without a
combinatorics of classes. The default `color="neutral" variant="solid"` is the black button of the
system. `color="current"` follows the text colour of the parent.

With `href`, `navigate` or `patch` a link is rendered that looks the same. Without content and with
`icon`, the button is icon-only (`shape="square"`); `icon` also accepts `true` (square button whose
content is the slot, e.g. an inline SVG).

`loading` blocks the button (no double submit) with `disabled` (links: `aria-disabled`) plus
`aria-busy`, hides the label keeping the width and shows a spinner on top. It is not `inert`, so the
spinner's `role="status"` is announced. `pip` puts the notification dot on the corner.

To change a measure pick the matching attr (`size`, `shape`): two utilities of one property in a
class list are resolved by the stylesheet, never by their order, so `class` is for layout
(`w-full`, `ml-auto`), not for overriding the component's own look.

## `<.button>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `color` | `:string` | `"neutral"` | `current`, `dark`, `error`, `info`, `light`, `lime`, `mono`, `neutral`, `primary`, `secondary`, `success`, `warning`, `white` - `current` takes the parent's text colour. |
| `variant` | `:string` | `"solid"` | `bordered`, `dim`, `flat`, `ghost`, `glass`, `glow`, `outline`, `soft`, `solid` |
| `size` | `:string` | `"md"` | `lg`, `md`, `sm`, `xl`, `xs` |
| `shape` | `:string` | `nil` | `nil`, `rounded`, `pill`, `square` - `square` is the icon-only button; without `shape` it is chosen from `icon` and the content. |
| `icon` | `:any` | `nil` | An icon name (`"huge-plus"`, `"plus"`): that icon before the label; without content the button is icon-only. `true`: a square button holding only the slot (pass `aria-label`). |
| `trailing_icon` | `:string` | `nil` | An icon name after the label. |
| `canvas` | `:boolean` | `false` | The compact toolbar button of the canvas: `size` (`sm`/`lg`) and `appearance` apply, `color`, `variant` and `shape` do not. |
| `appearance` | `:string` | `"default"` | `default`, `primary`, `accent`, `soft`, `ghost`, `danger-soft`, `topbar`, `go` - Look of the `canvas` button: `default` (panel with a border), `primary` (the inverse, black button), `accent`, `soft`, `ghost` (no box), `danger-soft`, `topbar` (the 40x40 top bar button) or `go` (the 30px round accent arrow). `topbar` and `go` have a fixed size: `size` is ignored. |
| `part` | `:string` | `"button"` | The `data-part` of the element (`"icon-button"` for the canvas icon buttons). |
| `type` | `:string` | `"button"` |  |
| `disabled` | `:boolean` | `false` |  |
| `loading` | `:boolean` | `false` | Disables the button (no clicks), marks it `aria-busy`, shows a spinner (announced: not `inert`). |
| `pip` | `:boolean` | `false` | The notification dot on the corner. |
| `loading_label` | `:string` | `"Loading"` | Read by screen readers for the spinner. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `target`, `rel`, `replace`, `form`, `name`, `value`.

Slots:

- `<:inner_block>`

## `<.button_group>`

Joins buttons side by side into one segmented control (corners only at the ends).

    <.button_group>
      <.button variant="outline" size="sm">Day</.button>
      <.button variant="soft" size="sm">Month</.button>
    </.button_group>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.insight_button>`

The top bar pill with a count badge (`New AI insights`).

With `href`, `navigate` or `patch` it renders a link (`<.link>`, no `type`) with the same look.
`icon` replaces the count inside the same square box; if `icon` and `count` are both given, `icon`
wins.

    <.insight_button count={3}>New AI insights</.insight_button>
    <.insight_button navigate={~p"/insights"} icon="huge-sparkles">AI suggestions</.insight_button>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `count` | `:any` | `nil` | The number in the square badge. |
| `icon` | `:string` | `nil` | Icon name shown in the badge box instead of the count. Wins over `count`. |
| `type` | `:string` | `"button"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `target`, `rel`, `replace`, `form`, `name`, `value`.

Slots:

- `<:inner_block>` (required)
