# LedgerUI.Components.SignaturePad

A signature field: sign with a finger, a pen or the mouse (pointer events), or type a name
that is set in a handwriting font. The signature leaves as SVG text.

    <.signature_pad field={@form[:signature]} label="Signature" />
    <.signature_pad name="receipt" mode="type" text="Marcos Oliveira" locale="pt_BR" />
    <.signature_pad name="sign" modes={["draw"]} height={220} />

The form gets the SVG (`<svg xmlns=... viewBox="0 0 W H"><path .../></svg>`, `""` while the pad
is empty) through a hidden input named like the field, and every stroke, typed letter or Clear
fires a bubbling `input` event from it. The drawing surface is client-owned
(`phx-update="ignore"
      role="img"
      aria-label={@l.signature_area}`); the hook `LedgerUI.SignaturePad`
(`priv/static/ledger_ui/hooks/signature_pad.js`) redraws it when the server sends another
`value`. Show a saved signature elsewhere as an image, never as raw markup:

    <img src={"data:image/svg+xml;base64," <> Base.encode64(@signature)} alt="Signature" />

`confirm` (a label) and `on_confirm` add a "confirm" button to the footer, as in the design.

## `<.signature_pad>`

Renders the signature pad.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` |  |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `mode` | `:string` | `"draw"` | `draw`, `type` |
| `modes` | `:list` | `["draw", "type"]` |  |
| `text` | `:string` | `""` |  |
| `name_input` | `:boolean` | `true` | Show the field to type the name in `type` mode. `false` draws the typed `text` alone in the surface (a read-only display, as in the design's canvas). |
| `ink` | `:string` | `"#0F172A"` |  |
| `height` | `:integer` | `170` |  |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `labels` | `:map` | `%{}` |  |
| `disabled` | `:boolean` | `false` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `classic` |
| `footer` | `:boolean` | `true` |  |
| `confirm` | `:string` | `nil` | Label of a confirm button in the footer. |
| `on_confirm` | `:string` | `nil` |  |
| `on_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
