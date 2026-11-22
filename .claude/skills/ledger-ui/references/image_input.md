# LedgerUI.Components.ImageInput

An image field: the picture (an avatar, a logo) in a round or rounded frame, with an edit
overlay and a small button to remove or revert it.

    <.image_input name="avatar" value={@user.avatar_url} size="lg" />
    <.image_input name="logo" value="/images/logo.png" shape="rounded" />

With a `name` the frame is a file picker: clicking the picture opens the chooser, the chosen
file shows at once and the button puts the first picture back or, with nothing chosen, empties
the field and sets the hidden `<name>_remove` input to `1`. The behaviour lives in the
`LedgerUI.ImageInput` hook (`priv/static/ledger_ui/hooks/image_input.js`).

Without a `name` it is only the frame: `initials` draws a filled
frame with letters, `hover` forces the edit overlay and `progress` draws the upload ring.

Deviations from the README: `size` has no default (`nil` is the design's 88px frame with a
large icon, same as `md`) and `shape` accepts `square` (the design's default radius) and
`wide` too.

## `<.image_input>`

Renders the image field.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` | The name of the file input; `<name>_remove` is the hidden one. |
| `value` | `:string` | `nil` | The address of the picture it holds now. |
| `accept` | `:string` | `".png,.jpg,.jpeg,.webp"` |  |
| `size` | `:string` | `nil` | `nil`, `lg`, `md`, `sm`, `xl` |
| `shape` | `:string` | `"circle"` | `circle`, `rounded`, `square`, `wide` |
| `label` | `:string` | `"Choose a picture"` |  |
| `remove_label` | `:string` | `"Remove or revert the picture"` |  |
| `initials` | `:string` | `nil` | Letters on a filled frame when there is no picture. |
| `hover` | `:boolean` | `false` | Draws the edit overlay (the hover state). |
| `loop` | `:string` | `nil` | `nil`, `hover`, `ring` - Animated demo of a state: `hover` loops the edit overlay, `ring` loops the upload ring. |
| `progress` | `:integer` | `nil` | An upload ring, 0 to 100. |
| `disabled` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
