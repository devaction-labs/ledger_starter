# LedgerUI.Components.LandingNav

The marketing-site top bar: the logo on the left, the links in the center (one may open a mega
menu), Entrar and the primary button on the right.

    <.landing_nav id="site-nav" brand={%{name: "Ledger", logo: "L", navigate: ~p"/"}}>
      <:link label="Produto">
        <.landing_mega>
          <.landing_feature icon="kanban" title="Projetos" description="Kanban, prazos" navigate={~p"/projetos"} />
        </.landing_mega>
      </:link>
      <:link label="Preços" navigate={~p"/precos"} active />
      <:actions>
        <.landing_login navigate={~p"/entrar"}>Entrar</.landing_login>
        <.landing_cta navigate={~p"/cadastro"}>Começar grátis</.landing_cta>
      </:actions>
    </.landing_nav>

## Variants

  * `default` - the classic bar, in the page flow.
  * `float` - a detached pill of frosted glass.
  * `clear` - transparent over a hero image; with `sticky` it turns solid once the page scrolls.
  * `tint` and `dark` - the accent wash and the near-black bar.
  * `mobile` - the phone layout at any width: logo and the menu button.
  * `hero` - transparent over a dark hero (the landing's `.lp-nav`): 80px tall, the logo on the left,
    the links as pills centered between the logo and the actions, and the bar itself in the dark theme
    (`data-theme="dark"`, so its text, hover and the solid state use the kit's dark tokens in either
    theme; see `theme` to follow the page instead). The links are always centered. They hide below 1024px. With `sticky` the bar overlays the hero (negative bottom
    margin) and turns solid after `stuck_after` px; put it outside the hero element, or it only sticks
    while the hero is in view.

## Theme and alignment

  * `theme` (`hero` only) - `"dark"` (default, as in 0.5.8: the bar is a dark scope over a dark hero),
    `"auto"` (no `data-theme`: the bar, its links and the solid state follow the page theme, for a hero
    that is light in the light theme) or `"light"`.
  * `align="center"` - the links sit centered between the logo and the actions (the other variants
    keep them next to the logo). The `hero` bar already centers them; `mobile` has no links.

`sticky` pins the bar to the top (`position: sticky`) and mounts the `LedgerUI.LandingNav` hook,
which sets `data-stuck` after `stuck_after` px of scroll. A `:link` with inner content is a
trigger: a button with `aria-expanded` / `aria-controls` that opens the content as the mega menu
(`landing_mega/1`), with hover (`open_on="hover"`) or click; Escape and a click outside close it,
arrows walk the items. The hook is mounted when there is a trigger, `sticky` or `responsive`.

`autohide` (with `sticky`) slides the bar away while the page scrolls down and brings it back when it
scrolls up, when the focus enters it or at the top of the page; it is not hidden while a menu is open.
With `prefers-reduced-motion: reduce` it still hides and shows, but without the slide.

`spy` marks, with `aria-current="true"`, the link whose `#anchor` section is the last one above
`spy_offset` px from the top of the view (none while the first section is still below it, the last one at
the end of the page); the mobile panel links are marked too. It leaves the `active` links
(`aria-current="page"`) that are not anchors alone.

    <.landing_nav id="nav" variant="hero" sticky autohide spy brand={%{name: "Nexus", icon: "sparkles"}}>
      <:link label="Recursos" href="#recursos" />
      <:link label="Preços" href="#precos" />
      <:actions :if={!@current_scope}><.landing_login href="/entrar">Entrar</.landing_login></:actions>
      <:signed_in :if={@current_scope}><.landing_cta href="/dashboard">Dashboard</.landing_cta></:signed_in>
    </.landing_nav>

`:signed_in` is the action of a visitor with a session (the Dashboard button): when it has an entry it
is drawn in place of `:actions`, in the bar and in the mobile panel.

`responsive` hides the links and the primary button below 768px and shows the menu button
(a panel listing every link and the `:actions` again, so do not put an `id` inside `:actions`).
The `mobile` variant always has the menu button. Without a `:logo` slot the `brand` map is used
(`%{name, navigate, logo | src | icon}`: `icon` draws the bare icon beside the name, as in the canvas).

A `:link` with `caret` is a plain link with the "▾" after its label, for a mega menu that is drawn
apart (`landing_mega/1` beside the bar, as in the canvas).

Only utilities: the anchors of the bar are `text-inherit no-underline opacity-80` through a
zero-specificity rule on the bar, so a utility on an anchor (the active link, a feature) wins.

## `<.landing_nav>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `variant` | `:string` | `"default"` | `default`, `float`, `clear`, `tint`, `dark`, `mobile`, `hero` |
| `theme` | `:string` | `"dark"` | `dark`, `auto`, `light` - `hero` only: the theme scope of the bar; `auto` follows the page theme. |
| `align` | `:string` | `"start"` | `start`, `center` - `center` centers the links between the logo and the actions. |
| `open_on` | `:string` | `"hover"` | `hover`, `click` |
| `sticky` | `:boolean` | `false` |  |
| `stuck_after` | `:integer` | `8` |  |
| `autohide` | `:boolean` | `false` | With `sticky`: hides on the way down, shows on the way up. |
| `spy` | `:boolean` | `false` | Marks (`aria-current="true"`) the link of the `#anchor` section in view. |
| `spy_offset` | `:integer` | `120` | How far from the top of the view a section counts as the current one. |
| `responsive` | `:boolean` | `false` | Show the phone menu button below 768px. |
| `brand` | `:map` | `nil` |  |
| `label` | `:any` | `"Main"` | The accessible name of the links (`nil` leaves it out). |
| `menu_label` | `:string` | `"Menu"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:link>` - attrs: `label`, `href`, `navigate`, `patch`, `active`, `caret`
- `<:logo>`
- `<:signed_in>` - The action of a visitor with a session; drawn in place of `:actions` when it has an entry.

## `<.landing_login>`

The "Entrar" link of the bar.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `href` | `:string` | `"#"` |  |
| `navigate` | `:string` | `nil` |  |
| `patch` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.landing_cta>`

The primary button of the bar. A link when it has `href`, `navigate` or `patch`, else a `button`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `size` | `:string` | `"md"` | `md`, `lg` |
| `block` | `:boolean` | `false` |  |
| `icon` | `:string` | `nil` |  |
| `href` | `:string` | `nil` |  |
| `navigate` | `:string` | `nil` |  |
| `patch` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `disabled`, `form`, `name`, `value`, `phx-click`.

Slots:

- `<:inner_block>` (required)

## `<.landing_mega>`

The mega menu content (inside a `:link` of `landing_nav/1`): the features and, optionally, a side panel.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"default"` | `default`, `cards` |
| `columns` | `:integer` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
- `<:side>`

## `<.landing_product>`

A product card of `landing_mega variant="cards"`: logo and name, a large title, a link and a preview.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` (required) | `:string` |  |  |
| `name` | `:string` | `nil` |  |
| `logo` | `:string` | `nil` |  |
| `link_label` | `:string` | `nil` |  |
| `tone` | `:string` | `"default"` | `default`, `tint`, `dark` |
| `accent` | `:string` | `nil` |  |
| `mock` | `:boolean` | `false` |  |
| `compact` | `:boolean` | `false` | A static mini card (`div`): only the title, as in the canvas menu. |
| `href` | `:string` | `"#"` |  |
| `navigate` | `:string` | `nil` |  |
| `patch` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:mark>`
- `<:preview>`

## `<.landing_feature>`

One feature of the mega menu: an icon in a box, the title and a line of description.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `icon` | `:string` | `nil` |  |
| `title` (required) | `:string` |  |  |
| `description` | `:string` | `nil` |  |
| `href` | `:string` | `"#"` |  |
| `navigate` | `:string` | `nil` |  |
| `patch` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.landing_mega_side>`

The highlighted panel beside the features: an eyebrow, the title, the text, a thumbnail and a link.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `eyebrow` | `:string` | `nil` |  |
| `title` (required) | `:string` |  |  |
| `thumb` | `:boolean` | `false` |  |
| `link_label` | `:string` | `nil` |  |
| `href` | `:string` | `"#"` |  |
| `navigate` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.landing_announcement>`

The thin announcement strip above the bar; the close button hides it with `JS.hide`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `eyebrow` | `:string` | `nil` |  |
| `link_label` | `:string` | `nil` |  |
| `href` | `:string` | `"#"` |  |
| `navigate` | `:string` | `nil` |  |
| `dismissible` | `:boolean` | `true` |  |
| `close_label` | `:string` | `"Close"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
