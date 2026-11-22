# LedgerUI.Components.TagsInput

A tag input: what is typed becomes a tag on Enter, Tab or a comma (pasting a comma separated
list creates several); tags are removed with Backspace or their remove button. Behaviour lives
in the `LedgerUI.TagsInput` hook (`priv/static/ledger_ui/hooks/tags_input.js`).

    <.tags_input label="Tags" placeholder="Enter tags" field={@form[:tags]} removable />
    <.tags_input name="tags" value={["awesome", "neat"]} removable restore_on_backspace />
    <.tags_input name="tags" value="clear,items" clearable max={5} />

`value` is a list of strings or a comma separated string. The tags are submitted as `name[]`
(plus an empty `name[]`, so an empty list still reaches the server) through a hidden
`<select multiple>`, and each change fires a bubbling `input` event for `phx-change`.
`suggestions` (or `options`) are offered in the list while typing; with `create={false}` only
listed options can be chosen and `on_search` pushes `%{"id" => id, "query" => text}` to
`target` (or the LiveView), which answers by re-rendering `options`.

## `<.tags_input>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `suggestions` | `:list` | `[]` |  |
| `options` | `:list` | `nil` |  |
| `selected_options` | `:list` | `[]` |  |
| `create` | `:boolean` | `true` |  |
| `on_search` | `:string` | `nil` |  |
| `debounce` | `:integer` | `300` |  |
| `removable` | `:boolean` | `false` |  |
| `clearable` | `:boolean` | `false` |  |
| `clear_label` | `:string` | `"Clear"` |  |
| `remove_label` | `:string` | `"Remove"` |  |
| `create_label` | `:string` | `"Add"` |  |
| `persist` | `:boolean` | `true` |  |
| `restore_on_backspace` | `:boolean` | `false` |  |
| `create_hint` | `:string` | `"Enter"` |  |
| `max` | `:integer` | `nil` |  |
| `counter` | `:boolean` | `true` |  |
| `limit_placeholder` | `:string` | `"Limit reached"` |  |
| `create_position` | `:string` | `"top"` | `top`, `bottom` |
| `compact` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | Demo animation (CSS only): the last tag fades in and `loop_text` is typed after it, over and over. |
| `loop_text` | `:string` | `nil` | The text typed by `loop`. |
| `no_results` | `:string` | `"No results found"` |  |
| `disabled` | `:boolean` | `false` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`.

Slots:

- `<:item>`
- `<:option>`
