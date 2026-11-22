# LedgerUI.Components.DatetimePicker

A date and a time chosen in one panel: a calendar with a list of times beside it or, for a
range, two months side by side with a start and an end time.

    <.datetime_picker field={@form[:starts_at]} label="Starts at" />
    <.datetime_picker name="meeting" interval={15} min="now" min_time="08:00" max_time="18:00" />
    <.datetime_picker name="slot" time="input" unavailable="12:00-13:00, 2026-10-14, 2026-10-15T10:00" />
    <.datetime_picker name="shift" mode="range" default_time="09:00/17:00" locale="pt_BR" />

The value is wall-clock text like a native `datetime-local` input (`2026-10-14T10:30`, no time
zone, no conversion), sent through a hidden input named like the field (a range sends `name[]`
with an empty first one, or two fields with `start_field`/`end_field` or
`start_name`/`end_name`). A bubbling `input` event fires on every change.

The behaviour lives in the `LedgerUI.DatetimePicker` hook
(`priv/static/ledger_ui/hooks/datetime_picker.js`). `datetime_picker_panel/1` renders just the
static panel surface.

## `<.datetime_picker_panel>`

The static panel: a calendar with the list of times beside it.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `month` | `:any` | `nil` |  |
| `selected` | `:any` | `nil` |  |
| `today` | `:any` | `nil` |  |
| `week_start` | `:integer` | `0` |  |
| `locale` | `:string` | `"en"` |  |
| `times` | `:list` | `[]` | The `"HH:MM"` texts of the time buttons. |
| `time` | `:string` | `nil` | The chosen `"HH:MM"`. |
| `timezone` | `:string` | `nil` | A time zone caption over the list of times. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.datetime_picker>`

Renders the date and time input with its panel.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `timezone` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `mode` | `:string` | `"single"` | `single`, `range` |
| `start_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `end_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `start_name` | `:string` | `nil` |  |
| `end_name` | `:string` | `nil` |  |
| `interval` | `:integer` | `30` |  |
| `time` | `:string` | `"list"` | `list`, `input` |
| `default_time` | `:string` | `nil` |  |
| `time_format` | `:string` | `"auto"` | `auto`, `12`, `24` |
| `time_24hr` | `:boolean` | `nil` |  |
| `minute_step` | `:integer` | `nil` |  |
| `default_hour` | `:integer` | `nil` |  |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `display_format` | `:string` | `nil` |  |
| `range_separator` | `:string` | `" – "` |  |
| `min` | `:any` | `nil` |  |
| `max` | `:any` | `nil` |  |
| `min_time` | `:string` | `nil` |  |
| `max_time` | `:string` | `nil` |  |
| `unavailable` | `:any` | `[]` |  |
| `week_start` | `:integer` | `0` |  |
| `months` | `:list` | `nil` |  |
| `weekdays` | `:list` | `nil` |  |
| `today` | `:any` | `nil` |  |
| `labels` | `:map` | `%{}` |  |
| `layout` | `:string` | `"auto"` | `auto`, `compact` |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled` |
| `split` | `:boolean` | `false` |  |
| `date_label` | `:string` | `nil` |  |
| `time_label` | `:string` | `nil` |  |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `placement` | `:string` | `"bottom-start"` | `top`, `bottom`, `left`, `right`, `top-start`, `top-end`, `bottom-start`, `bottom-end`, `left-start`, `left-end`, `right-start`, `right-end` |
| `show_icon` | `:boolean` | `true` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>` - Replaces the calendar icon.
- `<:trigger>` - Replaces the input: any button inside opens the panel.

## `<.date_time_picker>`

Same as `datetime_picker/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `timezone` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `mode` | `:string` | `"single"` | `single`, `range` |
| `start_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `end_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `start_name` | `:string` | `nil` |  |
| `end_name` | `:string` | `nil` |  |
| `interval` | `:integer` | `30` |  |
| `time` | `:string` | `"list"` | `list`, `input` |
| `default_time` | `:string` | `nil` |  |
| `time_format` | `:string` | `"auto"` | `auto`, `12`, `24` |
| `time_24hr` | `:boolean` | `nil` |  |
| `minute_step` | `:integer` | `nil` |  |
| `default_hour` | `:integer` | `nil` |  |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `display_format` | `:string` | `nil` |  |
| `range_separator` | `:string` | `" – "` |  |
| `min` | `:any` | `nil` |  |
| `max` | `:any` | `nil` |  |
| `min_time` | `:string` | `nil` |  |
| `max_time` | `:string` | `nil` |  |
| `unavailable` | `:any` | `[]` |  |
| `week_start` | `:integer` | `0` |  |
| `months` | `:list` | `nil` |  |
| `weekdays` | `:list` | `nil` |  |
| `today` | `:any` | `nil` |  |
| `labels` | `:map` | `%{}` |  |
| `layout` | `:string` | `"auto"` | `auto`, `compact` |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled` |
| `split` | `:boolean` | `false` |  |
| `date_label` | `:string` | `nil` |  |
| `time_label` | `:string` | `nil` |  |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `placement` | `:string` | `"bottom-start"` | `top`, `bottom`, `left`, `right`, `top-start`, `top-end`, `bottom-start`, `bottom-end`, `left-start`, `left-end`, `right-start`, `right-end` |
| `show_icon` | `:boolean` | `true` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>` - Replaces the calendar icon.
- `<:trigger>` - Replaces the input: any button inside opens the panel.
