# LedgerUI.Components.Table

Ledger UI's tables: basic, bordered, hoverable, zebra, the grid and the lean `data` looks, with
`:col` slots the way Phoenix's generated `CoreComponents.table/1` takes them.

    <.table id="users" rows={@users}>
      <:col :let={user} label="Name">{user.name}</:col>
      <:col :let={user} label="Job" align="right">{user.job}</:col>
    </.table>

    <.table id="users" rows={@streams.users} variant="hoverable"
      row_click={fn {_id, user} -> JS.navigate(~p"/users/#{user.id}") end}>
      <:col :let={{_id, user}} label="Name" sort_key="name">{user.name}</:col>
      <:action :let={{_id, user}}><.button size="sm">Edit</.button></:action>
    </.table>

The markup is `div[data-part=table-wrap] > table[data-part=table]`, styled only with Tailwind
utilities: the look of the table (`variant`, `compact`, `rounded`) is a set of local variables on
the `<table>` (`--tpx`, `--td-py`, ...) that every cell reads, so the same cell classes serve the
rows mode and the hand-written tables. `variant` is `nil` for the bare table; `rounded` (`row`,
`top`) rounds the rows or the header row.

A cell takes its text colour, weight and size from the utilities of its `class`
(`<:col class="font-medium text-ink">`, `class="font-mono text-[13px]"`).

In the rows mode the classes every cell shares (padding, borders, header type, background) are
set once on the `<table>` with descendant selectors; a cell only carries what varies (alignment,
`class`, priority, card role). The hand-written table keeps them on each cell.

## Events

Every event attr takes an event name or a `%JS{}`; `target` sets `phx-target`.

  * `on_sort`: `%{"column" => sort_key, "direction" => "asc" | "desc"}` (the direction to sort
    by next). A column with `sort_key` gets `class="sort"` and the arrows; `sort_by`/`sort_dir`
    mark the current order.
  * `on_select`: `%{"id" => key, "selected" => "true" | "false"}` (the new state of that row).
    `on_select_all`: `%{"selected" => "true" | "false"}`. `selected` lists the checked keys; the
    key is `row_key.(row)` or the row's DOM id. With a stream, `stream_insert` the rows whose
    selection changed and give `all_selected`.

## Hand-written tables

Without `rows`, the table renders its inner block: `table_head/1`, `table_body/1`,
`table_row/1`, `table_cell/1`, `table_foot/1` and `table_empty/1` (see each).

## Columns that leave by priority

A `:col` with `priority` 1, 2 or 3 (up to 4) leaves (header, cells and `:foot` cell together) when
the table's own box (a container, `@container`) gets narrower than the matching `breakpoints`
entry (720, 560 and 420px by default). Tailwind only sees literal class names, so the widths are
a fixed list (the `hide_widths` list of the internal Table.Layout module); another width raises
`ArgumentError`.

## Column sizing: `grow`, `wrap`, `min`

The table is an auto-layout `<table>` (`w-full`) and every cell is one line (`whitespace-nowrap`),
so with room to spare each column gets a share of it in proportion to its content. To give the
free width to one column (a name, a description) put `grow` on its `:col`:

    <:col :let={o} label="Cliente" grow={1}>{o.cliente}</:col>

The other columns stay at the width of their content, the grown one takes the rest, stays on a
single line while it fits and wraps when the table (or its wrapper) gets narrower. `grow` is a
weight: with `grow={2}` and `grow={1}` the first takes twice the second's share of the table.

  * `wrap="auto"`: the text may wrap (the default of a `grow` column; on a column without `grow`
    it only lets the text wrap). `wrap="never"`: always one line, the wrapper scrolls instead
    (the default of a column without `grow`). `wrap="truncate"`: one line cut with an ellipsis,
    never wider than the room the table gives it.
  * `min`: minimum width (`"12rem"`, `"200px"`), so a growing column does not wrap into a
    sliver before the table scrolls.
  * `width` wins: a column with `width` keeps its own track treatment and ignores `grow`, `wrap`
    and `min`. Without any of the three the markup is unchanged (`role="title"` does not grow by
    itself: say `grow` where you want it).
  * In the card layout (`card_below`) the column goes back to `w-auto` and drops `min`.

## Card layout, details panel, copy columns (used by `card_table/1`)

Extra attributes `card_below`, `details`, `row_editing`, `row_action` and the column attributes
`role`, `width`, `truncate`, `card`, `copy*` back the "card" table (see
`LedgerUI.Components.CardTable`): under `card_below` px each row is a two-line grid placed by the
`role` of its cells (`head`, `status`, `title`, `value`); `card_below` is one of
the `card_widths` list of the internal Table.Layout module. `details` adds a panel under the clicked row
(hook `LedgerUI.CardTable`) with the `:detail` slots and the columns that left by priority;
`copy` turns a cell into a copy button; `row_editing` swaps a row for the `:edit` slot.

## Streams with `:expand` / `:detail`: `row_groups`

