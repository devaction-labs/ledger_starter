# LedgerUI.Components.Accordion

A list of sections that open under their titles (`<.accordion>` with `<.accordion_item>`).

    <.accordion id="faq" variant="bordered">
      <.accordion_item id="faq-1" title="Accordion Item 1" open>
        <p>Lorem ipsum dolor sit amet.</p>
      </.accordion_item>
      <.accordion_item id="faq-2" title="Accordion Item 2">...</.accordion_item>
    </.accordion>

    <.accordion id="help" variant="primary" color="warning">...</.accordion>

Variants: `canvas` (default), `basic`, `border-bottom`, `bordered`, `divided`, `primary` and
`advanced` (a `:header` of your own per item, with the chevron at its end). `color` tints the
`primary` style. One section is open at a time; `multiple` lets them open independently.

The browser owns which sections are open (the `LedgerUI.Collapse` hook,
`priv/static/ledger_ui/hooks/collapse.js`); the server's `open` wins when it changes,
`LedgerUI.open/close/toggle("faq-1")` work and `on_open` / `on_close` push `%{"id" => item_id}`
when they are event names. The ARIA is rendered by the server: the header is a `role="button"`
with `tabindex="0"`, `aria-expanded` and `aria-controls`, the body a `role="region"` labelled by
the header; the hook only updates `aria-expanded`.

## `<.accordion>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `variant` | `:string` | `"canvas"` | `advanced`, `basic`, `border-bottom`, `bordered`, `canvas`, `divided`, `primary` |
| `color` | `:string` | `"primary"` | `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `multiple` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` - `accordion_item/1`s, after the `<:item>`s.
- `<:item>` - attrs: `title`, `open`, `id`, `class` - A section, its content the body: one `accordion_item/1`, with the id `<id>-<position>`.

## `<.accordion_item>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `title` | `:string` | `nil` |  |
| `open` | `:boolean` | `false` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `toggle_label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `trigger_class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:header>`
- `<:inner_block>`
