# LedgerUI.Components.Kanban

Kanban board: a row of tinted columns holding cards that are dragged between them.

    <.kanban id="funnel" event="move" aria-label="Sales funnel" style="--cols:3">
      <.kanban_column id="col-open" list="open" label="Open" count={length(@open)} color="primary">
        <.kanban_card :for={card <- @open} id={"card-#{card.id}"} item={card.id}>
          <b>{card.title}</b>
        </.kanban_card>
        <:empty>Drop here</:empty>
      </.kanban_column>
      <.kanban_lost label="Lost" count={3} list="lost" />
    </.kanban>

Styled only with Tailwind utilities. The board is one `LedgerUI.Sortable` hook
(`priv/static/ledger_ui/hooks/sortable.js`): columns (`data-part="kanban-column"`) are lists,
cards (`data-part="kanban-card"`) are items, and a drop pushes `event` (to `target` when given) with
`%{"id" => item, "from" => list, "to" => list, "index" => position}`. Nothing is moved in the
browser: the server's render is the new order. `data-list`/`data-id` are only rendered when
`list`/`item` are given; the hook falls back to the element ids.

A column with a `limit` turns its pill and bar red (`data-wip="exceeded"`) when `count` goes over
it. The board is `role="group"` when it has an `aria-label`. `--cols` in `style` sets the grid
columns; without it the columns are 272px wide in a row that scrolls sideways (`fluid` shares
the width instead).

The same hook sorts any list: put `phx-hook="LedgerUI.Sortable"` on it with `data-list`,
`data-event`, `data-group`, `data-handle`, `data-axis`, `data-target`, `data-disabled`; items
carry `data-id`.

## `<.kanban>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `event` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `group` | `:string` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `local` | `:boolean` | `false` | The board moves the dropped card itself (and the counters), besides pushing `event`. |
| `fluid` | `:boolean` | `false` |  |
| `active` | `:string` | `nil` | Phone mode: the column shown below 640px. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.kanban_column>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `list` | `:string` | `nil` |  |
| `label` (required) | `:string` |  |  |
| `count` | `:any` | `nil` |  |
| `count_label` | `:string` | `nil` |  |
| `over_limit` | `:boolean` | `false` |  |
| `hint` | `:string` | `"empty"` | `empty`, `always` |
| `active` | `:boolean` | `false` |  |
| `color` | `:string` | `nil` | `nil`, `neutral`, `info`, `warning`, `primary`, `accent`, `success` |
| `limit` | `:integer` | `nil` |  |
| `meta` | `:string` | `nil` |  |
| `total` | `:string` | `nil` |  |
| `progress` | `:integer` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:empty>` - attrs: `title`, `icon`
- `<:footer>`
- `<:icon>`
- `<:inner_block>`

## `<.kanban_card>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `item` | `:any` | `nil` |  |
| `risk` | `:boolean` | `false` |  |
| `dense` | `:boolean` | `false` |  |
| `grip` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:inner_block>` (required)

## `<.kanban_lost>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `count` | `:integer` | `nil` |  |
| `meta` | `:string` | `nil` |  |
| `list` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>`
