# LedgerUI.Components.DataTable

A table with a search box, sortable headers, a pagination footer and row selection, in the two
looks of Ledger UI: `advanced` (title bar, the table as a card, summary and pager underneath)
and `grid` (search at the right, the gridjs table, summary and pager).

The LiveView owns the state: it filters, sorts and slices the rows and gives the component the
current page; the component renders it and sends events back.

    <.data_table
      id="users"
      rows={@users}
      search={@search}
      on_search="search"
      sort_by={@sort_by}
      sort_dir={@sort_dir}
      on_sort="sort"
      page={@page}
      page_size={10}
      total={@total}
      on_page="paginate"
    >
      <:title>Users</:title>
      <:col :let={user} label="Name" sort_key="name">{user.name}</:col>
      <:col :let={user} label="Email">{user.email}</:col>
    </.data_table>

    def handle_event("search", %{"search" => q}, socket), do: ...
    def handle_event("sort", %{"column" => col, "direction" => dir}, socket), do: ...
    def handle_event("paginate", %{"page" => page}, socket), do: ...

Rows may be a stream (`rows={@streams.users}`): the body renders with `phx-update="stream"` and
`total` drives the footer. `:col`, `:action`, `:expand`, `:empty`, `:foot`, `row_id`, `row_key`,
`row_item`, `row_click`, selection and columns that leave by `priority` work as in
`LedgerUI.Components.Table.table/1`, which renders the table.

## Events

`on_search` (`%{"search" => q}`), `on_sort` (`%{"column" => c, "direction" => d}`), `on_page`
(`%{"page" => "3"}`), `on_page_size` (`%{"page_size" => "30"}`), `on_select`
(`%{"id" => key, "selected" => "true" | "false"}`), `on_select_all` (`%{"selected" => ..}`).
With `page_path` (a function of the page number) the pager renders `patch` links instead.

## Extras over the README

A `:toolbar` slot (a row with a rule under it, for a search and buttons written by hand),
`body="card"` (the table directly in a card body instead of the bordered wrapper of the table)
and the pager looks `canvas` (plain) and `pages` (buttons, with previous arrow). Styled only
with Tailwind utilities.

## Not implemented

`peek` and `peek_label` are accepted; `peek` draws nothing yet. The pager pages are not
focusable (they carry `phx-click` only).

