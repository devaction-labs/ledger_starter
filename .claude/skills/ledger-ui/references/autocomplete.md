# LedgerUI.Components.Autocomplete

A text input with a list of suggestions under it. The person types, the list narrows (or the
server searches) and choosing a suggestion sets the field. Behaviour lives in the
`LedgerUI.Autocomplete` hook (`priv/static/ledger_ui/hooks/autocomplete.js`).

    <.autocomplete field={@form[:customer_id]} label="Customer" options={@customers}
                   on_search="search_customers" placeholder="Pick a customer" clearable />

    <.autocomplete field={@form[:city]} options={["Salvador", "Santos"]} free_text />

The choice is submitted through a hidden input named like the field; the visible input only
shows the label. A bubbling `input` event fires from the hidden input, so a surrounding
`phx-change` runs. With `free_text` the typed text is the value.

Without `on_search` the list filters itself on the client (ignoring case and accents). With it
the hook pushes `%{"id" => id, "query" => text}` (after `debounce` ms and `search_threshold`
characters) to `target` or the LiveView, shows `loading_text` until the reply and the server
answers by re-rendering `options`. Options may carry `:hint` (a dimmed note at the right),
`:icon`, `:initials` (an avatar, `:tone` `"t1"`..`"t5"` picks its color, else taken from the label) and `:disabled`.

## `<.autocomplete>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `label_hint` | `:string` | `nil` | Muted text beside the label (`opcional`). |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `options` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `display_value` | `:string` | `nil` |  |
| `free_text` | `:boolean` | `false` |  |
| `on_search` | `:string` | `nil` |  |
| `debounce` | `:integer` | `300` |  |
| `search_threshold` | `:integer` | `0` |  |
| `target` | `:any` | `nil` |  |
| `open_on_focus` | `:boolean` | `false` |  |
| `clearable` | `:boolean` | `false` |  |
| `clear_label` | `:string` | `nil` |  |
| `no_results` | `:string` | `nil` |  |
| `loading_text` | `:string` | `nil` |  |
| `create` | `:string` | `nil` |  |
| `on_create` | `:any` | `nil` |  |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `open` | `:boolean` | `false` | Renders the list open (static previews). |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element, including `autofocus`, `form`, `required`.

Slots:

- `<:option>`
- `<:prefix>`
