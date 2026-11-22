# LedgerUI.Components.Clipboard

Copy to clipboard: `clipboard/1`, a button that copies a text, and `clipboard_input/1`, a
field with a copy button joined to it.

    <.clipboard id="copy-ref" value="LDG-2026-1043" icon>Copiar</.clipboard>
    <.clipboard id="copy-cmd" from="#cmd" icon_only variant="ghost" aria-label="Copiar comando" />
    <.clipboard_input id="api-key" value={@api_key} field_label="Chave de API" readonly />

The buttons are the `button/1` of `color`, `variant` and `size`, styled only with Tailwind
utilities. The hook `LedgerUI.Clipboard` (`priv/static/ledger_ui/hooks/clipboard.js`) does the
copy (`navigator.clipboard`, with a `execCommand` fallback), then for two seconds:

  * turns the button into the copied state (`success` colour, `soft` variant, `data-copied`;
    the class list comes from `data-lu-copied-class`) and shows `copied_label` in place of the
    label (`[data-part=clipboard-label]`) when given;
  * dispatches `ledger:toast` on the page's toaster (`window` if there is none) with `%{message, kind}` (`kind` is `"success"` or
    `"error"`) when a `toast` is set. Pass `toast={nil}` for none;
  * runs `on_copy`: an event name (pushed with `%{"id" => id}`, to `target` if given) or a
    `%JS{}`.

`value` is the text to copy; `from` is a selector whose field value (or text) is copied instead.
`copied` renders the button already in the copied state.

## `<.clipboard>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  | Needed by the hook. |
| `value` | `:string` | `nil` | The text to copy. |
| `from` | `:string` | `nil` | Selector of the field or element whose text is copied. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |
| `toast` | `:any` | `:default` | Shown after a copy; `nil` or `""` for none. By default the locale's text. |
| `error_toast` | `:string` | `nil` |  |
| `copied` | `:boolean` | `false` | Renders the copied state. |
| `on_copy` | `:any` | `nil` | An event name or a `%JS{}`. |
| `target` | `:any` | `nil` |  |
| `copied_label` | `:string` | `nil` |  |
| `icon` | `:boolean` | `false` | A copy icon before the text (a check while copied). |
| `icon_only` | `:boolean` | `false` | Just the icon; give it an `aria-label`. |
| `color` | `:string` | `"primary"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `variant` | `:string` | `"solid"` | `solid`, `glow`, `outline`, `soft`, `bordered`, `flat`, `ghost` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg`, `xl` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.clipboard_input>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  | The id of the input; the button is `<id>-copy`. |
| `name` | `:string` | `nil` |  |
| `value` | `:string` | `nil` |  |
| `placeholder` | `:string` | `nil` |  |
| `label` | `:string` | `nil` | The button's text; by default the locale's. |
| `field_label` | `:string` | `nil` | The label above the field. |
| `leading_icon` | `:string` | `nil` | An icon at the start of the field. |
| `copied_label` | `:string` | `nil` |  |
| `icon` | `:boolean` | `true` | A copy icon before the label. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |
| `toast` | `:any` | `:default` |  |
| `error_toast` | `:string` | `nil` |  |
| `on_copy` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` | Merged into the wrapper. |

Any other HTML/phx attribute goes to the root element, including `readonly`, `disabled`, `autocomplete`, `form`, `phx-debounce`.
