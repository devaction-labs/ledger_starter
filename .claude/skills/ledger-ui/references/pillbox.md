# LedgerUI.Components.Pillbox

Multiple (or single) choice drawn as pills inside the field, with a searchable list
under it. It is the `LedgerUI.Components.Select` listbox (`multiple`, `search="panel"`)
and shares its hook, `LedgerUI.Select` (`priv/static/ledger_ui/hooks/select.js`).

    <.pillbox field={@form[:categories]} label="Categories" options={@categories} />
    <.pillbox name="tags" options={@tags} value={@chosen} create create_label="Create" />
    <.pillbox name="branches" options={@branches} value={@chosen} overflow="wrap" />
    <.pillbox name="product_id" value={@product_id} options={@products} multiple={false} />

The pills are submitted as `name[]` (an empty `name[]` first, so an emptied field still
reaches the server); `multiple={false}` submits `name`. Each change fires a bubbling `input`
event for `phx-change`. `readonly` keeps the values in the form but takes the x, the chevron
and the list away; `disabled` also leaves them out of the form.

Options may carry `:count` (a faint mono number at the right of the row) and `:color` /
`:initials` (a person: the pill gets a 22px avatar).

## `<.pillbox>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `options` | `:list` | `[]` |  |
| `selected_options` | `:list` | `[]` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `multiple` | `:boolean` | `true` |  |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `panel_min_width` | `:string` | `nil` |  |
| `panel_class` | `:any` | `nil` |  |
| `placeholder` | `:string` | `nil` |  |
| `search_placeholder` | `:string` | `"Search…"` |  |
| `overflow` | `:string` | `"one"` | `one`, `wrap` |
| `create` | `:boolean` | `false` |  |
| `create_label` | `:string` | `"Create"` |  |
| `create_hint` | `:string` | `"↵"` |  |
| `empty_label` | `:string` | `"No results found"` |  |
| `removable` | `:boolean` | `true` | An x on each pill. `false` draws plain pills (they are still removed from the list). |
| `chevron` | `:boolean` | `true` | The chevron at the end of the field. Without it more pills fit before the `+N`. |
| `clear` | `:boolean` | `false` |  |
| `clear_label` | `:string` | `"Clear"` |  |
| `remove_label` | `:string` | `"Remove"` |  |
| `hidden_label` | `:string` | `"%{count} hidden"` |  |
| `readonly` | `:boolean` | `false` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_search` | `:string` | `nil` |  |
| `debounce` | `:integer` | `300` |  |
| `target` | `:any` | `nil` |  |
| `on_load_more` | `:string` | `nil` |  |
| `has_more` | `:boolean` | `false` |  |
| `loading_label` | `:string` | `"Loading…"` |  |
| `open` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`, `required`.
