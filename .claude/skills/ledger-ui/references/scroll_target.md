# LedgerUI.Components.ScrollTarget

`scroll_target/1`: scrolls smoothly to a block when the server changes `target`.

    <.scroll_target id="purchase-detail-1" target={@focus} block="nearest" />

    <section data-block="contracts">...</section>
    <section data-block="alternatives">...</section>

Renders a hidden element; the hook `LedgerUI.ScrollTarget`
(`priv/static/ledger_ui/hooks/scroll_target.js`) scrolls to `[data-block="<target>"]` once each
time `target` changes (also when it mounts with one). A re-render with the same `target` does
not scroll; `nil` or `""` does nothing. With `prefers-reduced-motion: reduce` the scroll is
instant. A `target` with no matching element does nothing.

`block` is where the element lands (`start`, `center`, `end`, `nearest`).

## Scope

By default the block is searched in the whole document (the first `[data-block=...]`). Set
`scope` to a CSS selector to search only inside that container, so two panels that use the
same block names do not clash:

    <.scroll_target id="st-1" target={@focus} scope="#purchase-detail-1" />

## From the server

`LedgerUI.scroll_to(socket, selector, opts)` scrolls to any selector, once, with no component
(`block:` and `scope:` as above):

    {:noreply, LedgerUI.scroll_to(socket, ~s([data-block="contracts"]), block: "start")}

## `<.scroll_target>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  | Needed by the hook. |
| `target` | `:string` | `nil` | Value of `data-block` to scroll to; scrolls on change. |
| `block` | `:string` | `"nearest"` | `start`, `center`, `end`, `nearest` |
| `scope` | `:string` | `nil` | Selector of the container searched; the whole document when `nil`. |

Any other HTML/phx attribute goes to the root element.
