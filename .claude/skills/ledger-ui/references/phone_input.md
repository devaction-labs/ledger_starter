# LedgerUI.Components.PhoneInput

A phone number field with a country picker: a button at the left with the ISO code and the
calling code (`BR +55`), and the number input. The number is written in the national format of
the country as it is typed (`(11) 91234-5678`); what the form submits is the E.164 number
(`+5511912345678`).

    <.phone_input field={@form[:phone]} label="Telefone" />
    <.phone_input name="phone" country="US" label="Phone number" />
    <.phone_input field={@form[:phone]} country="PT" country_order={~w(PT BR)} />
    <.phone_input field={@form[:phone]} countries={~w(BR PT AR UY)} clearable />
    <.phone_input name="phone" value="+5511912345678" size="lg" variant="filled" />

`country` is the country the field starts with (`"BR"` by default); a `value` in E.164 selects
its own country. The picker is a searchable list (by name in Portuguese or English, ISO code or
calling code); `country_order` lists the countries shown first, `countries` limits the list and
`except` removes some. ISO codes are shown instead of flag emoji unless `flags` is set.

A hidden input with the field's name carries the E.164 number (empty while there are no
digits) and fires a bubbling `input` event when it changes, so `phx-change` runs; the visible
input has no name. `phx-debounce` and `phx-throttle` go to the hidden input.

## Formatting is not validation

The format only helps reading. Validate on the server with
`LedgerUI.Components.PhoneInput.Format.e164/2`:

    case LedgerUI.Components.PhoneInput.Format.e164(params["phone"], "BR") do
      {:ok, e164} -> e164
      {:error, reason} -> reason
    end

The list is not in the HTML: the markup carries only the ISO codes the field offers, in order
(`data-lu-countries`), and the hook builds the rows when it mounts from the country data shipped
once in `priv/static/ledger_ui/lib/phone_countries.js` (generated from `Format` by
`mix run scripts/gen_phone_countries.exs`). Without JS the field shows the selected country and
takes the number.

The behaviour lives in the `LedgerUI.PhoneInput` hook (`phone_input.js`), so the field needs a
stable `id` (from `field` or `name`).

## `<.phone_input>`

Renders the phone input.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `country` | `:string` | `"BR"` |  |
| `country_order` | `:list` | `[]` |  |
| `countries` | `:list` | `[]` |  |
| `except` | `:list` | `[]` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`: the texts and the country names. Default: the process locale, the app config; the country names are Portuguese when none is set (the texts, English). |
| `flags` | `:boolean` | `false` |  |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `state` | `:string` | `nil` | `nil`, ``, `success`, `error` |
| `disabled` | `:boolean` | `false` |  |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `clearable` | `:boolean` | `false` |  |
| `clear_label` | `:string` | `nil` |  |
| `picker_label` | `:string` | `nil` |  |
| `search_placeholder` | `:string` | `nil` |  |
| `no_results` | `:string` | `nil` |  |
| `on_country_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` | Inline style of the box (e.g. a width). |

Any other HTML/phx attribute goes to the root element, including `autocomplete`, `autofocus`, `form`, `placeholder`, `readonly`, `required`.
