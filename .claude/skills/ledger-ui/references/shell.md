# LedgerUI.Components.Shell

The one frame of the app: the side menu, the top bar, the page and the parts that lie over them.
`shell/1` draws the menu in one of two ways and keeps the same frame around it.

## Data mode: `nav`

The menu is fed by one list of items (`LedgerUI.Components.Sidebar.sidebar/1`), so changing
`format` changes how the menu is drawn and not the items.

    <.shell nav={MyAppWeb.Nav.items(assigns)} format="rail" current={@current_path}
      brand={%{name: "Ledger", logo: "S"}} user={@user}>
      <:topbar><.navbar>...</.navbar></:topbar>
      ...the page...
    </.shell>

`nav`, `brand`, `user`, `plan`, `trial`, `rail_extra`, `footer`, `version`, `match`,
`persist_groups`, `collapsible` and `collapsed` are those of `LedgerUI.Components.Sidebar.sidebar/1`,
which documents the data of the items. `format` is how it is drawn (`sections`, `rail`, `tree` or
`nested`).

## Slot mode: `<:sidebar>`

When the `:sidebar` slot is given, the menu is your markup (the building blocks below: the icon
rail, a panel, the sideblock, the horizontal navigation...) and `nav` and `format` are ignored.
`layout` says which arrangement it is (`sidebar`, `minimal`, `sideblock`, `horizontal` or `framed`).

    <.shell id="shell" full sidebar_open={@sidebar_open} on_toggle="sidebar">
      <:sidebar>
        <.main_sidebar current={@current_path}>
          <:logo navigate={~p"/"}><.icon name="grid" /></:logo>
          <:item navigate={~p"/dashboards"} label="Dashboards"><.icon name="home" /></:item>
        </.main_sidebar>
        <.sidebar_panel title="Layouts">
          <.sidebar_nav>
            <.sidebar_nav_link navigate={~p"/orders"} current={@current_path}>Orders</.sidebar_nav_link>
          </.sidebar_nav>
        </.sidebar_panel>
      </:sidebar>
      <:topbar><.header /></:topbar>
      <.page_header title="Avatar">
        <:crumb navigate={~p"/elements"}>Elements</:crumb>
        <:crumb>Avatar</:crumb>
      </.page_header>
    </.shell>

## The frame (both modes)

The `:topbar` slot is the row at the top of the page (a `navbar/1` or `header/1`), the `:tab_bar`
slot is the phone's bottom bar of tabs (a `tab_bar/1`, shown only below 768px), the `:aside` slot is
rendered after the page, over the whole shell (a drawer, a right sidebar, a modal).

`full` makes it a full-screen app (no border, radius or shadow, viewport height) and `min_height`
sets the minimum height. `float` makes the page a bordered, rounded card beside the menu (`layout="framed"`
implies it). `preloader` covers the shell with a spinner until the hook mounts.

`header_sticky` and `header_blur` (the top bar sticks and blurs what scrolls under it) default to
on in slot mode and off in data mode (the `navbar/1` scrolls with the page there).

## State and the hook

The root is the `group/shell` of its parts and carries the state other kits keep in `<body>`
classes: `open` and `is-sidebar-open` (so `LedgerUI.open/close/toggle(socket_or_js, "shell")` drive
it), `has-min-sidebar`, `navigation:sideblock`, `navigation:horizontal`, `is-header-blur` and
`is-header-not-sticky`. The `LedgerUI.Shell` hook keeps the open state (`sidebar_open`; by default
open for `sidebar` and `sideblock`), persists the user's choice at xl and up (`persist`,
`localStorage["ledger-sidebar"]`), closes it below xl, and tells the server through `on_toggle`
(an event name, pushed to `target` when given, or a `JS` command). `[data-sidebar-toggle]` inside
the shell toggles it (`sidebar_toggle/1`).

Hooks used: `LedgerUI.Shell`, `LedgerUI.Sidebar` (collapsing menus), `LedgerUI.RightSidebar`,
`LedgerUI.Clock` and `LedgerUI.MonochromeToggle`; dark mode is `theme_toggle/1` and
`theme_script/1` of `LedgerUI.Components.ThemeSwitch`.

## Building blocks

