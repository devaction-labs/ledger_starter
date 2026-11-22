# LedgerUI.Components.CardTable

The "card" table: one row per record in a rounded tray (styled with utilities only), with an optional heading, a
footer line and sub-lines. For long lists (orders, invoices, clients).

    <.card_table id="orders" rows={@streams.orders} on_select="select" selected={@selected}
      status={&order_status/1}>
      <:col :let={{_id, o}} label="Pedido" class="mono">{o.number}</:col>
      <:col :let={{_id, o}} label="Cliente">
        {o.client}
        <.ctable_sub priority={2}>{o.issuer}</.ctable_sub>
      </:col>
      <:col :let={{_id, o}} label="Total" align="right">{o.total}</:col>
      <:foot><span>Mostrando 1–6 de 128</span></:foot>
    </.card_table>

It renders `LedgerUI.Components.Table.table/1` inside the tray, so rows (list or stream), sorting,
selection and the other `row_*` attrs work as there. `variant="flat"` is the plain table of the
canvas dashboards (`lu-table flat`), in a card only when it has a `title`, `:top`, `:actions` or
`:foot`.

Columns leave by `priority` (1 to 4) when the table's own box is narrower than `breakpoints`
(`[1180, 960, 720, 520]` by default; between 2 and 5 strictly descending integers, else
`ArgumentError`). A `<.ctable_sub>` is a second line inside a cell that leaves by its own
`priority`, or shows only once the columns of `when_hidden` (`p1`..`p4`) have left.
`<:expand :let={row}>` is a full-width line under each row for which `row_expanded` is true.

