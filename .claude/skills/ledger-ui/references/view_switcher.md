# LedgerUI.Components.ViewSwitcher

The views of a collection (List, Board, Table...) as a segmented control, with an
optional "+ View" menu to add one and a menu of saved views. Styled only with Tailwind
utilities; every part carries `data-part` (`view-switcher`, `view-switcher-seg`,
`view-switcher-view`, `view-switcher-count`, `view-switcher-saved`, `view-switcher-add`).

    <.view_switcher
      id="invoice-views"
      value={@view}
      on_change="set_view"
      on_add="add_view"
      views={[%{label: "List", value: "list", icon: "list"}, %{label: "Board", value: "board", icon: "kanban"}]}
      options={[%{label: "Table", value: "table", icon: "table", description: "Table view"}]}
    />

`views` are maps with `:label`, `:value` and optionally `:icon`, `:count`, `:disabled`,
`:patch`/`:navigate`/`:href` (a link, `aria-current="page"` when chosen); plain strings
stand for `%{label: s, value: s}`. A tab sends `on_change` with `%{"view" => value}`.

`options` are the views the menu offers (`:label`, `:value`, `:icon`, `:description`, `:added`,
`:disabled`); choosing one sends `on_add` with `%{"view" => value}`. The menu is a
`dropdown/1` with id `"#{id}-add"`. `saved` (same shape) adds a menu of saved views
(`on_saved`, `saved_value`, `saved_label`).

Without `options` and `saved` the root is the segmented control itself; otherwise a row wraps
it. The chosen view is read from `aria-current="page"` (links) or `aria-pressed` (buttons); the menu
triggers carry `aria-haspopup`/`aria-expanded`/`aria-controls` (rendered by `dropdown/1`).
`data-lu-single` is set on the control when a `value` is chosen (the legacy script then moves
`aria-pressed` on click, before the server answers).

## `<.view_switcher>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `value` | `:any` | `nil` |  |
| `current` | `:any` | `nil` | Alias of `value`. |
| `views` | `:list` | `[]` |  |
| `options` | `:list` | `[]` |  |
| `saved` | `:list` | `[]` |  |
| `saved_value` | `:any` | `nil` |  |
| `saved_label` | `:string` | `"Saved views"` |  |
| `on_change` | `:any` | `nil` |  |
| `on_add` | `:any` | `nil` |  |
| `on_saved` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `add_label` | `:string` | `"View"` |  |
| `menu_title` | `:string` | `"Add a new view"` |  |
| `stretch` | `:boolean` | `false` | The views share the width of the control equally (each `flex-1`, content centered). |
| `loop` | `:boolean` | `false` | The canvas demo animation: a highlight slides over the views, 6s per round. It implies `stretch`. |
| `columns` | `:integer` | `2` | `1`, `2` |
| `placement` | `:string` | `"bottom-start"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
