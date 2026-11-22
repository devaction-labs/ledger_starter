# LedgerUI.Components.ErrorPage

The canvas's error screens (styled only with Tailwind utilities): the whole page an `ErrorHTML` renders (`error_page/1`), the error
inside the app (`error_state/1`) and the list of links under the actions (`error_links/1`).

    <.error_page code={404} request_id={@request_id}>
      <:brand><b>Acme</b></:brand>
      <:status href="https://status.acme.com">All systems operational</:status>
      <:actions><.button navigate="/" size="lg">Back home</.button></:actions>
      <.error_links title="Maybe you were looking for">
        <:link navigate="/orders" icon="receipt" description="Every order">Orders</:link>
      </.error_links>
      <:footer><a href="/help">Help center</a></:footer>
    </.error_page>

    <.error_state code={404} title="Order #2499 not found">
      It may have been deleted or belong to another branch.
    </.error_state>

`code` is the HTTP status (or text, `"OFF"` for offline). It picks the colour of the big code
(`tone`: `neutral` 404, `error` 5xx, `warning` 403/429/offline, `accent` 401/419/503) and the
English defaults of `label`, `title` and `description`; pass them translated.

There is no inline handler (a page with CSP `script-src 'self'` and no LiveView is fine): the back link
(`back_label`, a link to `back_href` or `/`, `data-lu-back`) and the copy button of the request id
(`data-lu-error-copy`) are served by delegated click listeners of `ledger_ui.esm.js`, which registers
them when it is imported (`import "ledger_ui"` is enough, no LiveSocket needed; the page must load
that bundle). Without JS the back link just goes to `back_href` and the copy button stays hidden
(it shows once the script has set `data-lu-js` on `<html>`).

## `<.error_page>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `code` (required) | `:any` |  |  |
| `tone` | `:string` | `nil` | `nil`, ``, `neutral`, `error`, `warning`, `accent` |
| `label` | `:string` | `nil` |  |
| `title` | `:string` | `nil` |  |
| `description` | `:string` | `nil` |  |
| `request_id` | `:string` | `nil` |  |
| `request_id_label` | `:string` | `"Request ID"` |  |
| `copy_label` | `:string` | `"Copy request ID"` |  |
| `copy` | `:boolean` | `true` |  |
| `back_label` | `:string` | `nil` |  |
| `back_href` | `:string` | `"/"` | Where the back link goes without JS (or with no history to go back to). |
| `timestamp` | `:string` | `nil` |  |
| `id` | `:string` | `"error-page"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:brand>`
- `<:card>`
- `<:footer>`
- `<:inner_block>`
- `<:status>` - attrs: `href`, `status`

## `<.error_state>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `code` (required) | `:any` |  |  |
| `tone` | `:string` | `nil` | `nil`, ``, `neutral`, `error`, `warning`, `accent` |
| `icon` | `:string` | `nil` |  |
| `compact` | `:boolean` | `false` | The small one: a 72px number in a gradient (ink to line), no icon tile; only the code, the title and the description. |
| `float` | `:boolean` | `false` | The code floats up and down (4s loop). |
| `title` | `:string` | `nil` |  |
| `description` | `:string` | `nil` |  |
| `id` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:inner_block>` - The description, instead of `description`.
- `<:more>` - Under the actions, full width.

## `<.error_links>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:link>` (required) - attrs: `href`, `navigate`, `icon`, `description`
