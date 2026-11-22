# LedgerUI.Components.Alert

Persistent inline notice with colour, variant, shape, accent stripe, actions and a close button.
Styled only with Tailwind utilities (the colour enters as `--c`/`--c-on`/`--c-soft`/`--c-ink`, see
`LedgerUI.Color`).

    <.alert color="warning" variant="soft" title="Certificate expires in 12 days"
            description="Renew it to keep issuing.">
      <:icon><.icon name="alert" /></:icon>
      <:action><.button color="warning" variant="soft" size="xs">Renew</.button></:action>
    </.alert>

    <.alert id="saved" color="success" dismissible on_dismiss="hide_notice">Changes saved.</.alert>

`loop` plays the canvas loop of the alert entering (`mo-alin`, CSS only).

`title` is the bold line and `description` the line under it; any other content goes in the
inner block (a `<b>` inside it is bold too). The close button hides the alert in the browser (no
round trip) and, with `on_dismiss`, tells the server (`%{"id" => id}`). `dismiss_alert/1` does the
same for a button placed by hand: `<button phx-click={dismiss_alert()}>Later</button>`.

## `<.alert>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `color` | `:string` | `"neutral"` | `nil`, `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `dark` |
| `variant` | `:string` | `"canvas"` | `nil`, `canvas`, `solid`, `outline`, `soft`, `bordered` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `accent` | `:any` | `nil` | `nil`, ``, `true`, `top`, `left`, `right` - The colored stripe: `top` (or just `accent`), `left`, `right`. |
| `description` | `:string` | `nil` | The line under the title (`title="..."`). |
| `dismissible` | `:boolean` | `false` |  |
| `on_dismiss` | `:any` | `nil` | Event name or `%JS{}` run when the alert is closed. |
| `target` | `:any` | `nil` | `phx-target` of `on_dismiss`. |
| `close_label` | `:string` | `"Close"` |  |
| `open` | `:boolean` | `true` |  |
| `loop` | `:boolean` | `false` | The canvas loop (`mo-alin`): the alert slides in, stays, leaves, forever (demos). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - Controls after the content.
- `<:icon>` - attrs: `boxed` - Icon before the content.
- `<:inner_block>`
