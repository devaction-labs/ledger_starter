# LedgerUI.Components.Navbar

The app top bar: a container (`navbar/1`) and small pieces to put in it. The right side keeps the
same vocabulary (search, notifications, theme, language and the user); the variants change what
goes on the left and the visual weight.

    <.navbar>
      <.navbar_crumbs items={[%{label: "Início", navigate: ~p"/"}, %{label: "Site novo"}]} />
      <:end>
        <.navbar_search placeholder="Buscar…" phx-click={JS.exec("data-show", to: "#palette")} />
        <.navbar_bell dot />
        <.theme_switch id="theme" variant="icons" size="sm" />
        <.navbar_user id="me" user={@user}>
          <:menu>
            <.navbar_menu_head user={@user} />
            <.navbar_menu_item icon="user" navigate={~p"/perfil"}>Perfil</.navbar_menu_item>
            <.navbar_menu_item icon="logout" danger href={~p"/sair"} method="delete">Sair</.navbar_menu_item>
          </:menu>
        </.navbar_user>
      </:end>
    </.navbar>

`variant`: `"default"` (64px, a line under it), `"float"` (a detached raised bar), `"clear"`
(transparent, over a hero), `"dense"` (48px) or `"mobile"` (56px). `size="sm"` is 52px. Slots:
`inner_block` (the left side), `:center`, `:end` (the right side) and `:tabs`, which makes the bar
two rows (the tabs row under the content).

The slots are rendered straight inside the `<header>` (a flex row), so the items are its direct
children and the crumbs take the free space. Inside `Shell` the bar sticks to the top and
blurs what scrolls under it, like `Shell.header/1`.

## `<.navbar>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"default"` | `default`, `canvas`, `float`, `clear`, `dense`, `mobile` - `canvas` is the same as `default` (the canvas's own bar). |
| `size` | `:string` | `"md"` | `md`, `sm` |
| `id` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:center>` - Between the left and the right: `navbar_links/1`, a wide `navbar_search/1`.
- `<:end>` - The right side.
- `<:inner_block>` - The left side.
- `<:tabs>` - `navbar_tabs/1`: makes the bar two rows.

## `<.navbar_brand>`

The logo and the name of the app.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` | `:string` | `nil` |  |
| `logo` | `:string` | `nil` | The letter in the logo (default: the first of `name`). |
| `src` | `:string` | `nil` | A picture for the logo instead of the letter. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_crumbs>`

The path to the page. Each item is `%{label: "...", navigate: path}` (or `href` / `patch`); the
last one, the page itself, is the current one, and an item with no link is plain text.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `items` (required) | `:list` |  |  |
| `label` | `:any` | `"Breadcrumb"` | The `aria-label` of the `nav` (`nil` leaves it out). |
| `variant` | `:string` | `"canvas"` | `canvas`, `plain` - `plain` is the bare trail of the app top bar (larger text, no chips). |
| `icon` | `:string` | `nil` | An icon before the trail (`grid`). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_workspace>`

The workspace switcher: logo, name, a line under it and a chevron. `phx-click` opens your menu.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` (required) | `:string` |  |  |
| `sub` | `:string` | `nil` |  |
| `logo` | `:string` | `nil` |  |
| `src` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_chip>`

A selector in a path of selectors (organization, project). `phx-click` opens the list.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `square` | `:string` | `nil` | The text in the square (2 or 3 letters). |
| `color` | `:string` | `nil` | The CSS color of the square. |
| `tag` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_slash>`

The `/` between two selectors.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_links>`

The main links, centered. Items are `%{label:, navigate:, active:}` (`href` / `patch` work too).
The active one is the item with `active: true` or the one whose link equals `current`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `items` (required) | `:list` |  |  |
| `current` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_tabs>`

The tabs of the page, for the `:tabs` slot of `navbar/1`. Items are those of `navbar_links/1` plus an optional `count`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `items` (required) | `:list` |  |  |
| `current` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_title>`

