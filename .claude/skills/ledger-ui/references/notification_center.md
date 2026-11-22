# LedgerUI.Components.NotificationCenter

A bell with a count when something is unread and, under it, a panel with the notifications
(`<.notification_center>`).

    <.notification_center
      id="notifications"
      items={@notifications}
      on_read="read"
      on_read_all="read_all"
    />

    <.notification_center id="inbox" variant="classic" items={@notifications}
      tabs={[%{id: "all", label: "All"}, %{id: "unread", label: "Unread"}, %{id: "orders", label: "Orders"}]}
      all_href={~p"/notifications"} />

Each item is a map: `title` (required), `body`, `text`, `at`, `group` (day heading shared by consecutive
items), `type` (`info success warning error primary`), `tone` (`lime`...), `icon`, `avatar`
(`%{initials: "FP", tint: "t2"}`), `category` (a tab id), `read`, `id`, and `navigate`, `patch` or `href`.

`body` may be rich (a `Phoenix.HTML.raw/1` string or a rendered `~H` template); in the canvas
rows `text` replaces the whole sentence (bold title, then body) with your own, so a part in the
middle can be bold: `text: raw("Payment received from <b>Acme</b> · $ 3,120.50")`. Only pass
trusted markup there.

The panel is a popover (`LedgerUI.Float` hook, `priv/static/ledger_ui/hooks/float.js`): it closes on a click
outside and on Esc, opens with `LedgerUI.open(socket, id)` and the tabs filter in the browser. Marking as
read is up to the server: change `read` and the dot, the count and the bell follow. `on_read`
pushes `%{"id" => id, "item" => item_id}`, `on_read_all` `%{"id" => id}`, `on_change` the tab
`%{"id" => id, "tab" => tab_id}`; each takes an event name (to `target`) or a `%JS{}`.

`variant="canvas"` is the compact panel (rows only); `classic` has a title bar, tabs and footer.
`count_tone` (or `count_tone` in a tab map) turns the tab counters neutral and highlights only the
one on the selected tab; it is `group-aria-selected:` utilities on the tab, so it follows the
selection without JS and the server-rendered HTML is already right.

`inline` renders only the panel, in the page flow (no bell, no hook).

The `classic` header takes an `:actions` slot (controls after "mark all as read") and `closable`, a
close button that closes the popover and returns focus to the bell (`close_label` is its `aria-label`).

## `<.notification_center>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `items` | `:list` | `[]` |  |
| `tabs` | `:list` | `[%{id: "all", label: "Todas"}, %{id: "unread", label: "Não lidas"}]` |  |
| `unread` | `:integer` | `nil` |  |
| `title` | `:string` | `"Notificações"` |  |
| `bell_label` | `:string` | `"Notificações"` |  |
| `read_all_label` | `:string` | `"Marcar todas como lidas"` |  |
| `preferences_label` | `:string` | `"Preferências de notificação"` |  |
| `close_label` | `:string` | `"Fechar"` |  |
| `all_label` | `:string` | `"Ver todas as notificações"` |  |
| `unread_label` | `:string` | `"não lidas"` |  |
| `empty` | `:string` | `"Nenhuma notificação"` |  |
| `empty_text` | `:string` | `"Quando houver novidades, elas aparecem aqui."` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `classic` |
| `empty_icon` | `:string` | `nil` |  |
| `empty_tone` | `:string` | `"success"` | `neutral`, `primary`, `info`, `success`, `warning`, `error` |
| `all_href` | `:string` | `nil` |  |
| `preferences_href` | `:string` | `nil` |  |
| `on_read_all` | `:any` | `nil` |  |
| `on_read` | `:any` | `nil` |  |
| `on_change` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `count_tone` | `:string` | `nil` | `nil`, `acc`, `pos`, `neg`, `warn`, `info`, `lime`, `primary`, `success`, `error`, `warning` - `classic`: the tone of the tab counters. The highlight follows the selected tab (the others stay neutral). Without it every counter keeps the accent look. A tab can override it with its own `count_tone`. |
| `size` | `:string` | `"md"` | `md`, `sm` - The bell: `md` is 36px, `sm` the 32px button of the top bar (like `navbar_bell size="sm"`). |
| `open` | `:boolean` | `false` |  |
| `placement` | `:string` | `"bottom-end"` |  |
| `arrow` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` | Merged into the panel. |
| `inline` | `:boolean` | `false` | Only the panel, in the page flow: no bell, no hook. |
| `closable` | `:boolean` | `false` | `classic`: a close button at the end of the header (closes the popover, focus goes back to the bell). Ignored when `inline`. |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - `classic`: extra controls at the end of the header, after "mark all as read" and before the close button.
- `<:empty_action>`