The slot mode is made of the parts of this module, all public function components: the icon rail
(`main_sidebar/1`, `main_sidebar_link/1`, `sidebar_profile/1`, `icon_rail/1`), the panel
(`sidebar_panel/1`, `sidebar_nav/1`, `sidebar_nav_link/1`, `sidebar_nav_group/1`, ...), the minimized
panel (`sidebar_panel_min/1`), `sideblock/1`, `header/1`, the horizontal navigation
(`horizontal_nav_menu/1`), `right_sidebar/1`, the framed menu (`framed_sidebar/1`, `rail_link/1`,
`rail_module/1`, `rail_heading/1`, `rail_workspace/1`, `rail_user/1`, `rail_toggle/1`), `tab_bar/1`,
`page_header/1` (it was `AppShell.page_header/1`) and `monochrome_toggle/1`.

Styled only with Tailwind utilities (no stylesheet of its own). The root keeps `overflow: clip`: a
drawer that slides in over it is clipped, and `clip` (unlike `hidden`) cannot be scrolled by the
focus the drawer takes. The collapsible menus (`framed_sidebar/1`, `Sidebar`) are the `group/side`
of their parts and read `data-collapsed`, which the `LedgerUI.Sidebar` hook sets.

## Preview

`variant="preview"` draws the canvas wireframe of a `layout` instead of the app (the docs and the
showcase use it): `sidebar`, `minimal`, `sideblock`, `horizontal`, `framed` or `rail`. A box with
grey bars for the menu, the top bar and the cards; `loop` animates the menu collapsing.

    <.shell variant="preview" layout="framed" loop />

## Configuration

    config :ledger_ui, :shell, sidebar: :sections, nav: {MyAppWeb.Nav, :items}, footer: :version, version: "v1.4.2"

Attributes always win over the config.

## `<.shell>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"shell"` |  |
| `variant` | `:string` | `"app"` | `app`, `preview` |
| `layout` | `:string` | `"sidebar"` | `sidebar`, `minimal`, `sideblock`, `horizontal`, `framed`, `rail` - The arrangement of the `:sidebar` slot (`rail` is only a wireframe, drawn as `sidebar`); with `preview`: the wireframe. |
| `loop` | `:boolean` | `false` | With `preview`: the menu collapses and expands on its own (the showcase demo). |
| `flat` | `:boolean` | `false` | Data mode: the items of the menu without the column around them. |
| `format` | `:any` | `nil` | Data mode: how the menu is drawn, `sections`, `rail`, `tree` or `nested` (the `format` of `sidebar/1`; it was the `sidebar` attribute). |
| `nav` | `:list` | `nil` |  |
| `current` | `:string` | `nil` |  |
| `brand` | `:map` | `nil` |  |
| `user` | `:map` | `nil` |  |
| `footer` | `:any` | `nil` |  |
| `show_user` | `:boolean` | `nil` |  |
| `version` | `:any` | `nil` |  |
| `match` | `:string` | `"exact"` | `exact`, `prefix` |
| `persist_groups` | `:boolean` | `false` |  |
| `plan` | `:map` | `nil` |  |
| `trial` | `:map` | `nil` |  |
| `rail_extra` | `:list` | `[]` |  |
| `collapsible` | `:boolean` | `true` |  |
| `collapsed` | `:boolean` | `false` |  |
| `full` | `:boolean` | `false` | Full-screen app: no border, radius or shadow, and a minimum height of the viewport (`100vh`) instead of 520px. |
| `float` | `:boolean` | `false` | The floating page (a bordered, rounded card beside the menu); `layout="framed"` implies it. |
| `min_height` | `:string` | `nil` | The minimum height of the shell, a CSS length ("900px", "40rem"). Default: 520px, or the viewport with `full`. |
| `sidebar_open` | `:boolean` | `nil` | The open state of the menu (the `open` / `is-sidebar-open` classes). Default: open for the `sidebar` and `sideblock` layouts. |
| `persist` | `:boolean` | `true` | Keep the open state the user chose (xl and up) in `localStorage["ledger-sidebar"]`. |
| `on_toggle` | `:any` | `nil` | An event name pushed with `%{"id" => id, "open" => boolean}` when the menu opens or closes, or a `Phoenix.LiveView.JS` command. |
| `target` | `:any` | `nil` | The `phx-target` of the `on_toggle` event. |
| `preloader` | `:boolean` | `false` | A spinner over the shell until it mounts. |
| `header_sticky` | `:boolean` | `nil` | The top bar sticks to the top. Default: on in slot mode, off in data mode. |
| `header_blur` | `:boolean` | `nil` | The top bar blurs what scrolls under it. Default: on in slot mode, off in data mode. |
| `class` | `:any` | `nil` |  |
| `main_class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:aside>` - Rendered after the page, over the whole shell: a drawer, a modal, a right sidebar.
- `<:brand_mark>`
- `<:inner_block>`
- `<:mobile_drawer>`
- `<:sidebar>` - Slot mode: your own menu (the main sidebar and its panel, the sideblock...). With it `nav` and `format` are ignored.
- `<:sidebar_footer>`
- `<:tab_bar>` - A bottom bar of tabs for phones: a `tab_bar/1`.
- `<:topbar>` - The row at the top of the page: a `navbar/1` or `header/1`.

