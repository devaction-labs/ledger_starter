# LedgerUI.Components.InputGroup

Joins inputs, addons, selects and buttons into one row with shared borders.

    <.input_group>
      <.input_group_addon>R$</.input_group_addon>
      <.input name="amount" variant="plain" />
      <.input_group_addon>,00</.input_group_addon>
    </.input_group>

    <.input_group label="Price" size="sm" errors={["must be positive"]}>
      <.input_group_addon variant="filled">$</.input_group_addon>
      <.input name="amount" variant="plain" size="sm" state="error" />
    </.input_group>

The row is a `role="group"` named by the caption (`aria-labelledby`; give each group an `id`
when two share a label). With `errors` (or `state="error"`) every border of the row turns red,
and the row gets `aria-invalid` and an `aria-describedby` that points at the messages.

The group draws the shared border, so an `input/1` inside it takes `variant="plain"`.

## `<.input_group>`

Renders the row; `label` adds a caption above it, `help` and `errors` a line below.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled` |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `state` | `:string` | `nil` | `nil`, ``, `success`, `error` |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.input_group_addon>`

A text or icon box at either end (or between the inputs) of an `input_group`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"outline"` | `outline`, `filled` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
