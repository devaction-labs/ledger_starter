# LedgerUI.Components.Drawer

Side panel (`<.drawer>`) and its sheet parts (`<.sheet_header>`, `<.sheet_body>`, `<.sheet_footer>`).

    <.drawer id="customer" placement="right" size="md" title="New customer" description="Who buys from you.">
      <.form for={@form} id="customer-form" phx-submit="save">...</.form>
      <:footer>
        <.button variant="ghost" phx-click={LedgerUI.close("customer")}>Cancel</.button>
        <.button type="submit" form="customer-form" variant="primary">Save</.button>
      </:footer>
    </.drawer>

The title is either `title="New customer"` or the `<:title>` slot (markup).

A bare drawer is a sliding frame for a menu; with `title`, `:header` or `:footer` (or `variant`)
it is a sheet: header, scrolling body and fixed footer. `placement="bottom"` is the phone's
sheet (rounded top, grab handle). It opens and closes like `LedgerUI.Components.Modal`
(`LedgerUI.open/close/toggle`, `open`, `on_open`, `on_close`) through the `LedgerUI.Overlay` hook;
by default it does not lock the page's scroll (`lock_scroll`).

Keep `class` and `panel_class` free of `transform`, `filter` and `contain`, so a modal rendered
inside the drawer still covers the whole viewport.

`layout="page"` is the sheet of the app templates: it renders only while `open`, as a dim
`lu-overlay` and an `aside.lu-drawer` laid over the closest positioned ancestor (the app shell),
with no hook; the page owns the state. The overlay, the Esc key and the × push `on_close`. The
`:header` slot is then the content before the ×, `:footer` the `<footer>`:

    <.drawer :if={@order} id="order" layout="page" open on_close="close_order">
      <:header><div><h3>Pedido #2495</h3><p>Criado hoje</p></div></:header>
      ...body...
      <:footer><.button>Imprimir</.button></:footer>
    </.drawer>

`inline` renders it in the page flow (a static preview, always open, without the hook).

## Width

`size` picks a fixed width (`sm` 400 px, `md`, `lg`, `wide` 800 px, `xl` 1080 px). Two ways to take another:

`size="auto"`: the panel is as wide as its content (`w-max`), at least the `sm` width and at most
the screen minus the margin of the drawer; the body scrolls horizontally only when the content
does not fit the screen. The panel keeps its full height and the body scrolls vertically.

    <.drawer id="order" placement="right" size="auto" title="Order">
      <.card_table id="items" rows={@items}>...</.card_table>
    </.drawer>

`width`: an integer (px) or a CSS value, through the `--lu-panel-w` variable of the panel, always
limited to the screen. It wins over `size`. A string with anything but a CSS value (`;`, `{`,
`}`, quotes, `:`) is ignored.

    <.drawer id="order" placement="right" width={900} title="Order">...</.drawer>
    <.drawer id="order" placement="right" width="min(90vw, 900px)" title="Order">...</.drawer>

Both apply to side drawers (not to `placement="bottom"`, which is as wide as the screen), and
to `layout="page"`. `sheet/1` takes the same; note that its `placement` is `bottom` by default.

