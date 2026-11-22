# LedgerUI.Components.KpiCard

Indicator card: a big tabular figure, its unit in `subtle` and a coloured delta in the footer.

    <.kpi_card label="MRR" value="184,320" prefix="$" delta="8.8%" compare="vs $169,460 in Sep"
      live spark={@mrr_series} open_label="Open" on_open="open_report" />

    <.kpi_card label="Churn rate" value="2.1" unit="%" delta="0.4 pts" trend="up" delta_tone="error" />

The colour of the delta follows the meaning, not the direction: churn going up is `error`
(a red arrow pointing up). `trend` draws the arrow (`up`, `down`, `flat`), `delta_tone` colours it
and defaults from `trend` (up `success`, down `error`, flat `neutral`).

## Variants

  * `canvas` (default): the reference card. The sparkline sits at the right (`spark`), the delta is
    a coloured figure with a small triangle and the arrow an icon.
  * `badge`: the compact card of the dashboards, with the delta in a badge and the arrow as a
    glyph (`↗`, `↘`, `→`); pair it with `count` for a figure that counts up (CSS only).

With an `<:icon>`, `layout="stack"` puts the icon chip before the label and `"inline"` puts it
beside the label and the figure.

The sparkline is drawn on the server (see `LedgerUI.Components.Sparkline`). The gradient of its
fill takes its id from `id` (derived from the card's content when not given). Styled only with
Tailwind utilities; the figure fades in once on mount.

`color` is kept for the API of the canvas; the card follows the accent (its arrow, sparkline and
round button), as the design does.

## `<.kpi_card>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `value` | `:string` | `nil` | The figure, already formatted. |
| `prefix` | `:string` | `nil` | A small prefix before the figure (`$`, `R$`). |
| `unit` | `:string` | `nil` | A smaller suffix beside the figure (`mil`, `%`, `dias`). |
| `delta` | `:string` | `nil` | The change since the last period, already formatted. |
| `compare` | `:string` | `nil` | What the change is measured against (`vs Sep`). |
| `trend` | `:string` | `"up"` | `up`, `down`, `flat` |
| `delta_tone` | `:string` | `nil` | `nil`, `success`, `error`, `neutral` |
| `spark` | `:list` | `[]` | Numbers for the sparkline. |
| `color` | `:string` | `"primary"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` - Kept for the canvas API; the card always follows the accent. |
| `variant` | `:string` | `"canvas"` | `canvas`, `badge` |
| `layout` | `:string` | `"inline"` | `stack`, `inline` |
| `count` | `:integer` | `nil` | `badge` variant: the figure counts up to this number, in CSS. |
| `progress` | `:integer` | `nil` | 0 to 100: a meter under the figure, in place of the sparkline. |
| `caption` | `:string` | `nil` | A faint line under the figure or the meter. |
| `icon_tone` | `:string` | `"acc"` | `acc`, `pos`, `neg`, `warn`, `info` |
| `value_id` | `:string` | `nil` | The `id` of the figure element. |
| `gap` | `:boolean` | `true` |  |
| `loading` | `:boolean` | `false` |  |
| `live` | `:boolean` | `false` | A `Live` chip beside the label. |
| `live_label` | `:string` | `nil` |  |
| `open_label` | `:string` | `nil` | `aria-label` of the round button at the footer's right; no button without it. |
| `on_open` | `:any` | `nil` | Event name or `%JS{}` of the round button. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:footer>` - A link or caption in the card's footer, after the delta and the comparison.
- `<:icon>` - An icon shown in a tinted chip before the label.
