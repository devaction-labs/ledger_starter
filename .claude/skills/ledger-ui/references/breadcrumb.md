# LedgerUI.Components.Breadcrumb

The trail of pages above the current one; the last `:item` is the current page.

    <.breadcrumb>
      <:item navigate={~p"/customers"}>Customers</:item>
      <:item>Casa das Tintas</:item>
    </.breadcrumb>

An item with `href`, `navigate` or `patch` is a link; one with `phx-click` is a link-looking
button; the others are plain text. `nil`/`false` destinations count as absent. Any other attr
of the item (`phx-target`, `phx-value-*`, `id`, `data-*`, `aria-*`) goes to the link.

`max_items` collapses a long trail: it keeps the first step and the last `max_items - 2`, and
the ones in between become a "…" button opening a `dropdown/1` (id `"#{id}-more"`).

The last step is rendered with `aria-current="page"`; the "…" trigger is a `role="button"`
with `aria-label`, `aria-haspopup`, `aria-expanded` and `aria-controls` (from `dropdown/1`).

`variant` is `canvas` (compact, the current step on a sunken chip, links get a hover chip),
`plain` or `bordered` (every step in a bordered box, no separator). The default is `nil`, the
plain trail, which `plain` repeats. The `:separator` slot replaces the default `/`.

Styled only with Tailwind utilities; every part carries `data-part` (`breadcrumb`,
`breadcrumb-link`, `breadcrumb-current`, `breadcrumb-text`, `breadcrumb-separator`,
`breadcrumb-more`).

Additions to the README: the item attr `icon` (an icon drawn before the step, outside the
link) and `style` (on the current step, or on a span wrapping a link and its separator, for
staggered animations).

## `<.breadcrumb>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `nil` | `nil`, `canvas`, `plain`, `bordered` |
| `label` | `:string` | `"Breadcrumb"` |  |
| `max_items` | `:integer` | `nil` |  |
| `loop` | `:boolean` | `false` | The canvas demo animation: the steps come in one after the other, 0.5s apart, every 6s (each step takes a `--dl` delay). |
| `more_label` | `:string` | `"Show hidden steps"` |  |
| `id` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:item>` (required) - attrs: `href`, `navigate`, `patch`, `class`, `icon`, `style`, `title`, `id`, `phx-click`, `phx-target`, `phx-value-id`
- `<:separator>`
