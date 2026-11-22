# LedgerUI.Components.CommandPalette

A dialog opened with Ctrl K (or `LedgerUI.open/1`) where the person types, narrows the results
by scope and jumps to a page or runs an action from the keyboard (`<.command_palette>`).

    <.command_palette
      id="palette"
      scopes={[{"All", "all"}, {"Pages", "pages"}, {"Actions", "actions"}]}
      items={[
        %{group: "Go to", scope: "pages", label: "Orders", icon: "cart", navigate: "/orders", keys: ["G", "O"]},
        %{group: "Actions", scope: "actions", label: "New order", icon: "plus", value: "new-order"}
      ]}
      assistant={%{label: "Ask the assistant: “%{query}”", sub: "Answers with your data"}}
      on_select="palette-select"
    />

    <.button phx-click={LedgerUI.open("palette")}>Search</.button>

The palette is a modal: `LedgerUI.open/close/toggle`, `open`, `on_open` and `on_close` work as for
`LedgerUI.Components.Modal`, and `shortcut` toggles it from anywhere. The items are filtered in the
browser by label, `sub` and `keywords` (ignoring case and accents) and by scope; with `on_search`
the server filters instead. Arrows move the active row, Enter presses it, Ctrl Enter opens a link
in a new tab and Esc closes. The behaviour comes from the `LedgerUI.Overlay` hook
(`priv/static/ledger_ui/hooks/overlay.js`); the ARIA is rendered by the server: the card is a
`role="dialog"` (`aria-modal`, `aria-label`), the input a `role="combobox"` with
`aria-controls`/`aria-expanded`/`aria-autocomplete`, the list a `role="listbox"` and the rows
`role="option"` with stable ids (`"#{id}-opt-N"`); the hook only moves `aria-selected` and
`aria-activedescendant`. The static previews (`inline`/`bare`) keep the design's `menuitem` rows.

Each item is a map with `label` (required) and optionally `value` (what `on_select` receives),
`sub`, `icon`, `avatar` (`%{initials: "CD", tint: "#d97a1e"}`), `keys` (key names on the right),
`count` (a badge), `group`, `scope`, `keywords`, `style` and one of `navigate`, `patch` or `href`.

Events (`on_select`: `%{"id", "value", "new_tab"}`, `on_assistant`: `%{"id", "query"}`,
`on_search`: `%{"id", "query", "scope"}`, `on_open`/`on_close`: `%{"id"}`) take an event name or a
`%JS{}` and go to `target` when given.

`inline` renders the dialog over its own in-page scrim (a static preview, always open, no hook);
`bare` renders only the `lu-cmd` card.

## `<.command_palette>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `label` | `:string` | `nil` |  |
| `placeholder` | `:string` | `nil` |  |
| `scopes` | `:list` | `[]` |  |
| `scopes_label` | `:string` | `nil` |  |
| `items` | `:list` | `[]` |  |
| `empty` | `:string` | `nil` |  |
| `assistant` | `:map` | `nil` |  |
| `assistant_mode` | `:string` | `"no_match"` | `no_match`, `always` |
| `on_select` | `:any` | `nil` |  |
| `on_assistant` | `:any` | `nil` |  |
| `on_search` | `:string` | `nil` |  |
| `debounce` | `:integer` | `200` |  |
| `query` | `:string` | `""` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `shortcut` | `:any` | `"Mod+k"` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `classic` |
| `hints` | `:boolean` | `true` |  |
| `highlight` | `:string` | `"always"` | `always`, `typed` |
| `hint_navigate` | `:string` | `nil` |  |
| `hint_open` | `:string` | `nil` |  |
| `hint_new_tab` | `:any` | `nil` |  |
| `hint_close` | `:string` | `nil` |  |
| `state` | `:string` | `nil` | `nil`, `no_match` - `"no_match"` draws only the empty-result card (the `empty` text and the assistant row, which the hook shows when nothing matches), a static preview. |
| `class` | `:any` | `nil` |  |
| `list_style` | `:string` | `nil` | Inline style of the list (replaces the variant padding). |
| `inline` | `:boolean` | `false` | Static preview over an in-page scrim: always open, no hook. |
| `bare` | `:boolean` | `false` | Only the `lu-cmd` card, always open, no hook. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:footer>`
- `<:item_icon>`

## `<.command_palette_dialog>`

Same as `command_palette/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `label` | `:string` | `nil` |  |
| `placeholder` | `:string` | `nil` |  |
| `scopes` | `:list` | `[]` |  |
| `scopes_label` | `:string` | `nil` |  |
| `items` | `:list` | `[]` |  |
| `empty` | `:string` | `nil` |  |
| `assistant` | `:map` | `nil` |  |
| `assistant_mode` | `:string` | `"no_match"` | `no_match`, `always` |
| `on_select` | `:any` | `nil` |  |
| `on_assistant` | `:any` | `nil` |  |
| `on_search` | `:string` | `nil` |  |
| `debounce` | `:integer` | `200` |  |
| `query` | `:string` | `""` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `shortcut` | `:any` | `"Mod+k"` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `classic` |
| `hints` | `:boolean` | `true` |  |
| `highlight` | `:string` | `"always"` | `always`, `typed` |
| `hint_navigate` | `:string` | `nil` |  |
| `hint_open` | `:string` | `nil` |  |
| `hint_new_tab` | `:any` | `nil` |  |
| `hint_close` | `:string` | `nil` |  |
| `state` | `:string` | `nil` | `nil`, `no_match` - `"no_match"` draws only the empty-result card (the `empty` text and the assistant row, which the hook shows when nothing matches), a static preview. |
| `class` | `:any` | `nil` |  |
| `list_style` | `:string` | `nil` | Inline style of the list (replaces the variant padding). |
| `inline` | `:boolean` | `false` | Static preview over an in-page scrim: always open, no hook. |
| `bare` | `:boolean` | `false` | Only the `lu-cmd` card, always open, no hook. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:footer>`
- `<:item_icon>`
