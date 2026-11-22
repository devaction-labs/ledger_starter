# LedgerUI.Components.MenuList

Menu lists: a vertical list of links with one active entry, plus `menu_item` and `menu_row`.
Styled only with Tailwind utilities: the list carries the look of its links (and of the active
one, marked `data-state="on"`), so a `menu_item` inside a `:row` takes it from the list. Every part
carries `data-part` (`menu-list`, `menu-item`, `menu-item-count`, `menu-rows`, `menu-row`...).

    <.menu_list variant="solid" color="primary">
      <:item navigate={~p"/orders"} active><.icon name="cart" />Orders</:item>
      <:item navigate={~p"/clients"} count={12}>Clients</:item>
    </.menu_list>

    <.menu_list variant="pill" on_select="pick">
      <:item value="shipping" active={@tab == "shipping"}>Shipping</:item>
    </.menu_list>

Items with a destination (`href`, `navigate`, `patch`) are links; items with a `value` push
`on_select` with `%{"value" => value}` (a `%JS{}` runs instead). `variant="static"` with
`:item` slots is the read-only list (links ignore the pointer); with `rows` and `:row` it is the
canvas list of `menu_row`s (a `div`).

Streams: `<.menu_list id="pages" rows={@streams.pages}><:row :let={{_id, page}}>...`.

## Notes

  * An `active` link item (or `menu_item`) carries `aria-current="page"`.
  * Each `:item` accepts any attribute (`style`, `phx-click`, `id`...).
  * `menu_item`'s `variant`/`color` default to `nil`: the item is then a bare `<a>` meant for a
    `menu_list` `:row`; with a variant it is wrapped in its own `lu-ml` navigation.

## `<.menu_list>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `variant` | `:string` | `"link"` | `link`, `solid`, `pill`, `gradient`, `bordered`, `static` |
| `color` | `:string` | `"primary"` | `primary`, `neutral` |
| `on_select` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `rows` | `:any` | `nil` | A list or a stream rendered by `:row`. |
| `row_id` | `:any` | `nil` |  |
| `demo` | `:boolean` | `false` | The animated mock: the highlight walks over the links (stagger them with `style="--dl:1.5s"`). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:item>` - attrs: `href`, `navigate`, `patch`, `active`, `value`, `count`, `class`, `style`, `id`, `title`, `phx-click`, `phx-target`, `phx-value-id`
- `<:row>`

## `<.menu_item>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `nil` | `nil`, `link`, `solid`, `pill`, `gradient`, `bordered` |
| `color` | `:string` | `nil` | `nil`, `primary`, `neutral` |
| `active` | `:boolean` | `false` |  |
| `value` | `:string` | `nil` |  |
| `on_select` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `replace`.

Slots:

- `<:count>`
- `<:icon>`
- `<:inner_block>` (required)

## `<.menu_row>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` | `:string` | `nil` |  |
| `sub` | `:string` | `nil` |  |
| `unread` | `:boolean` | `false` |  |
| `unread_label` | `:string` | `"Unread"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `replace`.

Slots:

- `<:icon>`
- `<:inner_block>`
- `<:value>`

## `<.menu>`

Same as `menu_list/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `variant` | `:string` | `"link"` | `link`, `solid`, `pill`, `gradient`, `bordered`, `static` |
| `color` | `:string` | `"primary"` | `primary`, `neutral` |
| `on_select` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `rows` | `:any` | `nil` | A list or a stream rendered by `:row`. |
| `row_id` | `:any` | `nil` |  |
| `demo` | `:boolean` | `false` | The animated mock: the highlight walks over the links. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:item>` - attrs: `href`, `navigate`, `patch`, `active`, `value`, `count`, `class`, `style`, `id`, `title`, `phx-click`, `phx-target`, `phx-value-id`
- `<:row>`
