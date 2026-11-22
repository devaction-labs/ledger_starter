# LedgerUI.Components.NumberInput

A numeric field for money and quantities that shows the number the way the person's locale
writes it (`1.234,56` in pt-BR, `1,234.56` in en) and submits the plain machine value
(`1234.56`).

    <.number_input field={@form[:price]} label="Price" prefix="R$" decimals={2} min={0} />
    <.number_input field={@form[:quantity]} label="Quantity" steppers min={1} step={1} suffix="un" />
    <.number_input name="qty" value={3} steppers stepper_style="round" min={0} />

The control is the design's number box: the number is a `span[data-part=number-value]` that the `LedgerUI.NumberInput`
hook (`priv/static/ledger_ui/hooks/number_input.js`) makes editable (`contenteditable`,
`role="spinbutton"`); a hidden input named like the field carries the machine value and fires a
bubbling `input` event when it changes, so a surrounding `phx-change` runs. Typing keeps what
the person writes; leaving the field clamps to `min`/`max`, rounds to `decimals`/`max_decimals`
and writes it grouped. Arrow up/down (and the steppers) move by `step`, Page up/down by ten
steps. The steppers are disabled at `min` and `max` by the hook.

Deviations from the README: `align` defaults to `"center"` (the design's value), and the
accessible names of the steppers default to the `locale`'s (`Diminuir`/`Aumentar` in pt-BR).

## `<.number_input>`

Renders the number input.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`: the separators and the labels. Default: the process locale, the app config, `"pt_BR"`. |
| `decimal_separator` | `:string` | `nil` |  |
| `thousands_separator` | `:string` | `nil` |  |
| `decimals` | `:integer` | `nil` |  |
| `max_decimals` | `:integer` | `nil` |  |
| `min` | `:any` | `nil` |  |
| `max` | `:any` | `nil` |  |
| `step` | `:any` | `1` |  |
| `steppers` | `:boolean` | `false` |  |
| `stepper_style` | `:string` | `"inset"` | `inset`, `round`, `joined` |
| `decrement_label` | `:string` | `nil` |  |
| `increment_label` | `:string` | `nil` |  |
| `prefix` | `:string` | `nil` |  |
| `suffix` | `:string` | `nil` |  |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `align` | `:string` | `"center"` | `left`, `right`, `center` |
| `wrapper_class` | `:any` | `nil` |  |
| `canvas` | `:boolean` | `false` | The block of the canvas app templates: a `div` with 14px icons (otherwise a `span`). |
| `loop` | `:boolean` | `false` | Demo animation (CSS only): the number counts 1 to 5 and back while the + button is pressed. The text is drawn by a counter, so `value` is not shown. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.number_stepper>`

Same as `number_input/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`: the separators and the labels. Default: the process locale, the app config, `"pt_BR"`. |
| `decimal_separator` | `:string` | `nil` |  |
| `thousands_separator` | `:string` | `nil` |  |
| `decimals` | `:integer` | `nil` |  |
| `max_decimals` | `:integer` | `nil` |  |
| `min` | `:any` | `nil` |  |
| `max` | `:any` | `nil` |  |
| `step` | `:any` | `1` |  |
| `steppers` | `:boolean` | `false` |  |
| `stepper_style` | `:string` | `"inset"` | `inset`, `round`, `joined` |
| `decrement_label` | `:string` | `nil` |  |
| `increment_label` | `:string` | `nil` |  |
| `prefix` | `:string` | `nil` |  |
| `suffix` | `:string` | `nil` |  |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `align` | `:string` | `"center"` | `left`, `right`, `center` |
| `wrapper_class` | `:any` | `nil` |  |
| `canvas` | `:boolean` | `false` | The block of the canvas app templates: a `div` with 14px icons (otherwise a `span`). |
| `loop` | `:boolean` | `false` | Demo animation (CSS only): the number counts 1 to 5 and back while the + button is pressed. The text is drawn by a counter, so `value` is not shown. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
