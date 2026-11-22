# LedgerUI.Components.OtpInput

A one-time code made of single-character boxes.

    <.otp_input field={@form[:code]} label="Codigo de 6 digitos" />
    <.otp_input name="pin" length={4} mask autofocus />
    <.otp_input field={@form[:code]} separator={3} on_complete="verify" />
    <.otp_input name="invite" mode="alphanumeric" length={8} size="lg" />

Typing fills a box and moves to the next, Backspace on an empty box goes back and empties the
previous one, the arrows, Home and End move between boxes, and a paste or an autofill spreads
its characters over the boxes. Characters the `mode` does not allow are dropped.

The boxes have no `name`: a hidden input named like the field carries the joined code and fires
a bubbling `input` event whenever it changes, so a surrounding `phx-change` receives
`%{"name" => "482913"}` (a partial code while it is typed). A `value` the server sends later
wins over the one in the browser (render `value=""` to clear a rejected code).

`on_complete` is an event name or a `%JS{}`; it is sent to `target` (or the LiveView) each time
the code changes while every box is filled, with `%{"id" => id, "name" => name, "value" => code}`.

The behaviour lives in the `LedgerUI.Otp` hook (file `otp.js`), so the component needs a stable
`id` (from `field` or `name`).

With `autofocus` the box that takes the focus first (the first empty one) is rendered with
`data-on`, so the ring and the caret show before the hook runs (the hook moves that attribute).

## `<.otp_input>`

Renders the boxes, with their caption, help and errors when given.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `state` | `:string` | `nil` | `nil`, ``, `success`, `error` |
| `length` | `:integer` | `6` |  |
| `mode` | `:string` | `"numeric"` | `numeric`, `alphanumeric` |
| `size` | `:string` | `nil` | `nil`, `sm`, `md`, `lg` |
| `mask` | `:boolean` | `false` |  |
| `disabled` | `:boolean` | `false` |  |
| `autofocus` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | Demo animation (CSS only): the digits of `value` appear in sequence, each box taking the ring in turn. The boxes stay empty. |
| `separator` | `:any` | `nil` |  |
| `on_complete` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `aria_label` | `:string` | `"One-time code"` |  |
| `digit_label` | `:string` | `"Digit"` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