## `<.main_sidebar>`

The main sidebar: the icon rail with the logo, the section links and the bottom links.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"main-sidebar"` |  |
| `current` | `:any` | `nil` | The current path (matched against each item's link), or an item's `name`. |
| `centered` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:bottom>`
- `<:item>` - attrs: `href`, `navigate`, `patch`, `label`, `icon`, `name`, `active`, `class`, `style`, `count`, `count_tone`
- `<:logo>` - attrs: `href`, `navigate`, `patch`, `src`, `alt`

## `<.main_sidebar_link>`

One icon link of the main sidebar.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` | `:string` | `nil` | The tooltip and the accessible name. |
| `active` | `:boolean` | `false` |  |
| `current` | `:string` | `nil` |  |
| `count` | `:any` | `nil` | A counter badge on the corner of the button. |
| `count_tone` | `:string` | `"neg"` | `neg`, `warn` - The color of the counter. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `replace`.

Slots:

- `<:inner_block>` (required)

## `<.sidebar_profile>`

The avatar at the bottom of the main sidebar and the profile box it opens on its right.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `src` (required) | `:string` |  |  |
| `alt` | `:string` | `"avatar"` |  |
| `name` (required) | `:string` |  |  |
| `subtitle` | `:string` | `nil` |  |
| `status` | `:string` | `"success"` | `nil`, ``, `success`, `warning`, `error`, `info`, `neutral` |
| `href` | `:string` | `nil` |  |
| `navigate` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:footer>`
- `<:item>` - attrs: `href`, `navigate`, `patch`, `method`, `color`, `title`, `description`

## `<.sidebar_panel>`

The sidebar panel next to the main sidebar: its title and the scrolling body.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` (required) | `:string` |  |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.sidebar_nav>`

A list of the sidebar panel (or the sideblock).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.sidebar_nav_link>`

A plain link of the sidebar panel, active with `active` or when its path is `current`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `active` | `:boolean` | `false` |  |
| `current` | `:string` | `nil` |  |
| `color` | `:string` | `nil` | `nil`, `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` - The active link takes the soft fill and the ink of this color (default: the selected look). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `replace`.

Slots:

- `<:count>` - The count (or the key hint) at the end of the link.
- `<:inner_block>` (required)

## `<.sidebar_nav_count>`

The count (or the key hint) at the end of a link of the sidebar panel (`<:count>` of `sidebar_nav_link/1` renders it).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.sidebar_nav_heading>`

The title over a group of links of the sidebar panel, with no toggle (`sidebar_nav_group/1` is the collapsible one).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `icon` | `:string` | `nil` | A small icon before the title (`chevron-down`, as in a group). |
| `upper` | `:boolean` | `false` | Mono caps, as the heading of the rail. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.sidebar_nav_group>`

A collapsible group of the sidebar panel. It opens when one of its items is active (or with `open`).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` | Defaults to `sidebar-group-<label>`. |
| `label` (required) | `:string` |  |  |
| `open` | `:boolean` | `nil` |  |
| `name` | `:string` | `"sidebar-nav"` | Groups with the same name open one at a time. |
| `current` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:item>` (required) - attrs: `href`, `navigate`, `patch`, `active`

## `<.sidebar_nav_divider>`

The line between the lists of the sidebar panel.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

## `<.sidebar_panel_min>`

The minimized sidebar panel (`layout="minimal"`): a header, the icon links and a footer.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:footer>`
- `<:header>`
- `<:inner_block>` (required)

## `<.sidebar_min_group>`

A list of icon links of the minimized panel.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Slots:

- `<:inner_block>` (required)

## `<.sidebar_min_link>`

