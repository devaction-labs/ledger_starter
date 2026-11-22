# LedgerUI.Components.Progress

Progress bar (`progress/1`) and the stacked bar of parts of a total (`progress_stack/1`). Styled
only with Tailwind utilities (the colour enters as `--c`/`--c-on`, see `LedgerUI.Color`).

    <.progress value={64} color="primary" />
    <.progress value={92} size="xl" label="92%" />
    <.progress indeterminate color="info" />
    <.progress_stack label="Sales by channel">
      <:segment value={46} label="Counter" />
      <:segment value={33} label="Online" />
    </.progress_stack>
    <.progress_ring value={64} />

`variant` and `size` default to the solid, 8px bar. `label` is the accessible name
(`role="progressbar"`, with `aria-valuenow`); with `size="xl"` it is drawn inside the bar
instead. `active` runs stripes over the bar, `indeterminate` slides it, with `shine` it is a
light that passes; `loop` fills the bar and empties it again (`mo-fillw`, CSS only).

## `<.progress>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `value` | `:any` | `0` | A number between 0 and `max`. |
| `max` | `:any` | `100` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `white` |
| `variant` | `:string` | `nil` | `nil`, `solid`, `soft`, `gradient` |
| `size` | `:string` | `nil` | `nil`, `sm`, `md`, `lg`, `xl` |
| `height` | `:string` | `nil` | `nil`, ``, `1`, `1.5`, `2`, `3`, `4` |
| `active` | `:boolean` | `false` |  |
| `indeterminate` | `:boolean` | `false` |  |
| `shine` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | The canvas loop (`mo-fillw`): the bar fills up to `value`, then empties, forever (demos). |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `bar_class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.progress_stack>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `max` | `:any` | `100` |  |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:segment>` (required) - attrs: `value`, `color`, `label`

## `<.progress_bar>`

Same as `progress/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `value` | `:any` | `0` | A number between 0 and `max`. |
| `max` | `:any` | `100` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `white` |
| `variant` | `:string` | `nil` | `nil`, `solid`, `soft`, `gradient` |
| `size` | `:string` | `nil` | `nil`, `sm`, `md`, `lg`, `xl` |
| `height` | `:string` | `nil` | `nil`, ``, `1`, `1.5`, `2`, `3`, `4` |
| `active` | `:boolean` | `false` |  |
| `indeterminate` | `:boolean` | `false` |  |
| `shine` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` |  |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `bar_class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.progress_ring>`

Circular progress: a conic arc around a hole with the value in the centre.

    <.progress_ring value={64} />
    <.progress_ring value={3} max={4} label="3/4" color="success" size="lg" />

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `value` | `:any` | `0` | A number between 0 and `max`. |
| `max` | `:any` | `100` |  |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` - Ring diameter: 40, 56 or 72px. |
| `color` | `:string` | `nil` | `nil`, `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `white` - Colour of the arc; `nil` is the accent. |
| `label` | `:string` | `nil` | Text in the centre. Defaults to the percentage; `""` leaves the centre empty. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
