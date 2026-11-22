# LedgerUI.Components.Spinner

Short loading indicator: five designs, five sizes and the system colours. Styled only with
Tailwind utilities (the colour enters as `--c`, see `LedgerUI.Color`).

    <.spinner color="primary" variant="soft" size="md" label="Saving" />

With a `label` (default `"Loading"`) it is `role="status"` and `aria-label`led; pass
`label={nil}` for a purely decorative one. `white` and `current` (the surrounding text colour)
are for spinners inside filled buttons.

## `<.spinner>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `white`, `current` |
| `variant` | `:string` | `"canvas"` | `canvas`, `border`, `soft`, `grow`, `svg` |
| `size` | `:string` | `"sm"` | `xs`, `sm`, `md`, `lg`, `xl` |
| `elastic` | `:boolean` | `false` | An elastic easing instead of the default one. |
| `label` | `:any` | `"Loading"` | Accessible name; `nil` for a decorative spinner. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
