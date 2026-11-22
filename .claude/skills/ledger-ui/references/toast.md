# LedgerUI.Components.Toast

Notifications: the toaster, toasts pushed by the server, and the cards drawn in the page.

Mount the toaster once, in the layout every LiveView renders (it reads the flash):

    <.toaster flash={@flash} />

Then, from the server:

    conn |> put_toast("Saved", color: "success") |> redirect(to: ~p"/orders")
    socket |> put_toast("Saved", color: "success") |> push_navigate(to: ~p"/orders")
    socket |> send_toast("Copied", color: "info", position: "center-top")
    socket |> send_toast("Sending…", id: "nfe-42", kind: :loading)
    socket |> update_toast("nfe-42", replace: true, kind: :success, title: "Sent")
    socket |> dismiss_toast("nfe-42")
    socket |> clear_toasts()

`put_toast/3` goes through the flash (it survives a redirect and the standard `:info`/`:error`
flash messages are drawn too); `send_toast/3` pushes to the page at once. From the browser,
with no round trip (both go through a `ledger:toast` event the toaster hook listens to):

    <button phx-click={show_toast("Copied", color: "info")}>Copy</button>
    <button phx-click={dismiss_toast("nfe-42")}>Hide</button>

Options: `id` (the same id updates a toast in place), `title` (`**object**` is drawn in bold in the
status pill), `description`, `kind` (the format, `:status` or `:card`, or the colour kind `neutral info
success warning error loading`), `status` (`run queue ok err`, the compact dark pill; `:queue` is the
dashed ring of a task waiting), `color`, `position`, `duration` (ms; `0` or `:infinity` keeps it until
closed), `close`, `timer`, `template` (id of a `<template>` whose first element is shown), `actions`
(`[label:, event:, value:, target:, href:, navigate:, patch:, js:, dismiss:, variant:, color:]`), `aura` (`true :dual :glow`,
with `aura_size`/`aura_color`), `progress` (0..100, also `value`; `bar: true` draws a line instead of the
fill), `steps`/`step` and `invert`.

## Two formats

  * **status**: the dark pill (bottom centre by default). The icon fills with `progress`, or is the
    dashed ring with `status: :queue`; it carries at most one action and the progress in %. It goes
    away in 5 s, 8 s with an action, and stays while it works (`kind: :loading`, `status: :run`,
    `progress` under 100).
  * **card**: description, any number of actions, progress and `steps`. It stays while it has actions;
    with `persist_errors` an error or a warning card stays until closed.

The pill's action is a filled button; `variant: :ghost` draws it as text only (no background), the way
"Hide" and "Undo" read in the design. `action:` is one action, `actions:` a list (the pill shows the first):

    socket |> send_toast("Cancelling **PUB-1005279**", status: :queue, action: %{label: "Undo", event: "undo", variant: :ghost})
    socket |> send_toast("Batch **#118** issued", action: [label: "View", href: "/notes"])
    socket |> send_toast("Order **ORD-7** sent", action: [label: "View order", navigate: ~p"/orders/7"])

`href` is a plain link (the page reloads). `navigate:` and `patch:` are LiveView links (`data-phx-link`):
the screen changes with no reload, and the toast closes on the click. They take a path of this site only
(`/orders/7`, `/orders?tab=open`): a URL with a host, `//host`, `javascript:` or a backslash is dropped from
the action. This holds for `send_toast`, `put_toast`, `update_toast`, `show_toast` and the flash. In
`status_toast/1` an `:action` slot takes the same `href`/`navigate`/`patch`; in `toast_card/1` write a
`<.link navigate={...}>` inside the `:action` slot.

In a card with `progress`, `icon` keeps the document-type icon (PDF, NF-e...) and the tile's background fills
from 0 to 100% with the progress (instead of the spinning ring); `update_toast` moves the level.

`kind: :status | :card` forces the format. Otherwise a description, an aura, `steps`, `progress` or
more than one action make a card, and everything else a pill. Each format has its own place:
`<.toaster position="center-bottom" card_position="right-top" />` (`status_position` is the pill's
when it must differ from `position`), and a toast's own `position:` wins.

## Queue and updates

Each stack shows `max_visible` toasts (three, the blades of the pile); the rest wait in a queue and
come in as the others leave, their time counting from then. A toast sent with an id already on screen
(or in the queue) updates that toast. `update_toast/3` changes only the options it is given; with
`replace: true` it swaps the whole toast (the way a loading toast turns into its result, even in the
other format) and starts its time again:

    socket |> send_toast("Importing **orders.csv**", id: "imp", status: :run, progress: 10)
    socket |> update_toast("imp", progress: 64)
    socket |> update_toast("imp", replace: true, kind: :status, color: :success, title: "Imported **orders.csv**")

The client side is the `LedgerUI.Toaster` hook (`priv/static/ledger_ui/hooks/toaster.js`).

