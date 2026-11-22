# LedgerUI.Components.Segmented

A segmented control: a row of toggle buttons where exactly one is chosen.

    <.segmented id="range" value={@range} on_change="set-range" options={~w(day month year)} />
    <.segmented field={@form[:view]} options={[{"List", "list"}, {"Board", "board"}]} />

    <.segmented id="view" value="board" options={[
      %{label: "Board", value: "board", icon: "kanban"},
      %{label: "All", value: "all", count: 128}
    ]} />

Options are strings, `{label, value}` tuples or maps with `:label`, `:value`, `:icon`, `:count`
and `:disabled`. It is a `role="group"` (see `role`) of buttons with `aria-pressed`, which is what the chosen look reads. The choice is made in
the browser (hook `LedgerUI.Segmented`, `priv/static/ledger_ui/hooks/segmented.js`): a new
`value` from the server wins, a patch that does not change it leaves the person's choice
alone, arrow keys/Home/End move the focus (one segment is in the Tab order).

With a `name` (or `field`) the control submits through a hidden input that fires `input`, so a
form's `phx-change` runs. `on_change` is an event name (pushed with
`%{"id" => id, "value" => value}` to `target`) or a `%JS{}`.

## `<.segmented>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `options` | `:list` | `[]` | Strings, `{label, value}` tuples or maps; or write `<:option>` slots. |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `full` | `:boolean` | `false` |  |
| `stretch` | `:boolean` | `false` | The canvas form of a full-width control: `width:100%` on the group, `flex:1` per button. |
| `role` | `:string` | `"group"` | `group` (default) or what the surface needs. |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`.

Slots:

- `<:option>` - attrs: `value`, `label`, `icon`, `count`, `disabled`, `selected` - One segment, its content the label (instead of `options`). `value` defaults to the position; `selected` chooses it when `value` is not given.
