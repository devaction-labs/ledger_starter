# LedgerUI.Components.Range

Range slider: a rounded track with a round thumb, one value or a range of two.

    <.range name="volume" value={50} color="primary" />
    <.range field={@form[:level]} label="Level" min={0} max={10} size="lg" show_value />
    <.range name="discount" label="Desconto" value={12} max={30} show_value value_format="%{value}%" />
    <.range start_name="from" end_name="to" value={{40, 280}} min={0} max={500} />
    <.range name="weight" orientation="vertical" value={40} />

The slider is a track, a fill and one or two thumbs, positioned by the custom properties
`--lu-sp` (the value, in %) and `--lu-rlo` (the lower value of a pair). The
`LedgerUI.Range` hook (`priv/static/ledger_ui/hooks/range.js`) drags the thumbs, takes the
arrow keys, Home, End and Page Up/Down (it adds `role="slider"` and the ARIA values to the
thumbs), keeps the value text, the fill and the marks in step, and writes the value to hidden
inputs named like the field, firing a bubbling `input` event so `phx-change` runs.

Deviations from the README: `color` has no default (no `c-*` class, the neutral look) and
`filled` defaults to `true` (`filled={false}` is the design's "sem filled"); the value is not a
native `<input type="range">` but hidden inputs.

## `<.range>`

Renders a range slider.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `min` | `:any` | `0` |  |
| `max` | `:any` | `100` |  |
| `step` | `:any` | `1` |  |
| `color` | `:string` | `nil` | `nil`, `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `fill` | `:string` | `nil` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `classic` |
| `start_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `end_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `start_name` | `:string` | `nil` |  |
| `end_name` | `:string` | `nil` |  |
| `orientation` | `:string` | `"horizontal"` | `horizontal`, `vertical` |
| `height` | `:string` | `nil` | Height of a vertical slider (112px, the design's 8rem, by default). |
| `filled` | `:boolean` | `true` |  |
| `loop` | `:boolean` | `false` | The canvas demo animation: the value runs along the track (`--lu-sp` over 5s) and the thumb "grabs" it. The value in the hidden input stays. |
| `show_value` | `:boolean` | `false` |  |
| `value_format` | `:string` | `"%{value}"` |  |
| `marks` | `:list` | `[]` |  |
| `steppers` | `:boolean` | `false` |  |
| `decrease_label` | `:string` | `nil` |  |
| `increase_label` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.range_slider>`

Same as `range/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `min` | `:any` | `0` |  |
| `max` | `:any` | `100` |  |
| `step` | `:any` | `1` |  |
| `color` | `:string` | `nil` | `nil`, `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `fill` | `:string` | `nil` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `classic` |
| `start_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `end_field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `start_name` | `:string` | `nil` |  |
| `end_name` | `:string` | `nil` |  |
| `orientation` | `:string` | `"horizontal"` | `horizontal`, `vertical` |
| `height` | `:string` | `nil` |  |
| `filled` | `:boolean` | `true` |  |
| `loop` | `:boolean` | `false` |  |
| `show_value` | `:boolean` | `false` |  |
| `value_format` | `:string` | `"%{value}"` |  |
| `marks` | `:list` | `[]` |  |
| `steppers` | `:boolean` | `false` |  |
| `decrease_label` | `:string` | `nil` |  |
| `increase_label` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.
