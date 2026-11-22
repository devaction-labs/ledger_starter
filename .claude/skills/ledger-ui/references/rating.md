# LedgerUI.Components.Rating

A star rating: read-only, with a fractional value and the count of reviews, or interactive, as
a group of native radios; and `rating_distribution/1`, the summary with the average and a bar
per grade.

    <.rating value={4.5} />
    <.rating value={4.2} show_value count={38} />
    <.rating id="service" name="service" label="Como foi o atendimento?" value={@grade} on_change="rate" />
    <.rating field={@form[:grade]} label="Nota" />
    <.rating_distribution average={4.5} counts={[800, 310, 110, 40, 24]} />

A fractional value is drawn in half stars (the nearest half). The read-only rating is one
`role="img"` with the text `4,5 de 5 estrelas` (`aria_label` gives another).

Interactive ratings are a `radiogroup` of `max` native radios (Tab enters the group, the arrow
keys choose, the form submits `name`). `on_change` is an event name (pushed with
`%{"id", "value"}`, to `target` when given) or a `%JS{}`. The `LedgerUI.Rating` hook
(`priv/static/ledger_ui/hooks/rating.js`) previews the grade under the pointer.

## `<.rating>`

Renders a rating.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `max` | `:integer` | `5` |  |
| `variant` | `:string` | `"solid"` | `solid`, `outline` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `count` | `:integer` | `nil` |  |
| `show_value` | `:boolean` | `false` |  |
| `decimal` | `:string` | `","` |  |
| `interactive` | `:boolean` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `aria_label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | Animated demo: every star lights up in turn (read-only, no on/off state). |
| `on_change` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.rating_distribution>`

The summary of a rating: the average, its stars, the total and a bar per grade.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `counts` (required) | `:any` |  | A list, best grade first, or a map `%{grade => count}`. |
| `average` | `:any` | `nil` |  |
| `total` | `:integer` | `nil` |  |
| `unit` | `:string` | `nil` |  |
| `decimal` | `:string` | `","` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.
