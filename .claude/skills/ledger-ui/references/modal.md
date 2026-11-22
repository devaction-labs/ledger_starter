# LedgerUI.Components.Modal

Modal dialog for short tasks and confirmations (`<.modal>`).

    <.button phx-click={LedgerUI.open("export")}>Export</.button>

    <.modal id="export" title="Export report" description="October 2026" icon="download" size="sm">
      <p>Choose a format.</p>
      <:footer>
        <.button variant="ghost" phx-click={LedgerUI.close("export")}>Cancel</.button>
        <.button variant="primary">Export</.button>
      </:footer>
    </.modal>

The title is either `title="Export report"` or the `<:title>` slot (markup); the footer is `<:footer>`
or `<:actions>`; `show` is `open` under the name of Phoenix's generated `modal`.

It opens and closes in the browser (`LedgerUI.open/close/toggle("export")`, no round trip),
from the server (`LedgerUI.open(socket, "export")`) or from the `open` assign. The
`LedgerUI.Overlay` hook (`priv/static/ledger_ui/hooks/overlay.js`) keeps the focus inside, closes on
Esc and on a click on the backdrop (unless `prevent_close`), returns the focus to the trigger and
locks the page's scroll. `on_open` / `on_close` run however it opened or closed; as event names
they push `%{"id" => id}` to the LiveView (or `target`).

The root carries `data-lu-overlay`: use `LedgerUI.DOM.onBeforeElUpdated` (see the README) so patches
keep the browser's state.

`inline` renders the dialog in the page flow, always visible and without the hook: a static preview.

## Width

`size` picks a fixed width (`xs` 320 px ... `xl` 960 px, `full`). Two ways to take another:

`size="auto"`: the card is as wide as its content (`w-max`), at least the `sm` width (440 px) and
at most the screen minus the backdrop's margin; it scrolls horizontally only when the content
does not fit the screen. The height is the same as always (`max-h`, the body scrolls vertically).

    <.modal id="items" title="Items" size="auto">
      <.table id="items-table" rows={@items}>...</.table>
    </.modal>

`width`: an integer (px) or a CSS value, through the `--lu-panel-w` variable of the card, always
limited to the screen. It wins over `size`. A string with anything but a CSS value (`;`, `{`, `}`,
quotes, `:`) is ignored. `card_style` is merged with the variable.

    <.modal id="wide" title="Report" width={780}>...</.modal>
    <.modal id="wide" title="Report" width="min(90vw, 900px)">...</.modal>

`size="auto"` and `width` also apply to `layout="page"`.

`layout="page"` is the dialog of the app templates: only while `open`, a dim `lu-overlay` and a
`div.lu-modal` (`header`, `.bd`, `footer`) laid over the closest positioned ancestor, no hook;
the page owns the state and the overlay, Esc and × push `on_close`. The `:header` slot is then
the content before the ×. With `phx-submit` or `phx-change` in the attributes the dialog itself
is a `<form>` (so its controls validate and submit); `phx-target` goes to the form.

## `<.modal>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `layout` | `:string` | `nil` | `nil`, ``, `page` - `page`: the canvas-v2 dialog (a dim overlay + a dialog with `header`, `.bd`, `footer`), shown only while `open` and closed by `on_close` (a LiveView event or `%JS{}`). |
| `open` | `:boolean` | `false` | The server's state; the browser can still open and close it. |
| `show` | `:boolean` | `false` | The same as `open` (the name of Phoenix's generated `modal`); either one opens it. |
| `animation` | `:string` | `"fade"` | `fade`, `scale`, `sheet`, `shift-down`, `shift-up` |
| `size` | `:string` | `"lg"` | `auto`, `full`, `lg`, `md`, `sm`, `xl`, `xs` - `auto`: the card takes the width of its content (at least the `sm` width, at most the screen minus the margin). |
| `width` | `:any` | `nil` | A width: an integer (px) or a CSS value (`"56rem"`, `"min(90vw, 900px)"`), limited to the screen. It wins over `size`. A value with anything but a CSS value is ignored. |
| `placement` | `:string` | `"center"` | `bottom`, `center`, `top` |
| `origin` | `:string` | `"center"` | `bottom`, `center`, `top` |
| `blur` | `:boolean` | `false` |  |
| `backdrop_class` | `:any` | `nil` |  |
| `prevent_close` | `:boolean` | `false` |  |
| `close_button` | `:boolean` | `true` |  |
| `close_variant` | `:string` | `"plain"` | `plain`, `chip` |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `close_label` | `:string` | `nil` |  |
| `role` | `:string` | `"dialog"` | `dialog`, `alertdialog` |
| `description` | `:string` | `nil` |  |
| `body_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` | Merged into the card. |
| `icon` | `:string` | `nil` | An icon tile before the title (needs `title`). |
| `icon_tone` | `:string` | `"neutral"` | `accent`, `error`, `info`, `lime`, `neutral`, `success`, `warning` |
| `card_style` | `:string` | `nil` | Inline style of the card (overrides the `size` width; merged with the `width` variable). |
| `inline` | `:boolean` | `false` | Static preview: in the page flow, always open, no hook. |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - The footer's buttons; the same as `:footer`.
- `<:footer>` - attrs: `class`, `style`
- `<:header>` - attrs: `variant`, `class`, `style`
- `<:inner_block>`
- `<:title>` - The dialog's title (the `title="..."` attribute, a plain string, does the same); draws the header.
