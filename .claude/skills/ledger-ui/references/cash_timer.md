# LedgerUI.Components.CashTimer

Status card of a cash register shift: an icon in the colour of the state, a title and a line, the
time the register has been open (ticking in the browser) and a balance, a difference or an action.

    <.cash_timer id="register-2" state="open" title="Caixa 2 aberto" subtitle="desde 08:00 · Marina"
      elapsed={24_130} amount="R$ 6.412,30" />

    <.cash_timer id="register-2" state="closed" title="Caixa 2 fechado" subtitle="ontem às 18:04">
      <:action><.button color="mono" size="sm">Abrir caixa</.button></:action>
    </.cash_timer>

    <.cash_timer id="check-2" state="alert" title="Conferência do caixa 2" difference="− R$ 12,50">
      <:stat label="Esperado">R$ 6.412,30</:stat>
      <:stat label="Contado">R$ 6.399,80</:stat>
    </.cash_timer>

`state` styles the card (`closed` dimmed, `alert` ringed in amber; the `difference` takes the
amber); the icon tile is always the accent colour. `elapsed` (seconds) shows the clock, which counts up in the browser with the
`LedgerUI.Timer` hook while the state is `open` and `running`; a new `elapsed` from the server
resets it. `amount_label` (default `"Em caixa"`) names the balance. Styled only with Tailwind
utilities.

## `<.cash_timer>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `state` | `:string` | `"open"` | `open`, `closed`, `alert` |
| `title` (required) | `:string` |  |  |
| `subtitle` | `:string` | `nil` |  |
| `elapsed` | `:integer` | `nil` | Seconds the register has been open: shows the clock. |
| `running` | `:boolean` | `true` |  |
| `static` | `:boolean` | `false` | No hook: the open clock stays on `elapsed` (it only blinks), as in the canvas samples. |
| `amount` | `:string` | `nil` |  |
| `amount_label` | `:string` | `"Em caixa"` |  |
| `difference` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - A button at the right.
- `<:stat>` - attrs: `label` - A figure in the row under the head.
