# LedgerUI.Components.Switch

A switch: a checkbox drawn as a track and thumb, for an effect that is immediate.

    <.switch name="notify" label="Notifications" color="primary" />
    <.switch field={@form[:public]} label="Public" variant="outline" color="success" filled />
    <.switch name="dense" size="sm" shape="pill" thumb_inset={4} checked />
    <.switch name="email" label="Email" label_position="left" wrapper_class="w-full justify-between" />

With a `name` (or `field`) the switch holds a real, visually hidden checkbox (so the form,
the keyboard and `phx-change` work) and, like `checkbox/1`, sends `unchecked_value` through a
hidden input when off. The track and `aria-checked` flip in the browser with
`Phoenix.LiveView.JS`, no round trip (`aria-checked` draws the on look); without a name the label itself is the click target.

`shape` is `squircle` (the default look) or `pill`. `thumb_inset` (2..6 px) puts the thumb away
from the edge: the higher, the smaller it is; left `nil` it is 3px. Extra
HTML attributes go to the `<input>` (or to the label when there is no name).

## `<.switch>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `checked` | `:boolean` | `nil` |  |
| `checked_value` | `:string` | `"true"` |  |
| `unchecked_value` | `:string` | `"false"` |  |
| `hidden_input` | `:boolean` | `true` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `variant` | `:string` | `"basic"` | `basic`, `outline` |
| `filled` | `:boolean` | `false` |  |
| `shape` | `:string` | `"squircle"` | `pill`, `squircle` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `thumb_inset` | `:integer` | `nil` | `nil`, `2`, `3`, `4`, `5`, `6` |
| `label` | `:string` | `nil` |  |
| `label_position` | `:string` | `"right"` | `right`, `left` |
| `label_class` | `:any` | `nil` |  |
| `description` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | Demo animation (CSS only): the switch turns on and off by itself. |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`, `required`.

Slots:

- `<:inner_block>`
