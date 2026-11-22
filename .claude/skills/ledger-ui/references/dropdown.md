# LedgerUI.Components.Dropdown

Dropdown menu: a button (or any trigger) that opens a floating menu of links and actions.

    <.dropdown id="actions" label="Ações">
      <.dropdown_item phx-click="edit"><:icon><.icon name="edit" /></:icon>Editar</.dropdown_item>
      <.dropdown_separator />
      <.dropdown_item danger phx-click="delete">Excluir</.dropdown_item>
    </.dropdown>

    <.dropdown id="row" toggle_icon="dots" toggle_label="Mais ações" placement="bottom-end">
      <.dropdown_item href="#">Abrir</.dropdown_item>
    </.dropdown>

Styled only with Tailwind utilities; every element carries `data-part` (`dropdown`,
`dropdown-menu`, `pop`, `pop-item`, `pop-separator`, `pop-label`, `pop-head`, `pop-search`,
`pop-foot`, `pop-end`, `pop-kbd`, `dropdown-split`, `dropdown-kebab`...). The `pop-*` parts and the
helpers `pop_classes/1`, `item_classes/1`... are shared with `LedgerUI.Components.ContextMenu`. `action_button/1`, the direct button of an item with
a single action, lives here too.

## Markup

The root is the anchor (`relative inline-flex`); the menu is a `span` (`data-part="dropdown-menu"`,
`data-lu-placement`) holding the `pop` box. Everything dynamic (open state, ARIA, positioning, keys, click outside, scroll
following, flipping) is done by the hook `LedgerUI.Dropdown`
(`priv/static/ledger_ui/hooks/dropdown.js`), which puts the menu in the top layer
(`popover="manual"`, `position: fixed`) under the trigger. The server renders the ARIA and the
initial state: `popover="manual"` on the menu, `role="menu"` on the box, `role="menuitem"`
(`menuitemcheckbox`/`menuitemradio`, `separator`) on the parts and, on the built-in triggers,
`aria-haspopup="menu"`, `aria-expanded` and `aria-controls`; the hook only flips
`aria-expanded` and the open state. A custom `:toggle` slot receives those trigger attributes
as its argument (`<:toggle :let={t}><button {t}>...</button></:toggle>`); when it does not
spread them the hook falls back to setting `aria-haspopup`/`aria-controls` on that trigger.
Options that differ from the defaults reach the hook as `data-*`
attributes on the root (`data-offset`, `data-hover`, `data-keep-submenus`,
`data-close-on-select`, `data-on-open`, `data-on-close`).

`LedgerUI.open/close/toggle` work with the dropdown `id`.

## Additions to the design README

  * `menu_style` - inline style of the menu box (`width:220px`); `anchor_class` - extra
    classes of the root.
  * `demo` (`"click"`/`"loop"`) - the animated demo: the menu is drawn open under the trigger
    (no top layer) and fades in and out; `highlight` walks a highlight over the items
    (stagger them with `style="--dl:1s"`).
  * `:overlay` slot - extra content after the menu inside the anchor (a demo cursor).
  * `dropdown_item` accepts `danger`, `selected` and a `:trailing` slot, `kbd` (one key cap, verbatim) and
    `two_line` (the taller height for a `description`).
  * Row actions (the "⋯" menu of a row): `trigger_style="ghost"` (a ghost "⋯" button named by `label`, or
    the `:trigger` slot), a `:title` slot (muted heading line), `row_mark` (tints the table row while open),
    `part` (the `data-part` prefix: `"action-menu"` gives `action-menu`/`action-menu-trigger`/`action-menu-panel`)
    and `hook` (the `phx-hook` name).

## `<.dropdown>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `label` | `:string` | `nil` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `mono` |
| `toggle_icon` | `:string` | `nil` | `nil`, ``, `dots`, `dots-vertical` |
| `toggle_class` | `:any` | `nil` |  |
| `toggle_label` | `:string` | `nil` |  |
| `shape` | `:string` | `nil` | `nil`, ``, `rounded`, `pill`, `square` |
| `control` | `:boolean` | `false` |  |
| `open` | `:boolean` | `false` |  |
| `hover` | `:boolean` | `false` |  |
| `placement` | `:string` | `"bottom-start"` | `bottom-start`, `bottom`, `bottom-end`, `top-start`, `top`, `top-end`, `left-start`, `left`, `left-end`, `right-start`, `right`, `right-end` |
| `offset` | `:integer` | `4` |  |
| `close_on_select` | `:boolean` | `true` |  |
| `keep_submenus` | `:boolean` | `false` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `demo` | `:string` | `nil` | `nil`, `click`, `loop` - The animated demo: the menu is drawn open (no top layer); `click` presses the trigger and drops the menu, `loop` fades it in and out. |
| `highlight` | `:boolean` | `false` | Walks a highlight over the items (set `style="--dl:1s"` on each for the stagger). |
| `class` | `:any` | `nil` | Merged into the menu box. |
| `menu_style` | `:string` | `nil` |  |
| `anchor_class` | `:any` | `nil` | Extra classes of the root. |
| `part` | `:string` | `"dropdown"` | The `data-part` prefix. `"dropdown"` gives `dropdown`/`dropdown-toggle`/`dropdown-menu`; any other value gives `<part>`/`<part>-trigger`/`<part>-panel` (`"action-menu"` is the row-actions menu). |
| `trigger_style` | `:string` | `"default"` | `default`, `ghost` - `ghost` is the row-actions trigger: a ghost icon button (the "⋯" icon, or the `:trigger` slot) whose accessible name is `label`, with no chevron. |
| `row_mark` | `:boolean` | `false` | While open, the hook marks the nearest `[data-am-row]`, `tr` or `.ledger-ctable-row` with `data-am-open` and tints it (`data-row-mark` on the root). |
| `hook` | `:string` | `"LedgerUI.Dropdown"` | The `phx-hook` name (the `row_mark` attribute turns the row marking on). |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - attrs: `href`, `navigate`, `patch`, `type`, `disabled`, `class`, `id`, `phx-click`, `phx-target`, `phx-value-id`
- `<:inner_block>` (required)
- `<:overlay>`
- `<:title>` - A muted heading line at the top of the menu (`data-part="pop-label"`).
- `<:toggle>`
- `<:trigger>` - The label of the button that opens the menu, as markup (instead of `label`).

