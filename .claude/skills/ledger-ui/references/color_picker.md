# LedgerUI.Components.ColorPicker

A color picker that outputs hex text: a saturation/brightness area to drag, a hue slider, an
optional opacity slider, a hex field and a row of preset swatches.

    <.color_picker field={@form[:color]} label="Stage color" />
    <.color_picker name="tag" value="#4C3FE0" presets={~w(#EB3B2F #F5A214 #18996E)} />
    <.color_picker field={@form[:overlay]} alpha locale="pt_BR" />
    <.color_picker name="brand" variant="swatches" hex_field presets={~w(#0D8F91 #2F5FD0 #8A5CD6)} />

The form gets `#6366F1` (upper case, `#RRGGBB`; with `alpha` a translucent color is
`#RRGGBBAA`) through a hidden input named like the field; every change fires a bubbling
`input` event from it, so `phx-change` runs. The behaviour lives in the `LedgerUI.ColorPicker`
hook (`priv/static/ledger_ui/hooks/color_picker.js`), so the picker needs a stable `id`.

`variant="compact"` is the bare canvas picker (a 220px saturation/brightness area of 120px and
the hue bar, nothing else); `variant="row"` is a wrapping flex row of swatches, sized by
`swatch_size` (`sm` 20px, default 26px, `lg` 34px). `loop` runs their canvas demo animation
(the compact area's marker wandering, or the row sliding in while the selection walks across the swatches).

`popover` draws the picker on a popover surface (300px), as in the reference of the
design; otherwise the picker has no surface of its own.

## `<.color_picker>`

Renders the color picker.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `default` | `:string` | `"#4C3FE0"` |  |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `alpha` | `:boolean` | `false` |  |
| `presets` | `:list` | `["#4C3FE0", "#2763E6", "#1693CC", "#18996E", "#31A35B", "#F5A214", "#F06B0C", "#EB3B2F", "#DB428F", "#606A78"]` |  |
| `swatches` | `:list` | `nil` | The same as `presets`; it wins when given. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |
| `labels` | `:map` | `%{}` |  |
| `variant` | `:string` | `"full"` | `full`, `compact`, `swatches`, `row` - `swatches` is the 8-column grid under no picker; `row` a wrapping row of swatches (20/26/34px); `compact` the 220px area and hue bar. |
| `loop` | `:boolean` | `false` | `compact` / `row`: the canvas demo animation (marker moving / selection walking). |
| `hex_field` | `:boolean` | `false` |  |
| `hex_label` | `:any` | `:default` |  |
| `swatch_size` | `:string` | `nil` | `nil`, ``, `sm`, `md`, `lg` |
| `popover` | `:boolean` | `false` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