## Card layout, panel, copy, edit

  * Under the last breakpoint (`520` by default) rows with a column `role` (`head`, `status`,
    `title`, `value`) become two-line cards; `card` keeps a column in its own line, `truncate`,
    `width` shape the tracks, `<:action card={false}>` leaves the action cell out.
  * With `<:detail>` slots or columns with `priority`, a click on a row (rows variant) opens a
    panel under it (hook `LedgerUI.CardTable`, on the `<tbody>`); `panel_label` names it.
  * `copy` / `copy_label` / `copied_label` / `copy_show` / `copy_tip` on a column draw a copy button
    (same hook). A copy shows a toast with the value in bold (`ledger:toast`, as `clipboard/1`; the
    page needs a `toaster`): `copy_toast={false}` turns it off, `copy_toast_message="%s copiado"`
    sets the text, and both can be set on one column too.
  * A stream with `<:expand>` or a details panel renders one `<tbody>` per row (`row_groups`), so
    the detail rows follow their row on a reset, `at: 0` insert and delete (#24).
  * `row_editing` + `<:edit>` swap a row for an inline form; `row_action` drops the action of a
    row.

`status` paints an inset bar through `box-shadow` on the row (`data-status` carries the colour name).

The tray, its heading, description and footer are styled here; the table inside (rows, cells,
breakpoints, details panel) is `LedgerUI.Components.Table`. `ctable_sub` hides itself with the same
container-query utilities (`Table.Layout`), from the `breakpoints` it is given.

## `<.card_table>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `rows` (required) | `:any` |  | A list or a `@streams.x` stream. |
| `row_id` | `:any` | `nil` |  |
| `row_item` | `:any` | `&Function.identity/1` |  |
| `row_key` | `:any` | `nil` |  |
| `row_attrs` | `:any` | `nil` | Function of the row returning extra `<tr>` attributes. |
| `status` | `:any` | `nil` | Function of the row returning a colour for the bar at its left, or `nil`. |
| `on_select` | `:any` | `nil` |  |
| `on_select_all` | `:any` | `nil` |  |
| `selected` | `:list` | `[]` |  |
| `all_selected` | `:boolean` | `nil` |  |
| `select_all_label` | `:string` | `nil` |  |
| `select_label` | `:string` | `nil` |  |
| `panel_label` | `:string` | `nil` | The accessible name of the details panel. |
| `on_sort` | `:any` | `nil` |  |
| `sort_by` | `:string` | `nil` |  |
| `sort_dir` | `:string` | `"asc"` | `asc`, `desc` |
| `target` | `:any` | `nil` |  |
| `title` | `:string` | `nil` |  |
| `description` | `:string` | `nil` |  |
| `meta` | `:string` | `nil` | A small muted text right after the title. |
| `bordered` | `:boolean` | `true` | `false` drops the tray's own border, shadow and background. |
| `row_expanded` | `:any` | `nil` |  |
| `row_editing` | `:any` | `nil` | Function of the row; true shows the `<:edit>` slot in place of the cells. |
| `row_action` | `:any` | `nil` | Function of the row; false leaves out the content of its action cell. |
| `breakpoints` | `:list` | `[1180, 960, 720, 520]` | Widths (px) under which priority 1, 2, 3... leave, descending; the last is the card layout. |
| `body_class` | `:any` | `nil` | Classes of the `<tbody>`. |
| `row_groups` | `:boolean` | `nil` | One `<tbody>` per row (with its panel and `:expand` rows), so a stream moves them together. `nil` turns it on for a stream with `:expand`/`row_expanded` or a details panel; `false` keeps the single `<tbody>`. See `Table`. |
| `variant` | `:string` | `"rows"` | `rows`, `flat` |
| `copy_toast` | `:boolean` | `true` | A toast (event `ledger:toast` on the page's `toaster`) with the copied value in bold after a `copy` column copies. `false` turns it off; a column's own `copy_toast` wins. Not shown while `loading` or with an `error` (no rows then). |
| `copy_toast_message` | `:string` | `nil` | The toast text, `%s` is the copied value (`"%s copiado"`). Default: `"%s · <copied_label>"`. |
| `selection_label` | `:string` | `nil` | The text after the count in the `:selection` badge, for one selected. |
| `selection_label_plural` | `:string` | `nil` | Same, for several (`selection_label` when nil). |
| `selection_badge` | `:boolean` | `true` | `false` leaves the count badge out of the `:selection` strip (the slot draws all of it). |
| `loading` | `:boolean` | `false` | Skeleton lines (`loading_rows`, with the columns) in place of the rows. |
| `loading_rows` | `:integer` | `5` |  |
| `loading_label` | `:string` | `nil` |  |
| `error` | `:string` | `nil` | A message: shows the error state in place of the rows (wins over `loading`). |
| `on_retry` | `:any` | `nil` | Event name or `JS` of the retry button of the error state. |
| `retry_label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - attrs: `priority`, `card` - The last cell of every row (a menu button); receives the row.
- `<:actions>` - Buttons at the right of the heading.
- `<:col>` (required) - attrs: `label`, `width`, `priority`, `role`, `align`, `truncate`, `grow`, `wrap`, `min`, `class`, `sort_key`, `copy`, `copy_label`, `copied_label`, `copy_show`, `card`, `copy_tip`, `style`, `copy_toast`, `copy_toast_message` - A column; receives the row (after `row_item`).
- `<:detail>` - attrs: `label` - A line of the details panel that opens when a row is clicked.
- `<:edit>` - Inline form in place of the cells of a row being edited.
- `<:empty>` - Shown when there are no rows. Receives `%{id, rows, selected, title}`.
- `<:expand>` - A full-width line under a row (see `row_expanded`); receives the row.
- `<:foot>` - A line inside the card under the rows. Receives `%{id, rows, selected, title}`.
- `<:selection>` - A strip under the toolbar, only while something is selected, with the `accent-soft` fill and no border. Receives `%{count, selected}`; the count badge is drawn before it.
- `<:toolbar>` - A strip inside the card, between the heading and the table (search, filters, export), with a hairline under it.
- `<:top>` - With `variant="flat"`, what heads the card instead of the title (tabs).

## `<.ctable_sub>`

A second line inside a `card_table` cell (12px, faint) that leaves by its own `priority`; or,
with `when_hidden="p2"`, shows only once the columns of priority 2 have left.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `priority` | `:integer` | `nil` | 1 to 4: leaves where the columns of that priority leave. |
| `when_hidden` | `:string` | `nil` | `nil`, `p1`, `p2`, `p3`, `p4` |
| `breakpoints` | `:list` | `[1180, 960, 720]` | The widths of the table's priorities 1, 2, 3...: the `breakpoints` of the `card_table` without its last (card) width. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
