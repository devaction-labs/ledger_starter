# LedgerUI.Components.DescriptionList

Label and value pairs in a grid, as the canvas description list: the label small and faint, the
value in the ink colour. For the short data of a detail (an order, a client). Styled only with
Tailwind utilities.

    <.description_list cols={2}>
      <:item label="Razão social">Mercadinho Bom Preço Ltda</:item>
      <:item label="CNPJ" mono>12.345.678/0001-90</:item>
    </.description_list>

`cols` is 1 to 4. `layout="inline"` puts the label at the left and the value at the right. An
item with no content shows `empty` ("—"). An item takes `id`, `class` and `style` for its
`<dd>`, and `wrapper_id`, `wrapper_class` and `wrapper_style` for the `<div>` around the pair.

## `<.description_list>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `cols` | `:integer` | `2` | `1`, `2`, `3`, `4` |
| `layout` | `:string` | `"stacked"` | `stacked`, `inline` |
| `variant` | `:string` | `nil` | `nil`, `stacked`, `inline` - The same as `layout`; it wins when given. |
| `empty` | `:string` | `"—"` |  |
| `class` | `:any` | `nil` |  |
| `style` | `:string` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:item>` (required) - attrs: `label`, `title`, `mono`, `id`, `class`, `style`, `wrapper_id`, `wrapper_class`, `wrapper_style` - A pair: `label`, and the value as content.
