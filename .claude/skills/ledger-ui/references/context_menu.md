# LedgerUI.Components.ContextMenu

A menu that opens under the pointer on a right click.

    <.context_menu id="file-menu">
      <.card variant="panel">Right click here</.card>
      <:item phx-click="rename" icon="edit" kbd="F2">Rename</:item>
      <:item phx-click="copy">Copy</:item>
      <:item phx-click="delete" tone="danger" divider icon="trash">Delete</:item>
    </.context_menu>

The hook `LedgerUI.ContextMenu` (`priv/static/ledger_ui/hooks/context_menu.js`) opens the menu
at the pointer (kept inside the window, in the top layer), moves the focus to the first item
and closes it on a click outside, `Escape`, a scroll and when an item is chosen. The arrows,
`Home`, `End` and letters move between the items.

Styled only with Tailwind utilities (the popup parts are those of
`LedgerUI.Components.Dropdown`); every element carries `data-part` (`context-menu`, `pop`,
`pop-item`, `pop-separator`, `pop-end`, `pop-kbd`).

Besides the README attrs the `:item` slot takes `icon` (a name) and `kbd` (a shortcut shown
as text).

## `<.context_menu>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `label` | `:string` | `"Actions"` | Accessible name of the menu. |
| `class` | `:any` | `nil` |  |
| `placement` | `:string` | `"bottom-start"` | `bottom-start`, `bottom-end`, `top-start`, `top-end` - Where the menu sits against the pointer (`bottom-start`: below, from the pointer to the right). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required) - The area that answers to the right click.
- `<:item>` - attrs: `tone`, `divider`, `disabled`, `icon`, `kbd`, `phx-click`, `phx-value-id`, `phx-target`
- `<:trigger>` - The area that answers to the right click, in place of the inner block (the vitrine's form).
