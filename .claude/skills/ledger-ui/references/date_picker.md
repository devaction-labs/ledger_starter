# LedgerUI.Components.DatePicker

Date picker: one date, several dates or a range, with limits, disabled days, a custom
text format and presets. The calendar pops under the input or stays inline.

    <.date_picker field={@form[:due_on]} placeholder="Choose date..." />
    <.date_picker name="trip" mode="range" value={{~D[2026-10-10], ~D[2026-10-20]}} />
    <.date_picker name="days" mode="multiple" disabled_weekdays={[0, 6]} week_start={1} />
    <.date_picker start_field={@form[:from]} end_field={@form[:to]} locale="pt_BR"
      presets={[{"Este mês", "this_month"}, {"Mês passado", "last_month"}]} />

The input shows the date in `display_format` (flatpickr tokens `Y y m n d j F M l D`); the
form gets ISO text through hidden inputs named like the field (`name` for one date,
`name[]` for `multiple` and `range`, with an empty `name[]` first). A pick fires a
bubbling `input` event, so `phx-change` runs.

The behaviour lives in the `LedgerUI.DatePicker` hook (`priv/static/ledger_ui/hooks/date_picker.js`).
The popup is an overlay: `LedgerUI.open/close/toggle("id-pop")` is not needed, the hook
opens it; `date_picker_clear/1` empties the picker.

`date_picker_panel/1` renders just the calendar surface (a popover with the month), the markup
the popup is made of.

## `<.date_picker_panel>`

The calendar surface of the picker: month title with arrows, weekday letters and the days,
optionally with a column of `presets` on the left.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `month` | `:any` | `nil` | A `Date` of the month to show (today's month by default). |
| `selected` | `:any` | `nil` | A date or a list of dates drawn as selected. |
| `range` | `:any` | `nil` | `{from, to}`: painted as a continuous band. |
| `today` | `:any` | `nil` |  |
| `min` | `:any` | `nil` |  |
| `max` | `:any` | `nil` |  |
| `disabled_dates` | `:list` | `[]` |  |
| `disabled_weekdays` | `:list` | `[]` |  |
| `week_start` | `:integer` | `0` |  |
| `locale` | `:string` | `"en"` |  |
| `months` | `:list` | `nil` |  |
| `weekdays` | `:list` | `nil` |  |
| `labels` | `:map` | `%{}` |  |
| `presets` | `:list` | `[]` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.date_picker_calendar>`

The month: title, arrows, weekday letters and day buttons.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `month` | `:any` | `nil` |  |
| `selected` | `:any` | `nil` |  |
| `range` | `:any` | `nil` |  |
| `today` | `:any` | `nil` |  |
| `min` | `:any` | `nil` |  |
| `max` | `:any` | `nil` |  |
| `disabled_dates` | `:list` | `[]` |  |
| `disabled_weekdays` | `:list` | `[]` |  |
| `week_start` | `:integer` | `0` |  |
| `locale` | `:string` | `"en"` |  |
| `months` | `:list` | `nil` |  |
| `weekdays` | `:list` | `nil` |  |
| `labels` | `:map` | `%{}` |  |

Any other HTML/phx attribute goes to the root element.

## `<.date_picker>`

Renders a date input with its calendar.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `mode` | `:string` | `"single"` | `single`, `multiple`, `range` |
| `range` | `:boolean` | `false` | The same as `mode="range"`. |
| `start_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `end_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `start_name` | `:string` | `nil` |  |
| `end_name` | `:string` | `nil` |  |
| `presets` | `:list` | `[]` |  |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `range_separator` | `:string` | `nil` |  |
| `labels` | `:map` | `%{}` |  |
| `min` | `:any` | `nil` |  |
| `max` | `:any` | `nil` |  |
| `disabled_dates` | `:list` | `[]` |  |
| `disabled_weekdays` | `:list` | `[]` |  |
| `week_start` | `:integer` | `0` |  |
| `display_format` | `:string` | `nil` |  |
| `months` | `:list` | `nil` |  |
| `weekdays` | `:list` | `nil` |  |
| `today` | `:any` | `nil` |  |
| `inline` | `:boolean` | `false` |  |
| `show_icon` | `:boolean` | `true` |  |
| `skin` | `:string` | `nil` | `nil`, ``, `linea` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>` - Replaces the calendar icon.
- `<:trailing>` - Buttons joined to the right of the input.
