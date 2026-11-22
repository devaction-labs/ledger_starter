# LedgerUI.Components.Checkbox

`checkbox/1` (the box with label and description) and `checkbox_group/1` (one
checkbox per option of a list field).

    <.checkbox name="terms" label="I agree" />
    <.checkbox field={@form[:remember]} label="Remember me" color="primary" />
    <.checkbox name="pro" label="Pro plan" description="Billed yearly" color="primary" checked />
    <.checkbox name="all" label="Select all (3 of 8)" indeterminate />

    <.checkbox_group field={@form[:roles]} label="Roles"
      options={[{"Admin", "admin"}, {"Editor", "editor"}]} />
    <.checkbox_group field={@form[:channels]} variant="chip" color="primary" options={[
      %{label: "E-mail", value: "email", count: 3}, %{label: "WhatsApp", value: "whatsapp"}]} />

Inside a form a named checkbox sends `unchecked_value` through a hidden input when it is off
(`hidden_input={false}` skips it), so the field is always in the params. `indeterminate`
draws the dash of a partial selection (`data-ind`); the `indeterminate` property and
`aria-checked="mixed"` are set by the `LedgerUI.Indeterminate` hook
(`priv/static/ledger_ui/hooks/indeterminate.js`), so the box needs an `id`: it is taken from
`id`, the field, the name or the label. Pass `false` when the box can leave that state; a
click clears the dash.

Extra HTML attributes (`form`, `required`, `phx-click`, `data-*`...) go to the `<input>`.

## `<.checkbox>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `checked` | `:boolean` | `nil` |  |
| `indeterminate` | `:boolean` | `nil` |  |
| `checked_value` | `:string` | `"true"` |  |
| `unchecked_value` | `:string` | `"false"` |  |
| `hidden_input` | `:boolean` | `true` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `variant` | `:string` | `"basic"` | `basic`, `outline` |
| `filled` | `:boolean` | `false` |  |
| `shape` | `:string` | `"square"` | `square`, `circle` |
| `size` | `:string` | `"md"` | `nil`, `xs`, `sm`, `md`, `lg` |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `description` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | Demo animation (CSS only): the box fills and the tick draws by itself. |
| `wrapper_class` | `:any` | `nil` | Classes of the block that wraps box and errors. |
| `class` | `:any` | `nil` | Classes of the label (the clickable row). |
| `style` | `:string` | `nil` | Inline style of the label, not of the input. |

Any other HTML/phx attribute goes to the root element, including `form`, `required`, `autofocus`.

Slots:

- `<:inner_block>`

## `<.checkbox_group>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `options` | `:list` | `[]` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `variant` | `:string` | `"basic"` | `basic`, `outline`, `card`, `chip` |
| `filled` | `:boolean` | `false` |  |
| `shape` | `:string` | `"square"` | `square`, `circle` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg` |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:checkbox>` - attrs: `value`, `label`, `color`, `disabled`, `description`, `count`, `icon`
