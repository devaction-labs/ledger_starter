# LedgerUI.Components.Flow

Workflow editor: steps on a dotted board joined by connections that carry the condition of each
branch, a toolbar at the bottom and the configuration panel of a step on the right.

    <.flow id="triage" edges={@edges} on_add="add_node" on_move="move_node" aria-label="Triage" class="h-[640px]">
      <:node id="in" kind="Trigger" kind_icon="mail" icon="mail" title="Invoice received">
        <.flow_section label="Event">An invoice arrives at the inbox.</.flow_section>
      </:node>
      <:node id="gate" kind="Approval" icon="shield" title="Approval" selected />
      <:toolbar><.button color="primary" size="md">Add node</.button></:toolbar>
      <:panel label="Approval">
        <.flow_panel_head icon="shield" title="Approval" on_close="close_panel" />
        <.flow_panel_body>…fields…</.flow_panel_body>
      </:panel>
    </.flow>

## Layout

The server lays the steps out (no measuring): `edges` is a list of maps with `from` and `to`
(node ids) and optionally `label` and `status` (`"done"` green, `"error"` red; an edge into the
`selected` node takes the accent). A node's row is its depth along the edges, a parent is centred
over its children, and every connection is an SVG path drawn in the gap above its target with the
`label` on it. Without `edges` the nodes are a free grid, four to a row. Rows are
200px tall plus a gap, so keep a step's card about that size; the `LedgerUI.Flow` hook redraws
the connections from the real node boxes.

## Dragging

With `on_move` the nodes can be dragged on the board (pointer events); a drop pushes
`%{"id" => id, "x" => x, "y" => y}` (to `target` when given). Keep the positions on the server
and pass them back as the `x`/`y` of the `:node`; the connections follow while dragging.

Events: `on_add` (the + button under nodes with no outgoing edge, `phx-value-id` of the node),
`on_move` (a node was dragged).

## Branching in the browser

With `steps` (the kinds of step a person may add) every card gets a `+` at its bottom, right and
left edges. A click opens the menu "Add step"; the chosen kind becomes a new card next to that
edge, joined by a connection. A kind with `branches` (a condition) also opens one empty
"Caminho ..." card per branch, each with its labelled connection; a click on an empty card opens
the menu to fill it. Cards are dragged without a round trip, a click selects one and `Delete`
removes it. Everything happens in the `LedgerUI.Flow` hook from `<template>`s rendered here
(so the classes come from this module); `on_branch` is pushed with
`%{"id" => new, "kind" => kind, "from" => id, "side" => "b" | "r" | "l"}` when set.

    <.flow id="auto" steps={[
      %{key: "acao", label: "Ação", title: "Atualizar pedido", sub: "Ação · ERP", icon: "zap", tone: "acc"},
      %{key: "cond", label: "Condição", title: "Valor acima de R$ 1.000?", sub: "Condição", icon: "filter", tone: "warn",
        branches: [%{label: "Sim", tone: "pos"}, %{label: "Não", tone: "neg"}]}
    ]}>
      <:node id="a" title="Pagamento falhou" icon="zap" />
    </.flow>

## `<.flow>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `edges` | `:list` | `[]` |  |
| `on_add` | `:any` | `nil` |  |
| `steps` | `:list` | `[]` | Kinds of step the `+` handles add in the browser: maps with `:key`, `:label`, `:title`, `:sub`, `:icon`, `:tone` (`acc`, `pos`, `neg`, `warn`, `info`, `lime`) and optionally `:branches` (`[%{label: "Sim", tone: "pos"}]`). |
| `on_branch` | `:string` | `nil` | Event pushed after a step is added in the browser (`id`, `kind`, `from`, `side`). |
| `menu_label` | `:string` | `"Add step"` |  |
| `ghost_label` | `:string` | `"Choose a step"` |  |
| `branch_label` | `:string` | `"Path"` |  |
| `on_move` | `:string` | `nil` | Event pushed when a node is dragged (`id`, `x`, `y`). |
| `target` | `:any` | `nil` | `phx-target` of `on_move`. |
| `add_label` | `:string` | `"Add step after"` |  |
| `node_width` | `:integer` | `300` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - Buttons beside the selected node; the node id is the slot argument.
- `<:hint>` - attrs: `title`, `left`, `top`, `width`, `class`
- `<:node>` (required) - attrs: `id`, `title`, `icon`, `kind`, `kind_icon`, `status`, `selected`, `class`, `metrics`, `x`, `y`
- `<:panel>` - attrs: `label`
- `<:toolbar>`

## `<.flow_section>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.flow_chips>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.flow_chip>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.flow_panel_head>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` (required) | `:string` |  |  |
| `icon` | `:string` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `close_label` | `:string` | `"Close"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.flow_panel_tabs>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.flow_panel_body>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.flow_panel_foot>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
