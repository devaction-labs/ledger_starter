# LedgerUI.Components.Hotkey

`hotkey/1`: a global keyboard shortcut that pushes an event to the LiveView or runs a `%JS{}`.

    <.hotkey id="aw-hotkey" keys="Mod+j" on_press={JS.push("aw_toggle")} />
    <.hotkey id="new-chat" keys="Mod+Shift+k, Alt+n" on_press="new_conversation" target={@myself} />
    <.hotkey id="save" keys="Mod+s" on_press="save" in_inputs />

Renders a hidden element; the hook `LedgerUI.Hotkey` (`priv/static/ledger_ui/hooks/hotkey.js`)
listens to `keydown` on the document and removes the listener when the element leaves the DOM.

`keys` is one or more combinations separated by commas. A combination is modifiers and a key
joined by `+`: `Mod`, `Ctrl`, `Cmd` (or `Meta`), `Alt`, `Shift`, then the key (`j`, `Enter`,
`Escape`, `ArrowUp`, `/`, `Space`...). `Mod` is Cmd on macOS and Ctrl elsewhere. The modifiers
must match exactly (`Mod+j` does not fire on `Mod+Shift+j`).

A press while the focus is in an `input`, `select`, `textarea` or `contenteditable` element is
ignored, unless `in_inputs` is set. A matching press calls `preventDefault`, so the browser's own
shortcut (Ctrl+J opens the downloads in Chrome) does not run.

`on_press` is an event name, pushed with `%{"key" => combination}` (to `target` when given: a
selector or a component id, as for `phx-target`), or a `%JS{}` run on the element
(`JS.push("evt", target: @myself)` carries its own target).

## `<.hotkey>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  | Needed by the hook. |
| `keys` (required) | `:string` |  | Combinations separated by commas, e.g. `"Mod+j, Mod+Shift+k"`. |
| `on_press` (required) | `:any` |  | An event name or a `%JS{}`. |
| `target` | `:any` | `nil` | `phx-target` of the event name (a selector or `@myself`). |
| `in_inputs` | `:boolean` | `false` | Also fires while typing in a field. |

Any other HTML/phx attribute goes to the root element.
