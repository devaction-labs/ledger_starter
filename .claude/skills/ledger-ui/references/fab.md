# LedgerUI.Components.Fab

Floating action buttons: `fab/1`, one button (the canvas's solid ink button, or the retracting
pill) and `fab_dial/1`, a speed-dial that opens a column of actions. Styled only with Tailwind
utilities.

    <.fab id="new" label="Novo pedido" phx-click="new_order">
      <:icon><.icon name="plus" size="md" /></:icon>
    </.fab>
    <.fab id="ask" label="Pergunte ao assistente" variant="pill" phx-click="open_assistant" />
    <.fab id="help" label="Precisa de ajuda?" variant="pill" retract="auto" retract_after={6000} />
    <.fab id="chat" label="Chat" variant="pill" retract="always" color="light" position="bottom-left" badge={3} />

    <.fab_dial id="quick" label="Ações rápidas">
      <:action label="Novo contato" phx-click="new_contact"><.icon name="user-plus" /></:action>
      <:action label="Enviar arquivo" phx-click="upload"><.icon name="upload" /></:action>
    </.fab_dial>

## Position

Both are fixed to the viewport corner (`fixed`, the default; `--ledger-z-fab`, 90, keeps them
under modals and drawers). `fixed={false}` leaves them `absolute` in the nearest positioned
ancestor, which is how the showcase demos show them inside a box. `offset` moves a button from
its corner, in pixels (18 by default). `loop` plays the canvas demo loop (the pill opens and
closes, the dial opens and closes), for showcases.

## Hooks

  * `LedgerUI.Fab` (`priv/static/ledger_ui/hooks/fab.js`), only for `retract="auto"`: expands the
    pill, retracts it after `retract_after` ms or on scroll, expands it again on hover and focus.
    `data-state` is kept across patches (`keep-data-state`); the utilities read it
    (`data-[state=expanded]:`).
  * `LedgerUI.FabDial` (`priv/static/ledger_ui/hooks/fab_dial.js`): click toggles, Escape closes and
    returns focus, arrows/Home/End walk the actions, a click outside or focus leaving closes it.

## `<.fab>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `label` (required) | `:string` |  | Always rendered, and the `aria-label`. |
| `position` | `:string` | `"bottom-right"` | `bottom-right`, `bottom-left`, `top-right`, `top-left` |
| `color` | `:string` | `"assistant"` | `assistant`, `primary`, `dark`, `light` |
| `size` | `:string` | `"md"` | `md`, `lg` |
| `variant` | `:string` | `"canvas"` | `canvas`, `pill` |
| `offset` | `:integer` | `nil` | Distance from the corner, in pixels. |
| `retract` | `:string` | `"hover"` | `hover`, `auto`, `never`, `always` |
| `retract_after` | `:integer` | `4000` | Milliseconds before `retract="auto"` retracts. |
| `expanded` | `:boolean` | `false` | Forces the pill open, whatever `retract` says. |
| `badge` | `:any` | `nil` | A count or short text on the bubble's corner. |
| `static` | `:boolean` | `false` | In the flow (`relative`, no corner, no offset): a sample inside a page or a box. |
| `fixed` | `:boolean` | `true` | Fixed to the viewport (`false`: absolute in its parent). |
| `loop` | `:boolean` | `false` | `variant="pill"`: plays the open/close loop of the canvas demo. |
| `type` | `:string` | `"button"` |  |
| `disabled` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `target`, `rel`, `replace`, `form`, `name`, `value`.

Slots:

- `<:icon>` - The glyph (a sparkle by default).
- `<:inner_block>` - Replaces the visible label text (`label` stays the `aria-label`).

## `<.fab_dial>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `label` (required) | `:string` |  | The button's `aria-label` and the name of the menu. |
| `position` | `:string` | `"bottom-right"` | `bottom-right`, `bottom-left`, `top-right`, `top-left` |
| `color` | `:string` | `"primary"` | `assistant`, `primary`, `dark`, `light` - Kept for API parity with `fab/1`. |
| `size` | `:string` | `"md"` | `md`, `lg` - Kept for API parity with `fab/1`. |
| `variant` | `:string` | `"canvas"` | `canvas`, `pill` |
| `offset` | `:integer` | `nil` |  |
| `open` | `:boolean` | `false` | The initial state; after mount the hook owns it. |
| `static` | `:boolean` | `false` | In the flow (`relative`, no corner, no offset): a sample inside a page or a box. |
| `fixed` | `:boolean` | `true` | Fixed to the viewport (`false`: absolute in its parent). |
| `loop` | `:boolean` | `false` | Plays the open/close loop of the canvas demo. |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` (required) - attrs: `label` (required), `href`, `navigate`, `patch`, `phx-click`, `phx-target`, `disabled`, `class` - A mini action: the icon is its content.
- `<:icon>` - The glyph of the button, a plus by default; it turns while open.