The detail row (`:expand`) and the panel row (`:detail`) are siblings of the row's `<tr>`. In a
stream the client only moves the element that carries the stream id, so a reset, a `stream_insert`
at `at: 0` or a `stream_delete` would leave those rows behind. With `row_groups` each item is a
`<tbody id={dom_id}>` holding its `<tr>` and the rows that belong to it, and `phx-update="stream"`
goes on the `<table>` (its `<thead>`, `<tfoot>` and the empty `<tbody>` keep their own ids). It is
on by itself when `rows` is a stream and there is an `:expand` or a panel (`details` with `:detail`
or `priority` columns); `row_groups={false}` keeps the single `<tbody>` and `row_groups={true}`
forces the layout for lists too. In that layout the `<tr>` id is `"<dom_id>-row"`, `body_class` is
applied to every item's `<tbody>`, the hook of the panel sits on the `<table>` and the zebra
stripes count items, not `<tr>`s. Without `row_groups` (and without the stream + expand/panel
case) the markup is the one it always was.

## Not implemented

`peek` / `peek_label` (the panel with the hidden columns) are accepted but draw
nothing yet. `borderless` is accepted: the design has no style for it.

## `<.table>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `rows` | `:any` | `nil` | A list or a `@streams.x` stream. Leave it out to write the table by hand. |
| `row_id` | `:any` | `nil` | Function giving each row's DOM id (streams: the stream id). |
| `row_click` | `:any` | `nil` | Function of the row returning a `JS` or an event. |
| `row_class` | `:any` | `nil` | Function of the row returning extra classes of its `<tr>`. |
| `row_attrs` | `:any` | `nil` | Function of the row returning a map of extra `<tr>` attributes. |
| `row_item` | `:any` | `&Function.identity/1` | Maps each row before the slots get it. |
| `row_key` | `:any` | `nil` | Function giving the selection key of a row (default: DOM id). |
| `variant` | `:string` | `nil` | `nil`, `basic`, `bordered`, `hoverable`, `zebra`, `grid`, `data`, `data-grid`, `flat` - `nil` is the bare table (rows light up on hover; `basic` does not). `grid` is the gridjs look; `data`/`data-grid` the lean one of `data_table/1`. |
| `rounded` | `:string` | `nil` | `nil`, `row`, `top`, `none` |
| `sort_by` | `:string` | `nil` |  |
| `sort_dir` | `:string` | `"asc"` | `asc`, `desc` |
| `on_sort` | `:any` | `nil` |  |
| `on_select` | `:any` | `nil` |  |
| `on_select_all` | `:any` | `nil` |  |
| `selected` | `:list` | `[]` |  |
| `all_selected` | `:boolean` | `nil` |  |
| `hoverable` | `:boolean` | `nil` |  |
| `compact` | `:boolean` | `false` |  |
| `headless` | `:boolean` | `false` |  |
| `sticky_header` | `:boolean` | `false` |  |
| `borderless` | `:boolean` | `false` |  |
| `bleed` | `:boolean` | `false` | For a table inside a `card` body with `padded={false}`: no box of its own (no border, radius or background) and the first and last cells are padded by the card's `--card-p` (16px outside a card), so rows run edge to edge while the content stays aligned with the card's padding. |
| `card_below` | `:integer` | `nil` | Width (px) of the table's own box under which rows become two-line cards (needs `role`s); one of `Table.Layout.card_widths/0`. |
| `details` | `:boolean` | `false` | A click on a row opens a panel under it (hook `LedgerUI.CardTable`). |
| `panel_label` | `:string` | `nil` |  |
| `row_editing` | `:any` | `nil` | Function of the row; true swaps its cells for the `:edit` slot. |
| `row_action` | `:any` | `nil` | Function of the row; false leaves the content of its `:action` cells out. |
| `body_class` | `:any` | `nil` | Classes of the `<tbody>` (of each item's, with `row_groups`). |
| `copy_toast` | `:boolean` | `false` | A toast (`ledger:toast`, the contract of `clipboard`) after a `copy` column copies. A column's own `copy_toast` wins. |
| `copy_toast_message` | `:string` | `nil` | The toast text; `%s` is the copied value, shown in bold. Default: `"%s · <copied_label>"`. |
| `row_groups` | `:boolean` | `nil` | One `<tbody>` per row, holding its `<tr>`, panel and detail rows, so a stream moves them together. `nil` turns it on for a stream with `:expand` or a details panel. |
| `select_attrs` | `:any` | `nil` | Function of the row returning extra attributes (`class`, `style`) of its checkbox label. |
| `expand_open` | `:any` | `nil` | Function of the row: with `:expand`, shows its detail row always open (no toggle column), for rows it returns true for. |
| `breakpoints` | `:list` | `[720, 560, 420]` | Widths (px) under which priority 1, 2, 3... leave; each is one of `Table.Layout.hide_widths/0`. |
| `wrapper` | `:boolean` | `true` | `false` leaves out the bordered box (a table inside a card body). |
| `container` | `:boolean` | `nil` |  |
| `peek` | `:boolean` | `false` | Not implemented yet. |
| `peek_label` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `expand_label` | `:string` | `nil` |  |
| `scroll_label` | `:string` | `nil` |  |
| `sort_label` | `:string` | `nil` |  |
| `row_label` | `:any` | `nil` |  |
| `select_all_label` | `:string` | `nil` |  |
| `select_label` | `:string` | `nil` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` | Classes of the `<table>`. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - attrs: `priority`, `card` - Cells appended to every row, after the columns.
- `<:col>` - attrs: `label`, `class`, `head_class`, `dim`, `align`, `sort_key`, `priority`, `style`, `role`, `width`, `truncate`, `grow`, `wrap`, `min`, `card`, `copy`, `copy_label`, `copied_label`, `copy_show`, `copy_tip`, `copy_toast`, `copy_toast_message` - A column; receives the row (after `row_item`).
- `<:detail>` - attrs: `label` - A `label: value` line of the details panel; receives the row.
- `<:edit>` - Inline form in place of the cells of a row for which `row_editing` is true.
- `<:empty>` - Shown in a full-width row when there are no rows.
- `<:expand>` - Detail shown under a row; receives `%{row: row, toggle: js}`.
- `<:foot>` - attrs: `class`, `align`, `colspan`, `priority` - A cell of the `<tfoot>` row, for totals.
- `<:inner_block>` - The hand-written table when `rows` is not given.

## `<.table_head>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `sort_by` | `:string` | `nil` |  |
| `sort_dir` | `:string` | `"asc"` | `asc`, `desc` |
| `on_sort` | `:any` | `nil` |  |
| `on_select_all` | `:any` | `nil` | Adds a select-all checkbox cell first; the event it sends. |
| `all_selected` | `:boolean` | `false` |  |
| `some_selected` | `:boolean` | `false` |  |
| `select_all_id` | `:string` | `nil` |  |
| `select_all_label` | `:string` | `nil` |  |
| `sort_label` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `sticky_header` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` | Classes of the `<tr>`. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:col>` - attrs: `label`, `class`, `align`, `colspan`, `priority`, `sort_key`, `title`, `id` - A header cell; its content is the label (or give `label`).
- `<:inner_block>` - Extra `<th>` cells after the columns, or further header rows.

## `<.table_body>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.table_row>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `selected` | `:boolean` | `nil` | `true` checks the box and tints the row. |
| `on_click` | `:any` | `nil` |  |
| `on_select` | `:any` | `nil` | Adds a selection checkbox cell first; the event it sends. |
| `select_value` | `:any` | `nil` | Sent as `"id"` by the checkbox. |
| `select_label` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:cell>` - attrs: `class`, `align`, `colspan`, `rowspan`, `priority`, `title`, `id` - A `<td>` of the row.
- `<:inner_block>` - Free cells after the `:cell` ones.

## `<.table_cell>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `header` | `:boolean` | `false` | Renders a `<th scope="row">`. |
| `align` | `:string` | `nil` | `nil`, `left`, `center`, `right` |
| `colspan` | `:any` | `nil` |  |
| `rowspan` | `:any` | `nil` |  |
| `priority` | `:integer` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.table_foot>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` | Classes of the `:cell` row. |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:cell>` - attrs: `class`, `align`, `colspan`, `priority` - A `<td>` of the totals row.
- `<:inner_block>` - Free `<tr>` rows after the `:cell` row.

## `<.table_empty>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `class` | `:any` | `nil` | Classes of the cell. |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.table_checkbox>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `checked` | `:boolean` | `false` |  |
| `indeterminate` | `:boolean` | `false` | Draws the dash of a partial selection (needs an `id`, for its hook). |
| `label` (required) | `:string` |  | The `aria-label` of the box. |
| `middle` | `:boolean` | `false` | `vertical-align: middle` (the box of a body row; the header's sits on the baseline). |
| `on_click` | `:any` | `nil` |  |
| `values` | `:map` | `%{}` | Sent as `phx-value-*` with `on_click`. |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.table_expand_toggle>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `row_id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.table_detail_row>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `row_id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` | Classes of the detail panel. |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.table_skeleton>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `rows` | `:integer` | `5` |  |
| `columns` | `:list` | `[]` | Header labels; one column each. |
| `cols` | `:integer` | `4` | How many columns when `columns` is empty. |
| `variant` | `:string` | `nil` | `nil`, `basic`, `bordered`, `hoverable`, `zebra`, `grid`, `data`, `data-grid`, `flat` |
| `rounded` | `:string` | `nil` | `nil`, `row`, `top`, `none` |
| `compact` | `:boolean` | `false` |  |
| `headless` | `:boolean` | `false` |  |
| `shapes` | `:list` | `[]` | Per column: `text` (a bar), `avatar`, `pill` or `number`. |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.
