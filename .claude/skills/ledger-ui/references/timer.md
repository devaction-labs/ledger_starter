# LedgerUI.Components.Timer

A timer that ticks in the browser: a ring with the time in the middle (a shift, a countdown, any
stretch of time) and a small pill of it for a top bar.

    <.timer id="shift" elapsed={@shift_seconds} running={@running} kicker="Register open"
      kicker_paused="Paused" label="Register 01" on_toggle="shift_toggled">
      <:actions>
        <button phx-click={LedgerUI.Timer.toggle("shift")}>Pause</button>
        <button phx-click={LedgerUI.Timer.add("shift", 900)}>+15 min</button>
      </:actions>
    </.timer>

    <.timer id="break" direction="down" total={900} elapsed={0} color="warning" on_finish="break_over" />
    <.timer id="mini" variant="mini" elapsed={@seconds} running={@running} label="Shift time" />

The server owns the time (`elapsed`, `running`, `total`, `direction`); the `LedgerUI.Timer`
hook counts from there on a monotonic clock with no round trip, and a new value from the server
replaces what the browser counted. `format` is `hms` (`03:12:45`), `hm` (`3h12`), `hh:mm` or `mm:ss` (`192:45`).

The timer is `role="timer"` named by `label`; the ticking text is not a live region. `color`
is the ring while it runs (nothing is added by default); paused is always warning (the hook flips
`data-state` between `running` and `paused`). Styled only with Tailwind utilities.

Events (`on_toggle`, `on_tick`, `on_finish`) take an event name or a `%JS{}` and go to `target`.
Browser commands live in `LedgerUI.Timer` (`pause/1`, `resume/1`, `toggle/1`, `add/2`, and the
`socket` versions to push them from the server).

## `<.timer>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `elapsed` | `:integer` | `0` |  |
| `total` | `:integer` | `28800` |  |
| `seconds` | `:integer` | `nil` | The same as `total` (`seconds={600}` with `direction="down"` is a ten minute countdown). |
| `running` | `:boolean` | `true` |  |
| `direction` | `:string` | `"up"` | `up`, `down` |
| `variant` | `:string` | `"ring"` | `ring`, `mini` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `color` | `:string` | `nil` | `nil`, `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `format` | `:string` | `"auto"` | `auto`, `hms`, `hm`, `hh:mm`, `mm:ss` |
| `kicker` | `:string` | `nil` |  |
| `kicker_paused` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `stop_at_total` | `:boolean` | `false` |  |
| `demo` | `:boolean` | `false` | The canvas CSS loop, no hook (a `mini` just stays still, with its dot): the ring fills (`up`) or empties (`down`) in 10s and the time counts `00:00`..`00:10` with a CSS counter (`mo-tup`/`mo-tdown`). For showcases. |
| `on_toggle` | `:any` | `nil` |  |
| `on_tick` | `:any` | `nil` |  |
| `on_finish` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - The controls under the ring (`ring` only).
- `<:caption>` - Replaces the `label` line under the time (`ring` only).
- `<:inner_block>` - `mini`: text after the time (a note on a static sample, ` · hms`).
