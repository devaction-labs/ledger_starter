# LedgerUI.Components.TimePicker

Time picker: an input with a clock icon that opens a scrollable list of times
(`variant="input"`), or a list of fixed slots (`variant="list"`).

    <.time_picker field={@form[:opens_at]} placeholder="Choose time..." />
    <.time_picker name="alarm" time_24hr min_time="15:00" max_time="22:30" minute_step={15} />
    <.time_picker field={@form[:slot]} variant="list" min_time="14:00" max_time="14:45" minute_step={15} />

The form gets `"HH:MM"` (24-hour) through a hidden input named like the field and every change
fires a bubbling `input` event, so `phx-change` runs. The behaviour lives in the
`LedgerUI.TimePicker` hook (`priv/static/ledger_ui/hooks/time_picker.js`).

`time_picker_panel/1` renders only the popup surface (a popover with the list of times), or with
`variant="bare"` the plain list of the canvas (no box, 110px wide, mono 13px, 32px rows) that
`loop` scrolls up and down.

## `<.time_picker_panel>`

The popup surface: a popover with the list of times (or, `variant="bare"`, the plain list).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `times` | `:list` | `[]` | The `"HH:MM"` texts of the buttons. |
| `value` | `:any` | `nil` | The chosen time (`"HH:MM"`) highlighted. |
| `variant` | `:string` | `"popover"` | `popover`, `bare` - `popover` is the box of the popup; `bare` the plain 110px list, with no box or hover. |
| `loop` | `:boolean` | `false` | `variant="bare"`: the canvas demo, the list scrolling down and back (8s). |
| `height` | `:integer` | `180` | `variant="bare"`: the height of the list, in px. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.time_picker>`

Renders a time input.

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
| `time_24hr` | `:boolean` | `false` |  |
| `min_time` | `:string` | `nil` |  |
| `max_time` | `:string` | `nil` |  |
| `minute_step` | `:integer` | `5` |  |
| `step` | `:integer` | `nil` | The same as `minute_step`; it wins when given. |
| `hour_step` | `:integer` | `1` |  |
| `default_hour` | `:integer` | `12` |  |
| `display_format` | `:string` | `nil` |  |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `labels` | `:map` | `%{}` |  |
| `variant` | `:string` | `"input"` | `input`, `list` |
| `show_icon` | `:boolean` | `true` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>` - Replaces the clock icon.
- `<:trailing>` - Buttons joined to the right of the input.
