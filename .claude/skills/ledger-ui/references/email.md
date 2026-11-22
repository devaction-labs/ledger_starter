# LedgerUI.Components.Email

Ledger UI's transactional e-mail: one layout for the e-mails a system sends (a sign-in code, a reset
link, an order update): the logo, a card with an icon badge, an eyebrow, a title, text, a block of
code, facts or steps, a main button with its address spelled out, a note and a footer. 520px wide.

    <.email_layout subject="Your code" preheader="Valid for 10 minutes" brand="Acme"
                   logo_url="https://acme.com/logo.png" eyebrow="Confirm your access" title="Your verification code">
      <:body>
        <.email_p>Hi <b>Ana</b>. Type this code on the sign-in screen.</.email_p>
        <.email_code value="482913" />
      </:body>
      <:action href="https://app.acme.com/confirm?token=7f3a9c">Sign in</:action>
      <:note>Not you? Ignore this e-mail.</:note>
      <:footer>Acme Ltda</:footer>
    </.email_layout>

It renders a whole HTML document built for mail clients: tables for the structure, every style inline,
web-safe font stacks, no script. The only `<style>` carries the resets, the mobile padding and the
dark mode: with `theme={:auto}` (the default) the e-mail follows `prefers-color-scheme`; `:light` and
`:dark` fix it. Every color is also on a hook class (`em-*`) that the dark block overrides with
`!important`. Icons and logos are images with an absolute URL.

Deliver it as the `html_body` of your mailer (`Phoenix.HTML.Safe.to_iodata/1` of the rendered
component). The helpers (`email_p/1`, `email_code/1`, `email_facts/1`, `email_steps/1`) draw the
light palette; with a fixed `theme={:dark}` layout pass `theme={:dark}` to them too.

## `variant="preview"`

The default `variant="document"` is the mail document above. `variant="preview"` is the canvas picture of
an e-mail for the documentation and the showcase: a page fragment (not a document, no tables) with a
tray background, a panel with the brand mark and `brand`, the `title`, the `:body`, the `:action` as a
primary button, a line and the `:footer` in small muted text. It is styled with Tailwind utilities
and the theme tokens, so it follows the theme of the page; do not send it as an e-mail.

## Inline styles on purpose

The `document` variant is the one exception to "only utilities": a mail client does not load a
stylesheet built by Tailwind and many ignore classes, so the structure is tables, every colour is
an inline hex (a fixed light and dark palette, not the page tokens) and the only `<style>` carries
the resets, the mobile padding and the dark mode. This is a rule of the medium, not of the kit.

## `<.email_layout>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `subject` (required) | `:string` |  |  |
| `preheader` | `:string` | `nil` |  |
| `brand` | `:string` | `nil` |  |
| `logo_url` | `:string` | `nil` |  |
| `logo_dark_url` | `:string` | `nil` |  |
| `eyebrow` | `:string` | `nil` |  |
| `title` (required) | `:string` |  |  |
| `theme` | `:atom` | `:auto` | `:auto`, `:light`, `:dark` |
| `lang` | `:string` | `nil` | The `lang` of the document; default: the locale (`en`, `pt-BR`). |
| `alt_text` | `:any` | `:default` | The line before the button's address; `nil`/`false` for none, `:default` for the locale's text. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |
| `button` | `:string` | `"accent"` | `accent`, `ink` |
| `footer_style` | `:string` | `"panel"` | `panel`, `plain` |
| `title_size` | `:integer` | `22` |  |
| `compact` | `:boolean` | `false` |  |
| `variant` | `:string` | `"document"` | `document`, `preview` - `preview` is the canvas picture of an e-mail (a page fragment, not for sending). |

Slots:

- `<:action>` - attrs: `href` (required)
- `<:badge>`
- `<:body>` (required)
- `<:footer>`
- `<:note>` - attrs: `icon`
- `<:secondary>` - attrs: `href`

## `<.email_p>`

A paragraph of the e-mail body, styled for mail clients.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `theme` | `:atom` | `:auto` | `:auto`, `:light`, `:dark` |
| `muted` | `:boolean` | `false` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.email_code>`

A verification code, one box per character.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `value` (required) | `:string` |  |  |
| `hint` | `:string` | `nil` |  |
| `theme` | `:atom` | `:auto` | `:auto`, `:light`, `:dark` |

## `<.email_facts>`

Rows of label and value: `{label, value}`, `{label, value, :mono}` or `{label, value, :total}`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `rows` (required) | `:list` |  |  |
| `theme` | `:atom` | `:auto` | `:auto`, `:light`, `:dark` |
| `variant` | `:string` | `"panel"` | `panel`, `table` |
| `header` | `:any` | `nil` |  |

## `<.email_steps>`

A row of steps: `{label, done?}` pairs, in order. Done ones are filled with a check.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `steps` (required) | `:list` |  |  |
| `theme` | `:atom` | `:auto` | `:auto`, `:light`, `:dark` |
