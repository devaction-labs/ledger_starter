# LedgerUI.Components.Form

The pieces Ledger UI's forms are made of: a caption (`label/1`), a help line (`help_text/1`),
an error line (`error/1`) and the `field/1` wrapper that puts them around any control.

    <.label for="email">Email</.label>
    <.help_text>We never share it.</.help_text>
    <.error>can't be blank</.error>

    <.field label="Country" help="Where you live" errors={@form[:country].errors}>
      <select>…</select>
    </.field>

`input/1`, `textarea/1`, `otp_input/1`, `phone_input/1` and the groups already render their own
field, so `field/1` is for the controls Ledger UI does not draw (a native `<select>`, a
third-party widget).

## `<.label>`

A caption for the control with the id `for`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `for` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.error>`

A validation message in the small red text. It has `role="alert"`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.help_text>`

The small line under a control. `state="success"` paints it green (with a check-circle icon)
and `state="error"` red.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `state` | `:string` | `nil` | `nil`, ``, `success`, `error` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.field>`

Wraps a control with its caption, help line and errors.

With `as="label"` (default) the whole block is a `<label>`, so a click on the caption focuses
the control. When there are errors they replace the help line.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` | Takes the errors from a form field. |
| `id` | `:string` | `nil` | The id of the control, for the caption's `for`. |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `label_hint` | `:string` | `nil` |  |
| `optional` | `:boolean` | `false` | Adds "(opcional)" to the caption. |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `state` | `:string` | `nil` | `nil`, ``, `success`, `error` |
| `as` | `:string` | `"label"` | `label`, `div` |
| `layout` | `:string` | `"stacked"` | `stacked`, `inline` |
| `required` | `:boolean` | `false` | Adds the red asterisk to the caption. |
| `label_id` | `:string` | `nil` | Id of the caption (for `aria-labelledby`). |
| `msg_id` | `:string` | `nil` | Id of the first help/error line (`aria-describedby`). |
| `class` | `:any` | `nil` |  |
| `bare` | `:boolean` | `false` | With nothing to show around the control (no caption, help, errors) render it alone. |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:aside>` - At the right of the help/error line (a character counter).
- `<:below>` - Between the control and the help line (strength bars).
- `<:inner_block>` (required)
- `<:label_aside>` - At the right of the caption (a "Forgot?" link): the caption and this sit in one row.
