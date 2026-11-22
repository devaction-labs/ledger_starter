# LedgerUI.Components.PixelCard

The pixel card: a card to choose from (a model, a module, an integration) that, on hover or
keyboard focus, lights up a matrix of pixels in its top right corner, in the card's colour.

    <.pixel_card navigate={~p"/novo/loja"} color="red" icon="huge-shopping-cart-01"
      title="Loja" description="PDV, estoque, NFC-e" />
    <.pixel_card phx-click="pick" phx-value-id="agenda" color="ink" icon="huge-calendar-03"
      title="Agenda" description="Horários e lembretes" />

With `href`, `navigate` or `patch` the card is a link; with none it is a
`<button type="button">` that takes `phx-click` and the other events through `rest`. The
keyboard focus does what the hover does: the pixels, the stronger outline and the arrow
(`arrow={false}` leaves the arrow out).

`color` takes a palette name (`red`, `rose`, `green`, `teal`, `blue`, `violet`, `amber`,
`ink`); without it the card takes the accent. Any other colour goes through the `--px`
custom property (`style="--px: #f97316"`).

The pixel matrix is drawn by the `LedgerUI.PixelCard` hook (three random opacity patterns that
swap in steps); its classes come from the server (`data-lu-grid-class`, `data-lu-cell-class`), since
the stylesheet only knows the utilities written in this module. The hook needs a DOM id: pass `id`,
or it is derived from the title. Styled only with Tailwind utilities.

## `<.pixel_card>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` | The hook's DOM id; derived from the title when omitted. |
| `title` (required) | `:string` |  | The bold name of the option. |
| `description` | `:string` | `nil` | The muted line under the name. |
| `icon` | `:string` | `nil` | An icon, drawn white in a round chip of the colour. |
| `color` | `:string` | `nil` | `nil`, `red`, `rose`, `green`, `teal`, `blue`, `violet`, `amber`, `ink` |
| `arrow` | `:boolean` | `true` | The arrow that appears on hover. |
| `lit` | `:boolean` | `false` | Shows the hover/focus state (border, matrix, arrow) without the pointer. |
| `loop` | `:boolean` | `false` | Plays the hover (border, pixels, arrow) in a loop, as the canvas demo does. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `disabled`.

Slots:

- `<:inner_block>` - Extra content under the description.
