# LedgerUI.Components.Textarea

Multi-line text field: `outlined`, `filled` or `plain`, fixed or resizable, with a live
character counter, autogrow, `{{token}}` highlighting and optional header/footer bars.

    <.textarea field={@form[:bio]} label="Bio" variant="filled" resizable />
    <.textarea name="note" maxlength={200} counter autogrow max_rows={8} />
    <.textarea name="why" counter min_length={20} counter_format="%{count} de %{max}" />
    <.textarea name="msg" tokens value="A fatura {{fatura.numero}} esta atrasada." />

    <.textarea name="post" rows={5}>
      <:header><span class="text-xs text-muted">Variaveis</span></:header>
      <:footer><span>toolbar</span></:footer>
    </.textarea>

With `counter`, `maxlength` is a soft limit: the counter warns from 90% and turns red past it,
and the browser does not refuse the characters (validate on the server).

The counter (`counter`), `autogrow` and `tokens` run in the `LedgerUI.Textarea` hook, which
needs a stable `id` (it comes from `field`, or `name`). The counter updates while typing, without
the server. A plain textarea needs no hook.

## `<.textarea>`

Renders a `<textarea>` inside its frame, with its caption, help and errors.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `rows` | `:integer` | `nil` | Lines shown. Without it the field is the design's 84px (`min-height`); more lines make it taller. |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled`, `plain` |
| `size` | `:string` | `nil` | `nil`, `sm`, `md`, `lg` |
| `resizable` | `:boolean` | `false` |  |
| `counter` | `:boolean` | `false` |  |
| `counter_format` | `:string` | `"%{count} / %{max}"` |  |
| `counter_align` | `:string` | `"end"` | `end`, `start` |
| `min_length` | `:integer` | `nil` |  |
| `autogrow` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | Demo animation (CSS only, needs `counter`): the counter counts up (12, 168, 196, warning colours). `value` is not counted. |
| `max_rows` | `:integer` | `nil` |  |
| `tokens` | `:boolean` | `false` |  |
| `state` | `:string` | `nil` | `nil`, ``, `success`, `error` |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `label_hint` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `frame_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `autocomplete`, `autofocus`, `cols`, `form`, `maxlength`, `minlength`, `placeholder`, `readonly`, `required`, `wrap`.

Slots:

- `<:footer>` - Content below the text, laid out as a row (`ml-auto` sends an item to the end).
- `<:header>` - Content above the text, laid out as a row.
