# LedgerUI.Components.AuthSplit

The sign in and sign up screen in two halves, as the canvas draws it: on the left a centered column (the
brand mark, the title and subtitle, the `:providers` buttons and the divider, the form and a line under
it) and, on the right, either a picture filling its half with a testimonial over its lower part or the
`:aside` panel (tray background, content centered: a badge, a headline, a KPI card).

    <.auth_split title="Criar conta" subtitle="Preencha seus dados." src={~p"/images/auth.jpg"}>
      <:brand><img src={~p"/images/logo.svg"} width="28" /> Acme</:brand>
      <:providers>
        <.oauth_button provider="google" href={~p"/auth/google"}>Google</.oauth_button>
      </:providers>
      <.form for={@form} phx-submit="save">...</.form>
      <:quote author="Marina Costa" role="Gerente" rating={5}>Em uma semana a equipe inteira estava usando.</:quote>
      <:footer>Já tem conta? <.link navigate={~p"/users/log-in"}>Entrar</.link></:footer>
    </.auth_split>

The picture is `src` or the `:art` slot; without either and without `:aside`, the form takes the
whole card. `variant`: `card` (default, the framed app) or `full` (the whole screen). The
`:brand` slot is the content of the 40px brand tile (`brand_href` makes it a link); `oauth_button`
takes `block` for the full-width provider button of the canvas.
For the canvas-v2 screen (brand tile, tinted art with floating cards) see `auth_page/1` and
`auth_art/1`. Under 1024px the right half goes away. The other states of the screen: `auth_sent/1` (link sent),
`auth_alert/1` (errors) and `auth_submit/1` (sending).

## `<.auth_split>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` | `:string` | `nil` | Plain title; the `:heading` slot replaces it. |
| `subtitle` | `:string` | `nil` |  |
| `src` | `:string` | `nil` |  |
| `alt` | `:string` | `""` |  |
| `variant` | `:string` | `"card"` | `card`, `full` |
| `glow` | `:boolean` | `false` | Deprecated: the canvas has no glow; ignored. |
| `divider_label` | `:string` | `"Or"` |  |
| `brand_href` | `:string` | `nil` | Makes the brand mark a link. |
| `form_width` | `:integer` | `nil` | The width of the form column in px (default 360). Sets `--lu-auth-form-w` on the form column. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:art>`
- `<:aside>`
- `<:brand>`
- `<:footer>`
- `<:heading>` - The title with markup (highlight, `<br>`); replaces `title`.
- `<:inner_block>` (required)
- `<:page_footer>` - The bottom of the form half (terms, privacy, help), small muted text.
- `<:providers>`
- `<:quote>` - attrs: `author`, `role`, `rating`
- `<:top>` - A strip over the form half (brand on the left, a link on the right).

## `<.auth_page>`

The sign in / sign up / recovery screen of the canvas: on the left the brand, a
centered column (max 380px, `inner_block`) and a footer line; on the right the rounded art
(`:art`, see `auth_art/1`). It fills its parent (`height: 100%`), so give the parent the screen's
height.

    <.auth_page brand="Ledger">
      <h1>Entrar no Ledger</h1>
      <p class="sub">Pedidos, notas e financeiro num lugar só.</p>
      ...fields...
      <:footer><span>© 2026 Acme</span><span>Privacidade · Termos</span></:footer>
      <:art><.auth_art id="login-art">...</.auth_art></:art>
    </.auth_page>

With `on_submit` or `on_change` the column is a `<form>` (the layout is the same), so the fields
validate and submit through LiveView.

Inside the column use `<h1>`, `<p class="sub">` and a `<div class="or">ou com e-mail</div>`
divider: the column styles them with descendant utilities. Under 1024px there is one column and the
art goes away.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `brand` | `:string` | `"Ledger"` | The product name beside the mark. |
| `mark` | `:string` | `"L"` | The letter (or text) inside the brand tile. |
| `form_id` | `:string` | `nil` | Id of the column's `<form>` (with `on_submit`/`on_change`). |
| `on_submit` | `:any` | `nil` | Makes the column a `<form>` with this `phx-submit`. |
| `on_change` | `:any` | `nil` | Makes the column a `<form>` with this `phx-change`. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:art>` - The right half; usually `auth_art/1`.
- `<:footer>` - The line under the column: one `<span>` per side (copyright, links).
- `<:inner_block>` (required) - The form column: title, fields, buttons.

## `<.auth_art>`

The art half of `auth_page/1`: the mountain landscape (`Illustration.summit/1`), floating `:chip`
cards and a glass `:quote`. The landscape paints with the `--lu-hero-*` tokens, so it follows the
theme (light, dark, palette).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"auth-art"` | Prefix of the SVG's gradient ids; one per page. |
| `tone` | `:string` | `"teal"` | Kept for compatibility; the palette follows the theme. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:chip>` - attrs: `top`, `right`, `left`, `bottom` - A floating card over the picture (`top`, `right` in px or any CSS length).
- `<:quote>` - attrs: `author` (required), `role`, `initials`, `tone` - The glass testimonial at the bottom.

## `<.oauth_button>`

A sign in button for an identity provider: the icon and the label, as a link (`href`) or a button.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `provider` | `:string` | `nil` | `nil`, ``, `google`, `apple`, `github` |
| `href` | `:string` | `nil` |  |
| `block` | `:boolean` | `false` | The full-width provider button (`size="lg"`, the whole row). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `type`, `disabled`, `form`, `name`, `value`.

Slots:

- `<:icon>`
- `<:inner_block>` (required)

## `<.auth_sent>`

The "link sent" block: a tile with a mail icon and the message beside it (`role="status"`).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>`
- `<:inner_block>` (required)

## `<.auth_alert>`

The notice on top of a form with errors: a cross icon and the message (`role="alert"`).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.auth_submit>`

The form's submit button, full width and accent. With `loading` it disables itself and shows the spinner.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `loading` | `:boolean` | `false` |  |
| `loading_label` | `:string` | `nil` |  |
| `type` | `:string` | `"submit"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `disabled`, `form`, `name`, `value`.

Slots:

- `<:inner_block>` (required)