The centered title of the mobile bar.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.navbar_search>`

The search field of the bar. It is a trigger, not an input: with `phx-click` it becomes a button
(role and tabindex) that opens the command palette.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `placeholder` | `:string` | `"Search"` |  |
| `kbd` | `:string` | `"⌘K"` | The shortcut shown at the end; `nil` hides it. |
| `wide` | `:boolean` | `false` |  |
| `size` | `:string` | `"md"` | `md`, `sm` - `md` is 38px tall; `sm` is the compact field: 32px (`h-8`), 8px radius, `px-2.5`. |
| `input` | `:boolean` | `false` | A real `<input>` with the placeholder, instead of the static text (a field of the bar). |
| `demo` | `:string` | `nil` | `nil`, `typing` - `typing`: the canvas loop. `value` is typed one letter after the other, with a blinking caret, and erased, forever. |
| `loop` | `:boolean` | `false` | Same as `demo="typing"`. |
| `value` | `:string` | `nil` | The text typed by the `typing` demo. |
| `width` | `:string` | `nil` | A CSS width ("240px", "100%"). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `phx-click`.

## `<.navbar_bell>`

The notifications button; `dot` shows the dot of something unread.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `dot` | `:boolean` | `false` | There is something unread. |
| `tone` | `:string` | `"neg"` | `neg`, `warn`, `pos` - The color of the dot (or of the count badge). |
| `count` | `:integer` | `nil` | A count badge instead of the dot. |
| `label` | `:string` | `"Notifications"` |  |
| `size` | `:string` | `"md"` | `md`, `sm` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`.

## `<.navbar_icon>`

An icon button of the bar (search on a small screen, help, the menu of the mobile bar).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` (required) | `:string` |  | A Hugeicons name. |
| `label` (required) | `:string` |  |  |
| `size` | `:string` | `"md"` | `md`, `sm` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`.

## `<.navbar_lang>`

The language switcher: a small segmented group. `locales` is a list of codes (`["PT", "EN"]`,
with `current`) or of maps `%{code:, navigate:, active:, click:, label:}`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `locales` (required) | `:list` |  |  |
| `current` | `:string` | `nil` |  |
| `label` | `:string` | `"Language"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_sep>`

The thin vertical line between the icons and the user.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_env>`

The environment pill (`Produção`, `Homologação`); `tone` is `ok` (green) or `warn` (amber).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `tone` | `:string` | `"ok"` | `ok`, `warn` |
| `compact` | `:boolean` | `false` | Only the status dot, the label as its title. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_sync>`

The save state: a green check and a muted text (`Salvo há 2 min`).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `text` (required) | `:string` |  |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_avatars>`

The people on the page, as overlapping avatars; the rest is a `+N` bubble.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `users` (required) | `:list` |  |  |
| `max` | `:integer` | `3` |  |
| `total` | `:integer` | `nil` | How many people there are (default: the length of `users`). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.navbar_user>`

The user of the bar: the avatar, with a status ring (`"ring"`) or with the name (`"named"`).
Without the `:menu` slot it is a plain avatar (a button when it has `phx-click`). With it, the
button opens a raised panel (`role="menu"`, hidden at first; `id` is required) toggled with
`Phoenix.LiveView.JS`: a click outside closes it.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `user` (required) | `:map` |  | `%{name, email, role, initials, avatar, color}`. |
| `variant` | `:string` | `"avatar"` | `avatar`, `ring`, `named` |
| `size` | `:integer` | `nil` | Avatar size in px (32; 26 for `named`). |
| `id` | `:string` | `nil` | Required with a `:menu`. |
| `label` | `:string` | `"Account menu"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:menu>` - The content of the panel: `navbar_menu_*` pieces, links with `role="menuitem"`, `<hr />`.

## `<.navbar_menu_head>`

The head of the user menu: the avatar, the name and the email, and a `:badge` (the role) at the end.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `user` (required) | `:map` |  |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:badge>`

## `<.navbar_menu_status>`

The status line of the menu: a green dot, the label and an `:action` at the end.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>`

## `<.navbar_menu_row>`

A row of the menu with a label and a control at the end (`theme_switch/1`, `navbar_lang/1`).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.navbar_menu_item>`

An item of the menu: a link (`navigate`, `href`, `patch`, with `method="delete"` for a sign-out)
or, with only `phx-click`, an action.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `icon` | `:string` | `nil` |  |
| `kbd` | `:string` | `nil` |  |
| `danger` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `target`, `rel`.

Slots:

- `<:inner_block>` (required)