An icon link of the minimized panel. The active one is accent soft.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` | `:string` | `nil` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `active` | `:boolean` | `false` |  |
| `current` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `replace`.

Slots:

- `<:inner_block>` (required)

## `<.sidebar_min_divider>`

The line between the lists of the minimized panel.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

## `<.sideblock>`

The sideblock (`layout="sideblock"`): one wide sidebar with the logo and the navigation.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
- `<:logo>` - attrs: `href`, `navigate`, `patch`, `src`, `alt`

## `<.header>`

The header: the animated sidebar toggle, the search bar, the dark mode and monochrome toggles, the
notifications, the right sidebar toggle and a profile slot. With a `:nav` slot it is the
horizontal navigation header: the `:brand` and the navigation row below.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"app-header"` |  |
| `toggle` | `:boolean` | `true` |  |
| `search` | `:boolean` | `true` |  |
| `search_placeholder` | `:string` | `"Search here..."` |  |
| `search_input` | `:map` | `%{}` |  |
| `theme_toggle` | `:boolean` | `true` |  |
| `monochrome_toggle` | `:boolean` | `true` |  |
| `right_sidebar` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:brand>` - attrs: `href`, `navigate`, `src`, `label`
- `<:mobile_search>`
- `<:nav>`
- `<:notifications>` - attrs: `dot`, `label`
- `<:profile>`
- `<:search_results>`
- `<:start>`

## `<.sidebar_toggle>`

The animated hamburger: three bars that turn into an arrow while the sidebar is open.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.horizontal_nav_menu>`

A dropdown of the horizontal navigation: an icon and a label, and a box of links.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `label` (required) | `:string` |  |  |
| `active` | `:boolean` | `false` |  |
| `current` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>`
- `<:inner_block>`
- `<:item>` - attrs: `href`, `navigate`, `patch`, `active`

## `<.horizontal_nav_link>`

A link of a horizontal navigation box. A click closes the box.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `active` | `:boolean` | `false` |  |
| `current` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `replace`.

Slots:

- `<:inner_block>` (required)

## `<.horizontal_nav_divider>`

The line between the links of a horizontal navigation box.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

## `<.right_sidebar>`

A drawer from the right with an overlay, a top row (`:title` and the close button), the content and
a `:footer`. Opened with `open`, `right_sidebar_toggle/1` or `LedgerUI.open/close/toggle(id)`; Esc,
the overlay and the close button close it.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `label` | `:string` | `"Sidebar"` |  |
| `persist_tab` | `:boolean` | `false` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:footer>`
- `<:inner_block>`
- `<:title>`

## `<.right_sidebar_toggle>`

The header button that toggles a `right_sidebar/1`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `target` (required) | `:string` |  |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.framed_sidebar>`

The menu of the framed shell: the brand, an optional workspace and search, the navigation
(`rail_link/1`, `rail_module/1`) and the bottom items. It collapses to a rail of icons (the
names, headings and the workspace go away, badges become dots) and the choice is kept in
`localStorage`. Below 768px it is a top bar with a hamburger.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `collapsed` | `:boolean` | `false` |  |
| `collapsed_width` | `:integer` | `nil` | The width of the collapsed rail in px (default 60). Sets `--lu-rail-collapsed` on the menu; the variable can also be set in CSS. |
| `persist` | `:boolean` | `true` |  |
| `on_collapse` | `:string` | `nil` |  |
| `shortcut` | `:string` | `"b"` |  |
| `target` | `:any` | `nil` |  |
| `label` | `:string` | `"Main menu"` |  |
| `mobile_label` | `:string` | `"Menu"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:bottom>`
- `<:brand>`
- `<:inner_block>` (required)
- `<:search>` - attrs: `id`, `class`, `title`, `aria-label`, `phx-click`, `phx-target`
- `<:wordmark>`
- `<:workspace>`

## `<.tab_bar>`

A phone's bottom bar of tabs: one icon per section, the current one in the accent color.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` | `:string` | `"Sections"` |  |
| `current` | `:string` | `nil` |  |
| `variant` | `:string` | `"default"` | `default`, `canvas` |
| `match` | `:string` | `"exact"` | `exact`, `prefix` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:tab>` (required) - attrs: `href`, `navigate`, `patch`, `label`, `active`, `class`, `match`

## `<.rail_toggle>`

A button that collapses and expands the `framed_sidebar/1` with that id, from anywhere.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `for` (required) | `:string` |  | The id of the `framed_sidebar/1`. |
| `label` | `:string` | `"Collapse menu"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.rail_link>`

A page of the framed menu: the icon, the label, an optional badge and a tooltip for the rail.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `badge` | `:string` | `nil` |  |
| `variant` | `:string` | `"default"` | `default`, `sub` |
| `active` | `:boolean` | `false` |  |
| `current` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `replace`.

Slots:

- `<:inner_block>` - The icon (optional in the `sub` variant).
- `<:trailing>` - Right-aligned content (a `kbd` hint...); hidden when the rail collapses.

## `<.rail_heading>`

A small uppercase title over a group of `rail_link/1`s; hidden in the rail. `mono` (default) or `sans`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"mono"` | `mono`, `sans` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.rail_module>`

A module of the framed menu: a button that opens the pages under it.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `label` (required) | `:string` |  |  |
| `badge` | `:string` | `nil` |  |
| `open` | `:boolean` | `nil` |  |
| `current` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>` (required)
- `<:item>` (required) - attrs: `navigate`, `patch`, `href`, `active`, `badge`

