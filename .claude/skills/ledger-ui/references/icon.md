# LedgerUI.Components.Icon

Server-side SVG icons (Hugeicons Stroke Rounded), no JavaScript needed.

    <.icon name="download" />
    <.icon name="huge-download-01" size="sm" class="text-muted" />
    <.icon name="check-circle" boxed tone="success" />

The SVG is styled only with Tailwind utilities (stroke follows `currentColor`, so `text-*`
colours it). `size` picks the box: `sm` 14px, `md` 16px, `base` 18px (default), `lg` 22px,
`xl` 28px. Use `size`, not a `size-*` class, to change it: two utilities of one property in a
class list are resolved by the stylesheet, not by their order.

    <svg class="... size-[18px]" viewBox="0 0 24 24" aria-hidden="true" data-icon="download">...</svg>

Every icon is precomputed at compile time from `priv/icons.json` (regenerate it with
`elixir scripts/extract_icons.exs`) as an iodata binary and emitted with `Phoenix.HTML.raw/1`,
so rendering costs one map lookup.

## Names

Dictionary keys (`download`, `chevron-down`, ...) are used as-is. The API's `huge-*` names
are accepted too: `huge-` (or `hugeicons:`) is stripped, then the exact key is tried, then
the key without a trailing `-NN` suffix (`huge-download-01` -> `download-01` -> `download`).
Unknown names render nothing and log a warning (disable with
`config :ledger_ui, warn_unknown_icons: false`).

## Vendored icons

Icons outside the dictionary come from the app's own folder, filled by `mix ledger_ui.icons`
(`get`, `sync`; see `LedgerUI.Icons`):

    config :ledger_ui, :icons_path, "priv/hugeicons"

    <.icon name="huge-invoice-01" />

They are loaded once into `:persistent_term` and render the same markup as the built-in ones.
Order of lookup: a built-in key (exact, after dropping `huge-`), then a vendored file of that
name, then the built-in key without its `-NN` suffix. So a built-in name always wins over a
vendored file of the same name, while `huge-download-01` finds the vendored `download-01.svg`
before settling for the built-in `download`.

## Box

`boxed` wraps the icon in a rounded square box (32px; 44px with `box_size="lg"`); `tone` colours it (`accent`/`acc`, `success`/`pos`,
`error`/`neg`, `warning`/`warn`, `info`, `lime`, `neutral`). `box_size="lg"` gives the large
box; any number of pixels sets width/height inline. The inner block replaces `name`.

## `<.icon>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` | `:string` | `nil` | Icon name (dictionary key or `huge-*`). |
| `size` | `:string` | `"base"` | `nil`, `base`, `lg`, `md`, `sm`, `xl` - `sm` 14px, `md` 16px, `base` 18px, `lg` 22px, `xl` 28px (`nil` is `base`). |
| `class` | `:any` | `nil` |  |
| `boxed` | `:boolean` | `false` | Wraps the icon in a rounded square box. |
| `tone` | `:string` | `nil` | `nil`, `acc`, `accent`, `error`, `info`, `lime`, `neg`, `neutral`, `pos`, `success`, `warn`, `warning` - Box colour (needs `boxed`). |
| `box_size` | `:any` | `nil` | `"lg"` or a size in pixels. |
| `box_class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` - Own SVG inside the box, instead of `name`.
