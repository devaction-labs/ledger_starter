# LedgerUI.Components.Badge

Badges: `color` x `variant` x `size` x `shape`, with a dot, an icon or a remove button. Styled only
with Tailwind utilities (the colour enters as `--c`/`--c-on`/`--c-soft`/`--c-ink`, see
`LedgerUI.Color`).

    <.badge>Default</.badge>
    <.badge color="success" shape="pill">Paid</.badge>
    <.badge color="primary" variant="outline" icon="huge-sparkles">3 new</.badge>
    <.badge color="primary" variant="soft" dot>Online</.badge>
    <.badge on_remove={JS.hide()}>Filter</.badge>

With `canvas` the badge is the compact canvas badge (tinted by `color`: `primary`, `success`,
`error`, `warning`, `info`, `lime`; `variant` `solid`/`outline`; `size` `sm`/`lg`), which is what tables
and KPI rows use.

## `<.badge>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `color` | `:string` | `"neutral"` | `current`, `dark`, `error`, `info`, `light`, `lime`, `mono`, `neutral`, `primary`, `secondary`, `success`, `warning`, `white` |
| `variant` | `:string` | `"soft"` | `bordered`, `flat`, `glow`, `outline`, `soft`, `solid` |
| `size` | `:string` | `"md"` | `lg`, `md`, `sm`, `xl`, `xs` |
| `shape` | `:string` | `"rounded"` | `pill`, `rounded`, `square` |
| `icon` | `:string` | `nil` | An icon name before the content. |
| `dot` | `:any` | `false` | A dot before the content; `"live"` pulses. |
| `canvas` | `:boolean` | `false` | The compact canvas badge. |
| `on_remove` | `:any` | `nil` | An event name or a `JS` command: adds a remove button after the content. |
| `id` | `:string` | `nil` |  |
| `target` | `:any` | `nil` | The `phx-target` of `on_remove` when it is an event. |
| `remove_label` | `:string` | `"Remove"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.count>`

The little counter box (18px, rounded 5px) for unread items and pending work.

    <.count>23</.count>
    <.count tone="warning">8</.count>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `tone` | `:string` | `"error"` | `error`, `info`, `primary`, `success`, `warning` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.delta>`

A variation with its arrow: `up` or `down`, green or red by meaning.

    <.delta trend="up">8.8%</.delta>
    <.delta trend="up" tone="error">0.4 pts</.delta>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `trend` | `:string` | `"up"` | `up`, `down` |
| `tone` | `:string` | `nil` | `nil`, `error`, `neutral`, `success` - The colour: `success` (green), `error` (red) or `neutral`. Defaults to green for `up` and red for `down`. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