## `<.data_table>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `rows` (required) | `:any` |  | The rows of the current page, a list or a stream. |
| `variant` | `:string` | `"advanced"` | `advanced`, `grid` |
| `body` | `:string` | `"wrap"` | `wrap`, `card` |
| `row_id` | `:any` | `nil` |  |
| `row_key` | `:any` | `nil` |  |
| `row_item` | `:any` | `&Function.identity/1` |  |
| `row_click` | `:any` | `nil` |  |
| `row_class` | `:any` | `nil` |  |
| `row_attrs` | `:any` | `nil` |  |
| `hoverable` | `:boolean` | `nil` |  |
| `search` | `:string` | `""` |  |
| `search_placeholder` | `:string` | `nil` |  |
| `on_search` | `:any` | `nil` |  |
| `sort_by` | `:string` | `nil` |  |
| `sort_dir` | `:string` | `"asc"` | `asc`, `desc` |
| `on_sort` | `:any` | `nil` |  |
| `page` | `:integer` | `1` |  |
| `page_size` | `:integer` | `10` |  |
| `total` | `:integer` | `nil` |  |
| `on_page` | `:any` | `nil` |  |
| `page_path` | `:any` | `nil` |  |
| `footer` | `:boolean` | `true` |  |
| `compact` | `:boolean` | `false` |  |
| `sticky_header` | `:boolean` | `false` |  |
| `scroll_label` | `:string` | `nil` |  |
| `peek` | `:boolean` | `false` |  |
| `peek_label` | `:string` | `nil` |  |
| `sort_label` | `:string` | `nil` |  |
| `row_label` | `:any` | `nil` |  |
| `headless` | `:boolean` | `false` |  |
| `borderless` | `:boolean` | `false` |  |
| `page_sizes` | `:list` | `[]` |  |
| `on_page_size` | `:any` | `nil` |  |
| `pager` | `:string` | `"rounded"` | `rounded`, `pill`, `circle`, `canvas`, `pages` - The pager look: `rounded`, `pill`, `circle`, `canvas` (plain) or `pages` (buttons). |
| `pager_siblings` | `:integer` | `1` |  |
| `pager_arrows` | `:boolean` | `true` |  |
| `loading` | `:boolean` | `false` |  |
| `loading_rows` | `:integer` | `3` |  |
| `show_label` | `:string` | `nil` |  |
| `entries_label` | `:string` | `nil` |  |
| `prev_label` | `:string` | `nil` |  |
| `next_label` | `:string` | `nil` |  |
| `page_label` | `:string` | `nil` |  |
| `filter_label` | `:string` | `nil` |  |
| `summary_label` | `:string` | `nil` | Summary text with `%{from}`, `%{to}` and `%{total}`. |
| `select_all_label` | `:string` | `nil` |  |
| `select_label` | `:string` | `nil` |  |
| `selected` | `:list` | `[]` |  |
| `all_selected` | `:boolean` | `nil` |  |
| `on_select` | `:any` | `nil` |  |
| `on_select_all` | `:any` | `nil` |  |
| `expand_label` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `select_attrs` | `:any` | `nil` |  |
| `body_class` | `:any` | `nil` |  |
| `row_groups` | `:boolean` | `nil` | One `<tbody>` per row, so the `:expand` rows of a stream move with their row; on by itself for a stream with `:expand`. See `Table`. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>`
- `<:actions>` - Buttons at the right of the title bar.
- `<:bulk>` - Rendered under the table (a `bulk_bar`).
- `<:col>` (required) - attrs: `label`, `class`, `head_class`, `align`, `sort_key`, `priority`, `style`, `grow`, `wrap`, `min`
- `<:empty>`
- `<:expand>`
- `<:filters>` - A filter panel the title bar's filter button opens. Receives the `JS` that toggles it.
- `<:foot>` - attrs: `class`, `align`, `colspan`, `priority`
- `<:summary>` - Replaces the summary text; receives `%{first: n, last: n, total: n}`.
- `<:title>` - The `advanced` heading.
- `<:toolbar>` - A row above the table, written by hand.

## `<.data_table_pager>`

The pager of the data table footer: the page numbers (`rounded`, `pill`, `circle`, `canvas`) or
the buttons of `pages`. Pages near the current one, the first and the last, with `…` between.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `page` (required) | `:integer` |  |  |
| `pages` (required) | `:integer` |  | How many pages there are. |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill`, `circle`, `canvas`, `pages` |
| `on_page` | `:any` | `nil` | Event or `%JS{}` sent with `%{"page" => "3"}`. |
| `page_path` | `:any` | `nil` | Function of a page number returning a path (patch links). |
| `target` | `:any` | `nil` |  |
| `page_label` | `:string` | `nil` |  |
| `prev_label` | `:string` | `nil` |  |
| `next_label` | `:string` | `nil` |  |
| `siblings` | `:integer` | `1` |  |
| `arrows` | `:boolean` | `true` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.table_search>`

The search field of the title bar (a sunken box, 32px). With `on_search`, the field sits in a
form (`<id>-search-form`, input `<id>-search`) that sends `%{"search" => query}` on every change
(debounced 300ms) and on submit.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `value` | `:string` | `""` |  |
| `on_search` | `:any` | `nil` | Event name or `%JS{}` for the query changes. |
| `target` | `:any` | `nil` |  |
| `placeholder` | `:string` | `nil` |  |
| `width` | `:string` | `"220px"` |  |
| `shortcut` | `:string` | `nil` | A key hint (`/`) drawn at the right. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.table_toolbar>`

The toolbar above a table: search, controls, actions, and the row of applied filters as
removable chips.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"table-toolbar"` |  |
| `search` | `:string` | `nil` | The current query; the search field shows when `on_search` or `search` is given. |
| `on_search` | `:any` | `nil` |  |
| `search_placeholder` | `:string` | `nil` |  |
| `search_width` | `:string` | `"260px"` |  |
| `shortcut` | `:string` | `nil` |  |
| `filters` | `:list` | `[]` | Applied filters as chips: `[%{id: "plan", label: "Plano: Pro"}]`. |
| `on_remove_filter` | `:any` | `nil` | Sent with `%{"id" => id}` by a chip's remove button. |
| `on_clear` | `:any` | `nil` |  |
| `filters_label` | `:string` | `nil` |  |
| `clear_label` | `:string` | `nil` |  |
| `remove_label` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - Buttons at the right end.
- `<:start>` - Controls right after the search (a filter button, a view switch).
