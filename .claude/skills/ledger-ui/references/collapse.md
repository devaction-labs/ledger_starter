# LedgerUI.Components.Collapse

A section that opens and closes under its trigger (`<.collapse>`) and a text clamped to a few
lines with a "show more" link (`<.collapse_text>`).

    <.collapse id="details">
      <:trigger>Shipping details</:trigger>
      <p>Ships in two days.</p>
    </.collapse>

    <.collapse id="files" open chevron="down" variant="section">
      <:trigger>My files</:trigger>
      ...
    </.collapse>

    <.collapse_text id="desc" lines={2} more="Show more" less="Show less">
      Long text...
    </.collapse_text>

`collapse` is a native `<details>`: the trigger works with the mouse and the keyboard and the
browser owns `open`; when the server changes `open`, the server wins. `LedgerUI.open/close/toggle("id")`
open and close it too. `on_open` / `on_close` run on every toggle (an event name pushes
`%{"id" => id}` to the LiveView or `target`; a `%JS{}` is run as is). The `LedgerUI.Collapse` hook
(`priv/static/ledger_ui/hooks/collapse.js`) provides the events and the chevron's turn.

`variant` is the design canvas section by default; `classic` (or `nil`) leaves the trigger to its
`class`; `framed`, `flat` and `section` are the other ready-made looks.

## `<.collapse>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `chevron` | `:string` | `nil` | `nil`, ``, `down`, `right` |
| `variant` | `:string` | `"canvas"` | `nil`, ``, `classic`, `framed`, `flat`, `section`, `canvas` |
| `panel_class` | `:any` | `nil` |  |
| `chevron_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
- `<:trigger>` (required) - attrs: `class`, `style`

## `<.collapse_text>`

A text clamped to `lines` lines, with a link under it that shows the rest and hides it again.
Works in the browser (no event to the server); the link has `aria-expanded` and `aria-controls`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `lines` | `:integer` | `2` |  |
| `open` | `:boolean` | `false` |  |
| `more` | `:string` | `"Show more"` |  |
| `less` | `:string` | `"Show less"` |  |
| `class` | `:any` | `nil` |  |
| `text_class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
