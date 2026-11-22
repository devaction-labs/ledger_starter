# LedgerUI.Components.PlacementStage

An image (a rendered PDF page, a photo) with a dashed box on it that the user positions by
clicking or dragging, and resizes from a corner handle.

    <.placement_stage
      id="pdf-stage"
      src={@image}
      alt="Page 1"
      box={%{left: 10, bottom: 20, width: 30, height: 8}}
      resizable
      on_place="place_signature"
      on_resize="resize_signature"
    >
      Signature appears here
    </.placement_stage>

## The box

`box` is a map of percentages of the image: `left` (from the left edge), `bottom` (from the
bottom edge), `width` and `height`, which is how the CSS is written (`left:10%;bottom:20%`). A
`nil` box draws no box. The slot is the content of the box (a label, an icon).

## Events

The `LedgerUI.PlacementStage` hook (`priv/static/ledger_ui/hooks/placement_stage.js`) moves the
box at once, in the browser (optimistic), limited to the edges of the image, and tells the
server at the end of the gesture (pointer up or click):

  * `on_place`, `%{"x" => x, "y" => y}`: the **centre** of the box, as fractions `0..1` of the
    image; `x` counts from the **left** edge and `y` from the **top** edge. The centre is the
    one of the box as it is shown, already limited so the box stays inside the image.
  * `on_resize`, `%{"width" => w}`: the new width, a fraction `0..1` of the image width. The
    handle keeps the centre and the proportions of the box (so the height follows), and the
    width is never less than 5% nor more than the image allows around the centre.

Event names are strings; `phx-target` (for a live component) is read from the component.

Pointer events cover mouse, pen and touch (`touch-action: none` on the stage, pointer capture).
Pressing the image puts the centre of the box under the pointer. The box is focusable: the arrow
keys move it by 1% of the image (Shift: 10%) and every key press pushes `on_place`. `label` is
its `aria-label`.

The server wins: a new `box` replaces what the browser shows, except in the middle of a gesture
(it is ignored until the pointer is released) and while an event of this component has not been
answered yet (an unchanged `box` does not undo a move that is on its way to the server).

`resizable={false}` removes the handle; `disabled` shows the box and takes away the gestures.

## `<.placement_stage>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `src` (required) | `:string` |  |  |
| `alt` | `:string` | `""` |  |
| `box` | `:map` | `nil` | `%{left, bottom, width, height}`, in % of the image. |
| `resizable` | `:boolean` | `true` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_place` | `:string` | `nil` |  |
| `on_resize` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element, including `phx-target`.

Slots:

- `<:inner_block>`