## `<.dropdown_item>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `error` |
| `variant` | `:string` | `"default"` | `default`, `media` |
| `disabled` | `:boolean` | `false` |  |
| `shortcut` | `:string` | `nil` |  |
| `kbd` | `:string` | `nil` | One key cap shown verbatim at the end (`shortcut` splits on spaces into one cap per key). `shortcut` wins when both are given. |
| `two_line` | `:boolean` | `false` | The taller item height of `variant="media"` for a `description`, keeping the plain `menuitem` role. |
| `description` | `:string` | `nil` | A second, muted line under the label. With `variant="media"` the label is always wrapped in its two-line block. |
| `type` | `:string` | `"button"` |  |
| `danger` | `:boolean` | `false` |  |
| `selected` | `:boolean` | `false` | Check mark at the end. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `replace`, `download`, `target`, `rel`, `hreflang`, `referrerpolicy`, `form`, `name`, `value`.

Slots:

- `<:icon>`
- `<:inner_block>` (required)
- `<:trailing>`

## `<.dropdown_separator>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.menu_panel>`

The menu box on its own, always visible and in the flow of the page (no trigger, no top layer, no hook):
the same surface as the open menu of `dropdown/1` and `context_menu/1`. For a menu shown
in the page (docs, previews, a static list of actions).

    <.menu_panel width="w-[230px]">
      <.dropdown_item><:icon><.icon name="edit" /></:icon>Rename</.dropdown_item>
      <.dropdown_separator />
      <.dropdown_item danger>Delete</.dropdown_item>
    </.menu_panel>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `width` | `:string` | `nil` | A width utility of the box (`"w-[230px]"`); by default `min-w-[220px]`. |
| `highlight` | `:boolean` | `false` | Walks a highlight over the items (set `style="--dl:1s"` on each for the stagger). |
| `class` | `:any` | `nil` | Layout only (`mt-4`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required) - `dropdown_item`s, separators and labels.

## `<.dropdown_label>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.dropdown_header>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `subtitle` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.dropdown_search>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `placeholder` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `phx-debounce`, `phx-throttle`, `autocomplete`, `form`.

## `<.dropdown_checkbox>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `checked` | `:boolean` | `false` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` | `"true"` |  |
| `id` | `:string` | `nil` |  |
| `count` | `:any` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`.

Slots:

- `<:inner_block>` (required)

## `<.dropdown_radio>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `checked` | `:boolean` | `false` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` | `"true"` |  |
| `id` | `:string` | `nil` |  |
| `count` | `:any` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`.

Slots:

- `<:inner_block>` (required)

## `<.dropdown_submenu>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `label` (required) | `:string` |  |  |
| `placement` | `:string` | `"right"` | `right`, `left` |
| `disabled` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |
| `trigger_class` | `:any` | `nil` |  |
| `count` | `:integer` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>`
- `<:inner_block>` (required)

## `<.dropdown_footer>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |
| `clear_label` | `:string` | `nil` |  |
| `apply_label` | `:string` | `nil` |  |
| `apply_count` | `:integer` | `nil` |  |
| `on_clear` | `:any` | `nil` |  |
| `on_apply` | `:any` | `nil` |  |
| `close_on_apply` | `:boolean` | `true` |  |
| `apply_color` | `:string` | `"primary"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `mono` |
| `show_apply` | `:boolean` | `true` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.action_button>`

A `button/1`-looking icon button for an item with a single action (`danger` makes it the `error`
colour). `data-part="action-button"`.

    <.action_button label="Delete" icon="huge-delete-02" danger phx-click="delete" />

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  | Accessible name (`aria-label`). |
| `icon` | `:string` | `nil` |  |
| `danger` | `:boolean` | `false` |  |
| `variant` | `:string` | `"outline"` | `solid`, `glow`, `outline`, `soft`, `bordered`, `flat`, `glass`, `ghost`, `dim` |
| `size` | `:string` | `"sm"` | `xs`, `sm`, `md`, `lg`, `xl` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `target`, `rel`, `form`, `name`, `value`, `disabled`, `type`.

Slots:

- `<:inner_block>`
