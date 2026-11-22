# LedgerUI.Components.BulkBar

The bar of bulk actions for a table with selection: how many are selected, optional fields,
buttons for the actions and a close that clears the selection. It shows only while `count` is
above zero.

    <.bulk_bar
      id="orders-bulk"
      count={@count}
      label="selecionado"
      label_plural="selecionados"
      total={@total}
      on_select_all="select_all"
      on_clear="clear_selection"
    >
      <:action icon="file" phx-click="issue">Emitir NF-e</:action>
      <:action icon="download" phx-click="export">Exportar</:action>
      <:action variant="danger" icon="trash" phx-click="delete" confirm="Excluir 3 pedidos?"
        confirm_text="Os rascunhos somem para todos." confirm_label="Excluir" cancel_label="Cancelar">
        Excluir
      </:action>
    </.bulk_bar>

Texts come from outside (`label`, `label_plural`, `select_all_label` with `%{total}`,
`clear_label`); nothing is pluralized here.

## Looks

  * `inverse` (default), `soft` and `solid`: the selection pill (dark, accent-soft and accent).
  * `inline`: the strip at the top of a table (a panel tinted with the accent): a checkbox
    that clears the selection, the count, "select all" and the buttons.

  * `float` (the canvas template's bar): a dark pill absolutely positioned at the
    bottom center of the closest positioned ancestor (the app shell), with the count, one
    `:action` per button (`variant="danger"` is red and set apart by a rule) and the close. It
    ignores `floating`, `progress` and the `confirm` of an action (the action runs at once).

`floating` (default) pins a pill to the bottom center of the viewport; `floating={false}` lays
it out where it is (a bar inside a card or a toolbar). `progress`/`progress_max` turn the bar
into a progress bar while a bulk action runs. Esc runs `on_clear` (`phx-window-keydown`).

An `:action` with `confirm` opens a small card first (above the bar when floating, below
otherwise); only its confirm button runs the action's `phx-click`. A `disabled` action keeps the
focus (`aria-disabled`) and renders no `phx-*` attributes.

Styled only with Tailwind utilities.

## `<.bulk_bar>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `count` (required) | `:integer` |  | How many are selected; the bar shows only above zero. |
| `label` | `:string` | `"selected"` | The text after the count, for one selected. |
| `label_plural` | `:string` | `nil` |  |
| `total` | `:integer` | `nil` | How many there are in all (every page). |
| `select_all_label` | `:string` | `"Select all %{total}"` |  |
| `on_clear` | `:any` | `nil` |  |
| `on_select_all` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `clear_label` | `:string` | `"Clear selection"` |  |
| `check_label` | `:string` | `"Selection"` | `aria-label` of the `inline` checkbox. |
| `show_esc` | `:boolean` | `false` |  |
| `variant` | `:string` | `"inverse"` | `inverse`, `soft`, `solid`, `inline`, `float` |
| `floating` | `:boolean` | `true` |  |
| `progress` | `:integer` | `nil` |  |
| `progress_max` | `:integer` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - attrs: `variant`, `disabled`, `icon`, `confirm`, `confirm_text`, `confirm_label`, `cancel_label`, `id`, `title`, `aria-label`, `phx-click`, `phx-target`, `phx-disable-with`, `phx-value-id` - A button.
- `<:field>` - A control (a select, an input) in the bar.
