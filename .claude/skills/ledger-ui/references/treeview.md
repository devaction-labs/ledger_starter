# LedgerUI.Components.Treeview

A tree view: a hierarchical list whose branches expand and collapse.

    <.treeview id="notas" on_toggle="toggled" on_select="opened">
      <.tree_item id="2026" label="Notas 2026" expanded>
        <:icon><.icon name="folder" size="md" /></:icon>
        <.tree_item id="out" label="Outubro" branch />
        <.tree_item id="nfe" label="NF-e 48.211.xml" selected />
      </.tree_item>
    </.treeview>

An item with children is a branch, one without is a leaf. `branch` draws a closed branch
before its children are there (loaded when it opens). `checked` (`true`, `false` or `"mixed"`)
puts a checkbox before the label; `chevrons={false}` leaves the chevrons out.

Branches open and close in the browser (`LedgerUI.Treeview` hook), with no round trip; a
branch the person toggled stays that way across patches, and the server wins when it changes
`expanded` for it. `on_toggle` is pushed with `%{"id" => id, "expanded" => boolean}`,
`on_select` with `%{"id" => id}` when a leaf is clicked (or gets Enter), `on_check` with
`%{"id" => id, "checked" => boolean}`; all to `target` when given. A `%JS{}` is executed instead.

The ARIA is rendered by the server: the root is `role="tree"`, each row a `role="treeitem"` with
`aria-selected`, `aria-expanded` (branches), `aria-checked` (when `checked` is given), `aria-owns`
pointing at its `role="group"` of children and a roving `tabindex` (`0` on the selected row, `-1` on
the others; the hook makes sure one row, the first when none is selected, is in the tab order).
The hook only updates `aria-expanded`/`aria-selected`/`tabindex` as the person interacts.

The look is flat rows (`data-part="tree-item"`), styled only with Tailwind utilities: a selected
row is `aria-selected="true"`. Nested `tree_item`s are wrapped in a `data-part="tree-children"`
box that indents them (and is `hidden` while closed), so no `depth` is needed; rows written side
by side (as the design does) take `depth`.

## Checkboxes

A row with `checked` cascades in the browser: (un)checking a branch (un)checks everything under
it, and a branch shows the dash (`indeterminate`, `aria-checked="mixed"`) while only some of its
children are checked. `on_check` is pushed for the row that was clicked.

## Streams

    <.treeview id="files" rows={@streams.files}>
      <:row :let={{_dom_id, file}}>
        <.tree_item id={"file-#{file.id}"} label={file.name} />
      </:row>
    </.treeview>

## `<.treeview>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `expanded` | `:list` | `[]` | Ids of the branches that are open. |
| `on_toggle` | `:any` | `nil` |  |
| `on_select` | `:any` | `nil` |  |
| `on_check` | `:any` | `nil` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `lineone` - `lineone` is reserved: the design has no style for it. |
| `chevrons` | `:boolean` | `true` |  |
| `target` | `:any` | `nil` |  |
| `rows` | `:any` | `nil` | A list or a stream rendered by `:row`. |
| `row_id` | `:any` | `nil` | A function giving each row's DOM id (lists only). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`
- `<:row>` - Renders one row; takes `{dom_id, item}`.

## `<.tree_item>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` | Names the item in events and in `expanded`. |
| `label` | `:string` | `nil` |  |
| `expanded` | `:boolean` | `false` |  |
| `selected` | `:boolean` | `false` |  |
| `branch` | `:boolean` | `false` | A branch even with no children yet. |
| `checked` | `:any` | `nil` | `nil`, `true`, `false`, `mixed` |
| `tag` | `:string` | `nil` | `nil`, `li`, `div` - Wraps the item in this tag. |
| `count` | `:string` | `nil` | A trailing count (the mono figure at the right). |
| `depth` | `:integer` | `0` | Indent level for rows written side by side. |
| `chevron` | `:boolean` | `true` | Leaves room for / draws the chevron. |
| `chevron_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `icon`.

Slots:

- `<:icon>` - An icon before the label.
- `<:inner_block>` - The children; makes the item a branch.

## `<.tree>`

A tree written as data: the same as `treeview/1` with one `tree_item/1` per map.

    <.tree id="folders" items={[
      %{id: "fiscal", label: "Fiscal", icon: "folder", count: 12, expanded: true,
        children: [%{id: "nfe", label: "NF-e", icon: "file"}]}
    ]} selected="nfe" />

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"tree"` |  |
| `items` (required) | `:list` |  | Maps with `:label` and optionally `:id`, `:icon`, `:count`, `:checked`, `:expanded` and `:children` (the same shape, nested). |
| `selected` | `:any` | `nil` | The `id` (or the `label`, without ids) of the selected item. |
| `expanded` | `:list` | `[]` | Ids of the branches that are open. |
| `on_toggle` | `:any` | `nil` |  |
| `on_select` | `:any` | `nil` |  |
| `on_check` | `:any` | `nil` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `lineone` |
| `chevrons` | `:boolean` | `true` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
