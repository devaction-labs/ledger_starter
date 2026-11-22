# LedgerUI.Components.Pagination

Pagination: the canvas pager (`shape` `canvas`, `rounded` or `pill`) or the classic bar of
buttons (`shape="classic"`), in three sizes. Styled only with Tailwind utilities; every part
carries `data-part` (`pagination`, `pagination-page`, `pagination-arrow`, `pagination-ellipsis`,
`pagination-footer`, `pagination-summary`, `pagination-size`...).

    <.pagination page={@page} total_pages={10} patch={&"/orders?page=#{&1}"} />
    <.pagination page={@page} total_pages={10} on_change="paginate" shape="pill" />

Each page is a link when `patch`, `navigate` or `href` is given (a function from the page number
to a path); otherwise a button pushing `on_change` with `%{"page" => "3"}` (to `target`). With
neither, the pager is display-only (plain `span`s). Pages far from the current one collapse
into `…`: `siblings` pages on each side of the current one and `boundaries` at each end.

A list footer: `total_entries` and `page_size` add the "Showing 1–15 of 128" summary (and work
out `total_pages`), `page_sizes` a rows-per-page select in its own `<form>` pushing
`on_page_size` with `%{"page_size" => "30"}`. With a summary, a select or an `:aside` the root
is a `lu-row` around the pages.

The canvas shapes style `> span`, so interactive pages are `span`s holding the
button or link. `summary` defaults to "Showing %{first}–%{last} of %{total}" when
`total_entries` is given; an explicit `summary` is shown as-is without it.
Accessibility, rendered server-side: the current page carries `aria-current="page"` (on the
link/button, or on the `span` when the pager is display-only), every page and arrow has an
`aria-label` (`page_label`, `prev_label`, `next_label`), the summary is `role="status"`.
`shape="classic"` is an addition to the README.

## `<.pagination>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `page` (required) | `:integer` |  |  |
| `total_pages` | `:integer` | `nil` |  |
| `total_entries` | `:integer` | `nil` |  |
| `page_size` | `:integer` | `nil` |  |
| `page_sizes` | `:list` | `[]` |  |
| `on_page_size` | `:any` | `nil` |  |
| `summary` | `:string` | `nil` |  |
| `page_size_label` | `:string` | `nil` |  |
| `page_size_aria` | `:string` | `nil` |  |
| `siblings` | `:integer` | `1` |  |
| `boundaries` | `:integer` | `1` |  |
| `patch` | `:any` | `nil` |  |
| `navigate` | `:any` | `nil` |  |
| `href` | `:any` | `nil` |  |
| `on_change` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `divided` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | The animated mock: pages 1-4 take the current look in turn (give `page={0}`). |
| `shape` | `:string` | `"canvas"` | `canvas`, `rounded`, `pill`, `classic` |
| `variant` | `:string` | `nil` | `nil`, `canvas`, `rounded`, `pill`, `classic` - The same as `shape`; it wins when given. |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `arrows` | `:boolean` | `true` |  |
| `arrows_at` | `:string` | `"end"` | `end`, `sides` - Where the arrows go in the canvas pager: `end` (the bundle: both after the pages) or `sides` (previous before the pages, next after them, as in the classic bar). |
| `prev_label` | `:string` | `nil` |  |
| `next_label` | `:string` | `nil` |  |
| `page_label` | `:string` | `nil` |  |
| `page_attrs` | `:any` | `nil` | Function from a page number (or `:ellipsis`) to extra attrs (`%{style: ..., class: ...}`) of its item, e.g. for staggered animations. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:aside>`
