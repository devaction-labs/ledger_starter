# LedgerUI.Components.ThemePicker

Lets the user choose a named palette: a menu in the top bar or a grid of previews on a settings
page. Each option previews its own colors.

    <.theme_picker id="palette" />
    <.theme_picker id="palette" variant="grid" />
    <.theme_picker id="palette" themes={~w(ledger noite)} label="Tema" />

The palette is apart from the mode: `theme_switch/1` picks light, dark or system, the picker
picks which palette. The `LedgerUI.ThemePicker` hook puts the choice on
`<html data-palette>`, keeps it in `localStorage["ledger-palette"]`, marks the option and tells every
picker through the `ledger:palette` window event. `on_change` also pushes `%{"theme" => id}` to
the LiveView. Put `<.theme_script theme="..." />` in the root layout so the stored palette is on
before the first paint.

`assets/css/ledger_ui.css` ships two palettes, `ledger` (default) and `crepusculo` (`<html data-palette="crepusculo">`:
indigo brand, Inter Tight headings, its own hero and auth art); `themes/0` lists them first-class next to
the sample previews. Pass `themes={~w(ledger crepusculo)}` for the real ones.

`themes` takes ids of the built-in list (`themes/0`) or maps `%{id, label}` (optionally `bg`,
`accent`, `ink` for the preview).

## `<.theme_picker>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `variant` | `:string` | `"menu"` | `menu`, `grid` |
| `themes` | `:list` | `nil` | Ids or `%{id, label}` maps; default `themes/0`. |
| `default` | `:string` | `nil` | The theme shown when nothing is stored. |
| `current` | `:string` | `nil` | The same as `default`. |
| `label` | `:string` | `"Theme"` |  |
| `placement` | `:string` | `"bottom-end"` | `bottom-end`, `bottom-start` |
| `on_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `open` | `:boolean` | `false` | `variant="menu"`: a static preview of the open menu, in the flow and without the trigger. |
| `loop` | `:boolean` | `false` | `variant="grid"`: the demo motion, each box takes the highlight in turn. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