`toast_card/1` and `status_toast/1` draw the same cards where they are written. For docs and design
reviews, `toast_card progress_loop` fills and counts by itself, and `toast_loop/1` plays the toaster's
loops (toasts piling up, or a loading toast giving way to its answer) with CSS only.

## `<.toaster>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"ledger-toaster"` |  |
| `flash` | `:map` | `%{}` | The `@flash`, where `put_toast/3` leaves its toasts. |
| `position` | `:string` | `"center-bottom"` | `left-top`, `left-bottom`, `center-top`, `center-bottom`, `right-top`, `right-bottom` |
| `duration` | `:integer` | `5000` |  |
| `status_position` | `:string` | `nil` | `nil`, `left-top`, `left-bottom`, `center-top`, `center-bottom`, `right-top`, `right-bottom` - Where the status pill goes; `position` when `nil`. |
| `card_position` | `:string` | `nil` | `nil`, `left-top`, `left-bottom`, `center-top`, `center-bottom`, `right-top`, `right-bottom` - Where the card goes (`"right-top"` is the usual); `position` when `nil`. |
| `max_visible` | `:integer` | `3` | Toasts in view at once, per stack; the rest wait in a queue and enter as the others leave. With `stack` (the blades) three is the most that fits. |
| `stack` | `:boolean` | `true` |  |
| `persist_errors` | `:boolean` | `false` |  |
| `timer` | `:boolean` | `true` |  |
| `invert` | `:boolean` | `false` |  |
| `close_label` | `:string` | `nil` |  |
| `loading_label` | `:string` | `nil` |  |
| `contained` | `:boolean` | `false` | Draw the toaster inside its parent (a demo panel) instead of over the page. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` - Toasts already on screen at render time (a static preview), in the stack.

## `<.toast_card>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `tone` | `:string` | `"light"` | `light`, `dark` |
| `kind` | `:string` | `"neutral"` | `neutral`, `primary`, `success`, `warning`, `error`, `info` |
| `icon` | `:string` | `nil` |  |
| `title` (required) | `:string` |  |  |
| `description` | `:string` | `nil` |  |
| `dismissible` | `:boolean` | `true` |  |
| `close_label` | `:string` | `nil` |  |
| `on_dismiss` | `:any` | `nil` |  |
| `busy` | `:boolean` | `false` |  |
| `busy_label` | `:string` | `nil` | Accessible name of the spinner (none when `nil`). |
| `progress` | `:integer` | `nil` |  |
| `progress_state` | `:string` | `"run"` | `run`, `done`, `fail` |
| `progress_loop` | `:boolean` | `false` | Demo: the fill and the % go from 4 to 100 by themselves, in a 5s loop (`lu-fill`/`lu-pct`); it wins over `progress`. |
| `steps` | `:integer` | `nil` | Number of steps: draws one segment per step under the text (the hook's `steps`). |
| `step` | `:integer` | `0` | Steps done; the next segment is the current one (violet, pulsing). `steps` is required. |
| `steps_loop` | `:boolean` | `false` | Demo: the segments advance by themselves, in a 6s loop (up to 5 steps). |
| `aura` | `:string` | `nil` | `nil`, ``, `spin`, `dual`, `glow` |
| `aura_tone` | `:string` | `"accent"` | `accent`, `ai`, `info`, `pos`, `warn`, `neg`, `violet` |
| `aura_width` | `:string` | `"default"` | `xs`, `sm`, `default`, `lg` |
| `aura_shadow` | `:boolean` | `true` |  |
| `aura_style` | `:string` | `nil` | Inline style of the aura wrapper (e.g. a fixed width); it is full width by default. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - Buttons between the text and the close button.
- `<:icon_tile>` - Replaces the icon inside the tile.

## `<.status_toast>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `state` | `:string` | `"run"` | `run`, `queue`, `ok`, `err` |
| `status` | `:string` | `nil` | `nil`, `run`, `queue`, `ok`, `err` - The same as `state`; it wins when given. |
| `percent` | `:integer` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `action`, `action_variant`.

Slots:

- `<:action>` - attrs: `ghost`, `variant`, `on_click`, `id`, `href`, `navigate`, `patch`
- `<:inner_block>`

## `<.toast_loop>`

The loop of the toaster, for docs and design reviews (CSS only, no hook, no behaviour): the toasts
of the `:toast` slots enter and pile up (`mode="stack"`) or swap in place (`mode="swap"`).

    <.toast_loop mode="swap" class="w-[380px]">
      <:toast><.toast_card kind="primary" icon="sparkles" title="Issuing NF-e…" busy /></:toast>
      <:toast><.toast_card kind="success" icon="check-circle" title="NF-e authorised" /></:toast>
    </.toast_loop>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `mode` | `:string` | `"stack"` | `stack`, `swap` - `stack`: up to three toasts come in one after the other and pile up (9s loop); `swap`: the first one (a loading toast) gives way to the second (its answer), in the same place (5s loop). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:toast>` (required) - A toast (`toast_card/1`, `status_toast/1`...): three at most for `stack`, two for `swap`.
