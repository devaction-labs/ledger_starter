# LedgerUI.Components.FilterMenu

A filter button that opens a menu of filters: one row per group that opens a second panel to
its side with the group's options as checkboxes (or radios), plus flat sections (a sort order)
in the same menu. Behaviour lives in the `LedgerUI.FilterMenu` hook
(`priv/static/ledger_ui/hooks/filter_menu.js`): opening, submenus, keyboard (arrows, Enter,
Esc, `ArrowRight` into a submenu) and staging never leave the browser.

    <.form for={@form} phx-submit="apply_filters">
      <.filter_menu id="orders-filter" label="Filtrar" locale="pt_BR" variant="outline" size="sm"
        groups={[
          %{name: "filter[status]", label: "Status", icon: "checkmark-circle-02",
            value: @filter["status"],
            options: [{"Faturado", "invoiced", 3}, {"Aprovado", "approved", 2}]},
          %{name: "filter[sort]", label: "Ordenar por", caption: "Ordenar por",
            display: :section, type: :single, value: @filter["sort"],
            options: [{"Mais recentes", "recent"}, {"Maior valor", "value"}]}
        ]} />
    </.form>

Every option is a real input (`filter[status][]` for a multiple group, `filter[sort]` for a
single one), so a form posts them. In `mode="apply"` (default) ticks only stage: the group's
row shows how many are staged, Apply shows how many records they leave (the options' `count`,
or `results`), Clear unticks the filter groups and closing the menu any other way takes the
staged values back; the trigger shows how many values are applied (the groups' `value`).
`mode="live"` has no Apply: every tick reaches the form's `phx-change` and `on_change`.

`on_change`, `on_apply` and `on_clear` push `%{"id" => id, "values" => %{group_name => [..] | "x"}}`
to `target`. A `:single` group takes `custom: true` (or the row's text): a last row that
opens two date fields; the value is then `"custom:FROM..TO"` (ISO days), parsed by
`custom_range/1`. A `:group` slot takes the same attributes as a group and your own content
(any checkbox/radio inputs with a `name`, and `data-lu-count` for what Apply counts).

With no groups and no `:group` slot the panel shows a small empty state (`empty_label`, default
"No filters available" / "Nenhum filtro disponível") and hides the Clear/Apply footer.

## Locale

The texts (Filters, Clear, Apply, Custom…, From, To, results, empty state) follow the `locale`
attr: `"en"` (the default) or `"pt_BR"`. There is no application-wide locale config
(`config :ledger_ui, locale:` does not exist): pass `locale="pt_BR"` on every `filter_menu`
of a pt-BR page, or wrap it in your own function component that sets it.

## `<.filter_menu>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `label` | `:string` | `nil` |  |
| `icon` | `:string` | `nil` |  |
| `empty_label` | `:string` | `nil` | Text of the empty panel (no groups, no `:group` slot). |
| `groups` | `:list` | `[]` |  |
| `mode` | `:string` | `"apply"` | `apply`, `live` |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `results` | `:integer` | `nil` |  |
| `variant` | `:string` | `"outline"` | `solid`, `glow`, `outline`, `soft`, `bordered`, `flat` |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg`, `xl` |
| `dashed` | `:boolean` | `false` |  |
| `placement` | `:string` | `"bottom-start"` | `bottom`, `bottom-end`, `bottom-start`, `left`, `left-end`, `left-start`, `right`, `right-end`, `right-start`, `top`, `top-end`, `top-start` |
| `open` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `on_apply` | `:string` | `nil` |  |
| `on_clear` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:group>` - attrs: `name`, `label`, `icon`, `display`, `type`, `caption`, `custom`, `value`
- `<:trigger>` - The text of the button, as markup (instead of `label`).