## `<.drawer>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `layout` | `:string` | `nil` | `nil`, ``, `page` - `page`: the canvas-v2 sheet (a dim overlay + an `aside` panel with `header`, `.bd`, `footer`), shown only while `open` and closed by `on_close` (a LiveView event or `%JS{}`). |
| `side` | `:string` | `"left"` | `left`, `right` |
| `placement` | `:string` | `nil` | `nil`, ``, `left`, `right`, `bottom` - The same as `side`, which it overrides when given. |
| `size` | `:string` | `nil` | `nil`, ``, `auto`, `sm`, `md`, `lg`, `wide`, `xl` - `auto`: the panel takes the width of its content (at least the `sm` width, at most the screen minus the margin). |
| `width` | `:any` | `nil` | A width: an integer (px) or a CSS value (`"56rem"`), limited to the screen; wins over `size`. Ignored when not a CSS value. |
| `variant` | `:string` | `nil` | `nil`, ``, `float`, `flush` |
| `description` | `:string` | `nil` |  |
| `close_button` | `:boolean` | `true` |  |
| `close_label` | `:string` | `"Close"` |  |
| `floating` | `:boolean` | `false` | A sheet that floats with margins around it, the look of `variant="float"`; makes a bare drawer a sheet. |
| `overlay` | `:boolean` | `true` |  |
| `lock_scroll` | `:boolean` | `false` |  |
| `prevent_close` | `:boolean` | `false` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` | Merged into the sliding frame. |
| `panel_class` | `:any` | `nil` |  |
| `body_class` | `:any` | `nil` |  |
| `inline` | `:boolean` | `false` | Static preview: in the page flow, always open, no hook. |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:back>`
- `<:footer>` - attrs: `class`
- `<:header>` - attrs: `class`, `style`
- `<:inner_block>` (required)
- `<:title>` - The sheet's title (the `title="..."` attribute, a plain string, does the same); draws the header.

## `<.sheet>`

Same as `drawer/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `open` | `:boolean` | `false` |  |
| `layout` | `:string` | `nil` | `nil`, ``, `page` - `page`: the canvas-v2 sheet (a dim overlay + an `aside` panel with `header`, `.bd`, `footer`), shown only while `open` and closed by `on_close` (a LiveView event or `%JS{}`). |
| `side` | `:string` | `"left"` | `left`, `right` |
| `placement` | `:string` | `"bottom"` | `nil`, ``, `left`, `right`, `bottom` - The same as `side`, which it overrides when given. |
| `size` | `:string` | `nil` | `nil`, ``, `auto`, `sm`, `md`, `lg`, `wide`, `xl` - `auto`: the panel takes the width of its content (at least the `sm` width, at most the screen minus the margin). |
| `width` | `:any` | `nil` | A width: an integer (px) or a CSS value (`"56rem"`), limited to the screen; wins over `size`. Ignored when not a CSS value. |
| `variant` | `:string` | `nil` | `nil`, ``, `float`, `flush` |
| `description` | `:string` | `nil` |  |
| `close_button` | `:boolean` | `true` |  |
| `close_label` | `:string` | `"Close"` |  |
| `floating` | `:boolean` | `false` | A sheet that floats with margins around it, the look of `variant="float"`; makes a bare drawer a sheet. |
| `overlay` | `:boolean` | `true` |  |
| `lock_scroll` | `:boolean` | `false` |  |
| `prevent_close` | `:boolean` | `false` |  |
| `on_open` | `:any` | `nil` |  |
| `on_close` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` | Merged into the sliding frame. |
| `panel_class` | `:any` | `nil` |  |
| `body_class` | `:any` | `nil` |  |
| `inline` | `:boolean` | `false` | Static preview: in the page flow, always open, no hook. |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:back>`
- `<:footer>` - attrs: `class`
- `<:header>` - attrs: `class`, `style`
- `<:inner_block>` (required)
- `<:title>` - The sheet's title (the `title="..."` attribute, a plain string, does the same); draws the header.

## `<.sheet_header>`

The header of a sheet: title and description (or `:content`), a back arrow, buttons and the close ×.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` | The id of the title, for the drawer's `aria-labelledby`. |
| `drawer` | `:string` | `nil` | The id of the drawer the close button closes; the closest one when not given. |
| `title` | `:string` | `nil` |  |
| `description` | `:string` | `nil` |  |
| `close_button` | `:boolean` | `true` |  |
| `close_label` | `:string` | `"Close"` |  |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:back>`
- `<:content>`

## `<.sheet_body>`

The scrolling body of a sheet: it takes the height the header and the footer leave.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.sheet_footer>`

The footer of a sheet: the buttons, aligned to the end on a tinted bar.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
