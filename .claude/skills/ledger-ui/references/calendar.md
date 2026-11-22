# LedgerUI.Components.Calendar

A calendar for dates that matter (due dates, appointments, deadlines): a month grid or a week
grid of hours with colored event chips, month/week switching and keyboard navigation; plus
`due_calendar/1`, the agenda of due items by day.

    <.calendar id="due" view={@view} date={@date} events={@events} locale="pt_BR"
      on_navigate="calendar_navigate" on_view="calendar_view"
      on_select="calendar_select" on_event="calendar_event" />

The server owns what the calendar shows: `view` and `date` come from your assigns, and the
toolbar and the keyboard push `on_navigate` (`%{"id", "date", "view"}`), `on_view`,
`on_select` (`%{"id", "date"}`) and `on_event` (`%{"id", "event", "date"}`). Load the events of
a period with `calendar_range/3`.

An event is a map with `:date` and `:title`, and optionally `:id`, `:subtitle`, `:color`
(`neutral primary secondary info success warning error`), `:start` and `:end` (`"09:00"` or a
`Time`).

`variant="mini"` is the compact month in a card (round cells, a dot or a tint on the days
that have events); `size` is `sm`, `md` or `lg`, and `view="week"` draws only the week of
`date` (the weekday letters and one row, a strip). `view="day"` is the week grid with a single day, an addition to the README.

The roving focus and the arrow keys live in the `LedgerUI.Calendar` hook
(`priv/static/ledger_ui/hooks/calendar.js`), attached only when `on_select` is set.

## `<.calendar>`

Renders the calendar.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `view` | `:string` | `"month"` | `month`, `week`, `day` |
| `variant` | `:string` | `"full"` | `full`, `mini` |
| `range` | `:any` | `nil` |  |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` - `variant="mini"` only: the cell size, 28x26 / 34x32 / 42x40px with 12 / 13 / 14px digits. |
| `loop` | `:string` | `nil` | `nil`, `pick`, `range` - `variant="mini"` only: the canvas demo animation, each day lighting up in turn as the picked day (`pick`) or the picked range (`range`). |
| `marks` | `:string` | `"dot"` | `dot`, `tint` |
| `months_shown` | `:integer` | `1` |  |
| `date` | `:any` | `nil` | A date of the month (or week, day) shown; today by default. |
| `month` | `:any` | `nil` | The same as `date`. |
| `today` | `:any` | `nil` |  |
| `selected` | `:any` | `nil` |  |
| `events` | `:list` | `[]` |  |
| `legend` | `:list` | `[]` |  |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `months` | `:list` | `nil` |  |
| `weekdays` | `:list` | `nil` |  |
| `labels` | `:map` | `%{}` |  |
| `week_start` | `:integer` | `0` |  |
| `show_weekends` | `:boolean` | `true` |  |
| `day_start` | `:integer` | `8` |  |
| `day_end` | `:integer` | `18` |  |
| `max_events` | `:integer` | `3` |  |
| `header` | `:boolean` | `true` |  |
| `outside_days` | `:boolean` | `false` |  |
| `day_id` | `:any` | `nil` |  |
| `interactive_marked_only` | `:boolean` | `false` |  |
| `card` | `:boolean` | `true` |  |
| `on_navigate` | `:string` | `nil` |  |
| `on_view` | `:string` | `nil` |  |
| `on_select` | `:string` | `nil` |  |
| `on_event` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:event>` - Replaces the content of an event chip or block; receives the event map.

## `<.due_calendar>`

The agenda of due items, one row per item: the weekday and day, the title, a status badge
(overdue in `neg`, today highlighted) and the amount on the right.

    <.due_calendar items={@invoices} today={~D[2026-11-19]} locale="pt_BR" currency="R$ " />

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `items` | `:list` | `[]` | Maps with `:date`, `:title`, `:subtitle`, `:amount` (text or number) and optionally `:status` (`overdue`, `today`, `scheduled`) and `:status_label`. |
| `today` | `:any` | `nil` |  |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `currency` | `:string` | `""` | Prefix of numeric amounts (`"R$ "`). |
| `amount_width` | `:integer` | `80` |  |
| `animated` | `:boolean` | `false` | Staged demo (`mo-stg`): rows enter with a `--dl` delay, the overdue badge blinks, weekdays are lowercase and today's badge is `warn`. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