## `<.rail_workspace>`

The workspace switcher under the brand of the framed menu. It is a button: `phx-click` opens your list.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` (required) | `:string` |  |  |
| `subtitle` | `:string` | `nil` |  |
| `initials` | `:string` | `nil` |  |
| `bare` | `:boolean` | `false` | No margin under the box (for use outside of the menu). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.rail_user>`

The person at the bottom of the framed menu: their picture and, outside the rail, their name.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` (required) | `:string` |  |  |
| `subtitle` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.page_header>`

The title of a page. `variant="inline"` is the row: title (with the breadcrumb above it), a
description and the `:actions` at the right, then the `:tabs`. `variant="page"` is the framed
shell's title block: a top row (the `:leading` slot, the crumbs, the clock and the bell) or a
`back` link, the badge, the title with a context line and the actions, and the tabs.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` | `:string` | `nil` | The title text. Or give the `:title` slot. |
| `title_class` | `:any` | `nil` | Classes of the `h1` (e.g. an `animate-[…]` utility for the canvas). |
| `variant` | `:string` | `"inline"` | `inline`, `page` |
| `show_heading` | `:boolean` | `true` | `false` does not render the `h1` (the title, the `:heading` slot and the inline badge); the crumbs, description and actions stay. |
| `density` | `:string` | `"default"` | `default`, `compact` - The top padding: `default` is 26px (`pt-[26px]`), `compact` is 24px (`pt-6`). |
| `description` | `:string` | `nil` |  |
| `back` | `:string` | `nil` |  |
| `back_label` | `:string` | `nil` |  |
| `badge_position` | `:string` | `"above"` | `above`, `inline` |
| `clock` | `:boolean` | `false` |  |
| `locale` | `:string` | `nil` |  |
| `bell` | `:boolean` | `false` |  |
| `bell_label` | `:string` | `"Notifications"` |  |
| `on_bell` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:badge>`
- `<:crumb>` - attrs: `href`, `navigate`, `patch`
- `<:heading>` - The content of the `h1` with markup, instead of `title`.
- `<:icon>`
- `<:inner_block>`
- `<:leading>`
- `<:notifications>`
- `<:subtitle>` - A description with markup, instead of `description`.
- `<:tabs>`

## `<.monochrome_toggle>`

The monochrome mode: the palette button of the header or a switch. It toggles `is-monochrome` on `<body>`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"monochrome-toggle"` |  |
| `variant` | `:string` | `"button"` | `button`, `switch` |
| `on_change` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.icon_rail>`

Same as `main_sidebar/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"main-sidebar"` |  |
| `current` | `:any` | `nil` | The current path (matched against each item's link), or an item's `name`. |
| `centered` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:bottom>`
- `<:item>` - attrs: `href`, `navigate`, `patch`, `label`, `icon`, `name`, `active`, `class`, `style`
- `<:logo>` - attrs: `href`, `navigate`, `patch`, `src`, `alt`

## `<.sub_nav>`

The sub navigation next to the icon rail: a title and groups of links that open and close.

    <.sub_nav title="Cases">
      <:group label="Status">
        <.sidebar_nav_link navigate={~p"/cases/open"}>Open</.sidebar_nav_link>
      </:group>
    </.sub_nav>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` (required) | `:string` |  |  |
| `loop` | `:boolean` | `false` | The canvas loop: the first group closes and opens again, forever. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:group>` - attrs: `label` (required), `open` - A collapsible group under the title: a caption and the links.
- `<:inner_block>` - What goes before the groups.
