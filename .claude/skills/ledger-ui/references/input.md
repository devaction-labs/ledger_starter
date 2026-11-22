# LedgerUI.Components.Input

Single-line text field styled only with Tailwind utilities: `outlined`, `filled` or `plain`,
`rounded` or `pill`, three sizes, icon, prefix and suffix, states, masks.

    <.input field={@form[:name]} label="Nome" />
    <.input field={@form[:total]} align="right" label="Total" prefix="R$" suffix="BRL" />
    <.input field={@form[:email]} type="email" variant="filled" size="lg" state="success" help="E-mail verificado" />
    <.input field={@form[:q]} shape="pill" layout="inline" label="Buscar" label_hint="opcional" />

`field={@form[:name]}` fills `id`, `name`, `value` and `errors`. With errors the help line shows
the messages and the box turns red.

## Masks

`mask` formats what is typed (hook `LedgerUI.InputMask`, which needs a stable `id`; it comes
from `field`):

    <.input name="doc" mask="cpf_cnpj" label="CPF ou CNPJ" mask_submit="raw" />
    <.input name="amount" mask="numeral" mask_options={%{thousands: "lakh"}} />
    <.input name="code" mask="blocks" mask_options={%{blocks: [3, 2, 3], delimiter: "-", uppercase: true}} />

| mask | options |
|---|---|
| `blocks` | `blocks`, `delimiter`, `delimiters`, `prefix`, `uppercase`, `lowercase`, `numeric` |
| `credit_card` | `delimiter` |
| `date` | `pattern` (`~w(d m Y)`), `delimiter` |
| `time` | `pattern` (`~w(h m s)`), `delimiter` |
| `phone` | `blocks`, `delimiter` |
| `cpf_cnpj` | none |
| `numeral` | `thousands`, `decimals`, `delimiter`, `decimal_mark`, `positive`, `prefix` |

The input submits the masked text; `mask_submit="raw"` submits the unmasked value through a
hidden input that carries the field's name.

## Slots

`prefix` and `suffix` are text addons (`R$`, `%`, `.com.br`) separated by a divider. The slots
`:leading` and `:trailing` hold a control inside the box (a button, a `kbd`, a clear icon).
`:label_aside` goes at the right of the caption and `:below` between the box and the help line.

## Shortcut

`shortcut` draws a `kbd` at the end of the field and focuses the field when the key is pressed
anywhere on the page (the search of a list):

    <.input type="search" name="q" placeholder="Buscar" shortcut="/" />

The value is a combination as in `hotkey/1` (`"/"`, `"Mod+k"`); modifiers must match exactly, so
`"/"` does not fire with Ctrl, Meta or Alt. The press is ignored while the focus is in another
`input`, `select`, `textarea` or `contenteditable` element, and Esc inside the field takes the
focus out. The field gets `aria-keyshortcuts` and the `kbd` is `aria-hidden`. With several
fields with `shortcut` on one page, only the first visible one (in document order) answers.
The hook (`LedgerUI.SearchShortcut`) sits on the box, so it does not clash with `mask`'s hook;
it needs an `id` (it comes from `field`, or is derived from `name`). Without `shortcut` the
markup is unchanged.

Inside an `input_group` use `variant="plain"`: the group draws the shared border.

## `<.input>`

Renders a text-like `<input>`, with its caption, help and errors when given.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` | A form field: fills id/name/value/errors. |
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `type` | `:string` | `"text"` | `text`, `email`, `password`, `number`, `search`, `tel`, `url`, `date`, `time`, `datetime-local`, `month`, `week`, `color`, `file`, `hidden` |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled`, `plain` |
| `size` | `:string` | `"md"` | `lg`, `md`, `sm` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `align` | `:string` | `"left"` | `left`, `right` |
| `state` | `:string` | `nil` | `nil`, ``, `success`, `error` |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `hint` | `:string` | `nil` | Text at the right of the label (alias: `label_hint`). |
| `label_hint` | `:string` | `nil` |  |
| `optional` | `:boolean` | `false` | Adds "(opcional)" to the label. |
| `required` | `:boolean` | `false` |  |
| `layout` | `:string` | `"stacked"` | `stacked`, `inline` |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `options` | `:list` | `[]` | Suggestions, rendered as the input's `<datalist>`. |
| `icon` | `:string` | `nil` | Icon name at the left of the text. |
| `prefix` | `:string` | `nil` | Text addon before the input (`R$`). |
| `suffix` | `:string` | `nil` | Text addon after the input (`BRL`). |
| `mask` | `:string` | `nil` | `nil`, ``, `blocks`, `credit_card`, `date`, `time`, `phone`, `numeral`, `cpf_cnpj` |
| `mask_options` | `:map` | `%{}` |  |
| `mask_submit` | `:string` | `"formatted"` | `formatted`, `raw` |
| `clear_on_submit` | `:boolean` | `false` |  |
| `shortcut` | `:string` | `nil` | A key that focuses the field (`"/"`); draws a `kbd` at the end. See "Shortcut". |
| `wrapper_class` | `:any` | `nil` | Classes of the field wrapper (caption, box, help). |
| `class` | `:any` | `nil` | Classes of the box. |

Any other HTML/phx attribute goes to the root element, including `accept`, `autocomplete`, `autofocus`, `form`, `list`, `max`, `maxlength`, `min`, `minlength`, `multiple`, `pattern`, `placeholder`, `readonly`, `step`, `inputmode`, `size`.

Slots:

- `<:below>`
- `<:label_aside>`
- `<:leading>` - A control at the start of the box, after the icon.
- `<:trailing>` - A control at the end of the box (a button, a `kbd`).
