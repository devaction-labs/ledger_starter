# LedgerUI.Components.Persist

`persist/1`: keeps a piece of LiveView state in the browser and gives it back when it mounts.

    <.persist
      id="agent-widget"
      key="agent_widget"
      storage="session"
      value={%{open: @open?, conversation_id: @cid}}
      on_restore="aw_restore"
    />

    def handle_event("aw_restore", %{"value" => %{"open" => open?, "conversation_id" => cid}}, socket),
      do: {:noreply, assign(socket, open?: open?, cid: cid)}

Renders a hidden element; the hook `LedgerUI.Persist` (`priv/static/ledger_ui/hooks/persist.js`)
writes `value` (as JSON) under `key` in `sessionStorage` or `localStorage` (`storage`) on every
`mounted` and `updated`, unless it did not change.

On mount, when something is saved under `key` and it differs from the current `value`, the hook
pushes `on_restore` with `%{"value" => saved}` **before** writing, and does not write the current
value over it (the server's reply, `updated`, writes the restored one). So the saved value
survives a `push_navigate`: the next mount restores it. A value that is not valid JSON is
ignored (and overwritten by the next write). Storage that is blocked or full is ignored too.

> #### Not a place for secrets {: .warning}
> The value stays in the browser (readable by any script of the page and by the user, and in
> `localStorage` it outlives the tab). Do not put tokens, passwords or personal data in it, and
> do not trust it: it is user input when it comes back through `on_restore`, so validate it in
> the `handle_event`.

`target` is the `phx-target` of `on_restore` (a selector or `@myself`). Give each persisted state
its own `id` and `key`.

## `<.persist>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  | Needed by the hook. |
| `key` (required) | `:string` |  | The storage key. |
| `value` (required) | `:any` |  | Anything that encodes to JSON. |
| `storage` | `:string` | `"session"` | `session`, `local` |
| `on_restore` | `:string` | `nil` | Event pushed with `%{"value" => saved}`. |
| `target` | `:any` | `nil` | `phx-target` of `on_restore`. |

Any other HTML/phx attribute goes to the root element.
