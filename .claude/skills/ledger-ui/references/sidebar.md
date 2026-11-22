# LedgerUI.Components.Sidebar

The side menu of the shell, in four formats that read the same data:

  * `sections` (default): the brand with a company switcher, groups with an uppercase mono
    label, "settings and help" at the foot and the plan card.
  * `rail`: a 64px rail of icons (logo, home, one icon per group, extra apps in coloured circles,
    the foot items) beside the panel of the active module (title, create button, items, "try"
    shortcuts, trial card).
  * `tree`: the brand with a collapse button, collapsible groups, children joined by a line,
    square coloured icons and the user card at the foot.
  * `nested`: the shadcn/ui sidebar: team switcher, quiet group labels, items with children and
    the user at the foot, both able to open a menu.

        <.sidebar format="rail" nav={MyAppWeb.Nav.items(assigns)} current={@current_path}
          brand={%{name: "Ledger", logo: "S"}} user={%{name: "Marina Costa", email: "marina@ledger.com"}} />

Changing `format` changes how the menu is drawn, never the items.

## `variant`

`"floating"` (default) is the card with corners and a shadow, `"sidebar"` sits flush on the shell
background, `"inset"` drops the card too.

## The menu data

`nav` is a list of maps, in order. A map with `group` is a group, any other is an item.

Item keys: `label`, `icon` (a short name of the table in the README, or any icon name), `navigate`
/ `patch` / `href`, `count`, `badge`, `color`, `children`, `collapsible`, `open`, `active`,
`kbd` (a shortcut at the right), `caret` (`"down"` | `"right"`: a chevron at the end without children), `loose` (drawn outside the column of the items around it), `current`, `match` (`"exact"` | `"prefix"`), `disabled` (a "coming soon" item: a `span` with
`aria-disabled="true"`), `title`, `formats` and `style`.

Group keys: `group`, `icon`, `items`, `collapsible`, `open`, `navigate` / `patch` / `href`,
`footer: true` (the foot of the menu), `action` (`%{label, navigate, icon}`) and `try`
(`%{label, items}`) for the rail panel.

## Configuration

    config :ledger_ui, :shell, sidebar: :sections, nav: {MyAppWeb.Nav, :items}, footer: :version, version: "v1.4.2"

What you pass always wins.

## The foot

`footer`: `"user"` (the user card / the avatar of the rail), `"version"` (the version line:
a status dot, `v1.4.2`, the build and a "What's new" link; `version` is a string or
`%{version, build, navigate, label, title, status}`), `"none"`, or left out (each format's own).

## Collapsing

Styled only with utilities: the menu is the `group/side` of its parts, which read `data-collapsed`.
Every format collapses to icons (tooltips with the label, counts turn into dots) with the
`LedgerUI.Sidebar` hook: `collapsed` is the start, `on_collapse` is pushed with
`%{"id" => id, "collapsed" => boolean}`, the choice is kept in `localStorage["ledger-rail"]`
(`persist`), `rail_toggle/1` collapses it from anywhere and so does Ctrl/Cmd + `shortcut`.
Below 768px the menu is a top bar with a hamburger.

## `<.sidebar>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"sidebar"` |  |
| `format` | `:any` | `nil` |  |
| `nav` | `:list` | `nil` |  |
| `current` | `:any` | `nil` | The current path, matched against the items' links; or, with `<:item>` slots, an item's `name`. |
| `brand` | `:map` | `nil` |  |
| `workspace` | `:map` | `nil` | The workspace the menu belongs to, `%{name:, context:}`: a `brand` (the chart mark, the name and the muted context line) when `brand` is not given. |
| `views_label` | `:string` | `"Views"` | The caption of the group of the `<:view>` items. |
| `user` | `:map` | `nil` |  |
| `footer` | `:any` | `nil` |  |
| `show_user` | `:boolean` | `nil` |  |
| `version` | `:any` | `nil` |  |
| `plan` | `:map` | `nil` |  |
| `trial` | `:map` | `nil` |  |
| `rail_extra` | `:list` | `[]` |  |
| `collapsible` | `:boolean` | `true` |  |
| `match` | `:string` | `"exact"` | `exact`, `prefix` |
| `persist_groups` | `:boolean` | `false` |  |
| `collapsed` | `:boolean` | `false` |  |
| `collapsed_width` | `:integer` | `nil` | The width of the collapsed menu in px (default 60). Sets `--lu-rail-collapsed` on the menu; the variable can also be set in CSS. |
| `persist` | `:boolean` | `true` |  |
| `on_collapse` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `shortcut` | `:string` | `"b"` |  |
| `variant` | `:string` | `"floating"` | `floating`, `sidebar`, `inset` |
| `label` | `:any` | `"Main menu"` |  |
| `collapse_label` | `:string` | `"Collapse menu"` |  |
| `mobile_label` | `:string` | `"Menu"` |  |
| `nav_class` | `:any` | `nil` | Classes of the column that holds the items (an `animate-[…]` utility can highlight them in turn). |
| `flat` | `:boolean` | `false` | Draws the items straight in the menu, without the column that wraps a run of them. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:brand_mark>` - Replaces the logo and the name of the brand.
- `<:item>` - attrs: `icon`, `name`, `navigate`, `patch`, `href`, `badge`, `count`, `tone`, `active`, `label` - A link of the menu, its content the label, instead of `nav` (the same keys as an item of `nav`).
- `<:mobile_drawer>` - Content of the menu body shown only below 768px.
- `<:sidebar_footer>` - At the end of the foot of the menu.
- `<:view>` - attrs: `icon`, `name`, `navigate`, `patch`, `href`, `count`, `label` - A saved view: an item of the group `views_label` after the `<:item>`s.
