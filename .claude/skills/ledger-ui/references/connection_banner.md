# LedgerUI.Components.ConnectionBanner

The notice of a lost connection, as a toast: while the LiveView socket is down the toaster shows
a `loading` toast with the ring of light (`aura`), and removes it when the socket is back.

    <.connection_banner />
    <.connection_banner title="Sem conexão" description="Tentando reconectar..." />

`position="top"` or `"bottom"` puts that toast at the top or the bottom centre (the toaster's own place
when omitted).

Put it once in the root layout, next to the `<.toaster>` (it needs one on the page). It draws
nothing by itself and has no JavaScript of its own: `phx-disconnected` runs `show_toast/2` and
`phx-connected` runs `dismiss_toast/1` (see `LedgerUI.Components.Toast`).

With `preview` it draws the strip of each state instead (for docs and design reviews; it has no
behaviour): `state` is `off` (no connection), `re` (reconnecting, with a turning ring), `on`
(connected) or `cycle` (the three in turn, in a 9s loop).

    <.connection_banner preview state="off" label="Sem conexão" />
    <.connection_banner preview state="cycle" />

## `<.connection_banner>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"ledger-connection-banner"` |  |
| `title` | `:string` | `"Connection lost"` |  |
| `description` | `:string` | `"Trying to reconnect..."` |  |
| `color` | `:string` | `"warning"` | `assistant`, `primary`, `secondary`, `info`, `success`, `warning`, `error` - The light of the ring. |
| `position` | `:string` | `nil` | `nil`, `top`, `bottom` - Where the toast sits: `top` (`center-top`) or `bottom` (`center-bottom`); the toaster's own when `nil`. |
| `preview` | `:boolean` | `false` | Draw the strip of `state` where it is written (no hooks, no toast). |
| `state` | `:string` | `"off"` | `off`, `re`, `on`, `cycle` - Only with `preview`: lost, reconnecting, connected, or all three in a loop. |
| `label` | `:string` | `nil` | Only with `preview`: the text of the strip (default by state; not for `cycle`). |
| `cycle_labels` | `:list` | `["Connection lost. Your changes are kept here.", "Reconnecting…", "Connected again."]` | Only with `preview` and `state="cycle"`: the three texts, in order. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
