# LedgerUI.Components.ThemeSwitch

The light / dark / system choice.

    <.theme_switch id="theme" />
    <.theme_switch id="theme" variant="icons" size="sm" />
    <.theme_switch id="theme" variant="switch" />
    <.theme_switch id="theme" system={false} light_label="Claro" dark_label="Escuro" />
    <.theme_switch id="theme" variant="switch" value="dark"><:icon><.icon name="moon" /></:icon></.theme_switch>

`variant` is `"segmented"` (a track with the chosen icon raised), `"icons"` (the same without the
track, round), `"switch"` (a toggle: on is dark) or `"cards"` (a radiogroup of cards, each with a
small preview of the mode: light, dark, and the two halves side by side for system; the preview
carries its own `data-theme`, so it shows the mode right whatever the page is, in the active palette). `size="sm"` is the compact one;
`system={false}` leaves only light and dark.

## What it does

The `LedgerUI.ThemeSwitch` hook (`priv/static/ledger_ui/hooks/theme_switch.js`) reads the stored
choice (`localStorage["theme"]`: `"light"`, `"dark"` or `"system"`), puts the resolved mode on
`<html data-theme="light|dark">` (the choice itself on `data-theme-choice`), keeps `on`,
`aria-checked` and `tabindex` in step, and makes the markup a `radiogroup` of `radio`s (arrow keys
move the choice) or a `switch`. "System" follows `prefers-color-scheme` live. Every switch on the
page listens to the `ledger:theme` window event and follows.

The mode is apart from the palette (`<html data-palette="ledger|crepusculo">`, chosen with
`theme_picker/1`): every palette has a light and a dark token set, so any mode works with any palette.

Put `<.theme_script />` in the root layout `<head>` so the first paint already has the mode and the palette.

The server renders the light choice (or the one given by `value`); the hook owns the state. The labels travel as
`data-lu-light|dark|system|label` (read by the hook, which turns them into accessible names).

## `<.theme_switch>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `variant` | `:string` | `"segmented"` | `segmented`, `icons`, `switch`, `cards` |
| `size` | `:string` | `"md"` | `md`, `sm` |
| `system` | `:boolean` | `true` |  |
| `value` | `:string` | `nil` | `nil`, `light`, `dark`, `system` - The choice drawn on the server when nothing is stored yet (`nil`: light, then the hook decides). It is only the initial state: it does not change the page mode by itself. |
| `light_label` | `:string` | `"Light"` |  |
| `dark_label` | `:string` | `"Dark"` |  |
| `system_label` | `:string` | `"System"` |  |
| `label` | `:string` | `nil` | Names the group (default "Theme") or the switch (default "Dark mode"). |
| `loop` | `:boolean` | `false` | The demo motion: the raised choice (or the thumb) slides on its own. For the showcase. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:icon>` - `variant="switch"`: what sits beside the track (an icon) instead of the `dark_label` text.

## `<.theme_script>`

Inline script for the root layout `<head>`: applies the stored mode (`data-theme`) and palette
(`data-palette`) before the first paint, so there is no flash. It is plain and synchronous on
purpose (it must block rendering).

    <head>
      <.theme_script />
    </head>

With a strict CSP (`script-src 'nonce-...'`) the browser blocks an inline script that has no
nonce, and the page flashes the wrong mode on first paint. Pass the request nonce:

    <.theme_script nonce={assigns[:csp_nonce]} />

renders `<script nonce="...">`. Without `nonce` the output is the same as always. Other
attributes (`rest`) go to the `<script>` as well.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `theme` | `:string` | `nil` | The named palette when the user chose none (`config :ledger_ui, :theme`). |
| `default` | `:string` | `"system"` | `light`, `dark`, `system` - The mode when nothing is stored. |
| `nonce` | `:string` | `nil` | The CSP nonce put on the `<script>` (`script-src 'nonce-...'`). Omitted when `nil`. |

Any other HTML/phx attribute goes to the root element.

## `<.theme_toggle>`

A single button that flips light and dark: a moon in light mode, a sun in dark (both are in the
markup, the `dark:` variant shows the right one). It shares the storage and the `ledger:theme` event with `theme_switch/1`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"theme-toggle"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
