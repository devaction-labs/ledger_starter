# LedgerUI.Components.Chip

The chip: a small tag for a quick filter, an applied filter or a selected person.

    <.chip>Hoje</.chip>
    <.chip selected={@pro?} phx-click="toggle" value="pro">Pro</.chip>
    <.chip selected={false} count={12}>Atrasados</.chip>
    <.chip dashed icon="plus">Filtro</.chip>
    <.chip label="Situação: Aprovação" on_remove={JS.hide(to: "#c1")} id="c1" />
    <.chip avatar="Marina Costa" on_remove="remove_person" id="p-1">Marina Costa</.chip>
    <.chip patch={~p"/extract?account=1"} label="Conta 1" />
    <.chip label="Aberta" remove_patch={~p"/tasks"} />

  * a plain chip is a `<span>`; with `selected` (`true`/`false`) it is a toggle button
    (`aria-pressed`, the chosen state is the inverse colour) that flips in the browser unless
    you give it a `phx-click`; `dashed` and `phx-click` make it a button too;
  * with `href`, `navigate` or `patch` it is a link and has no x;
  * `on_remove` (an event name, pushed with `%{"id" => id}` to `target`, or a `JS` command)
    adds the x button; `remove_patch` makes the x a `patch` link instead;
  * `size` is the height: `sm` 24px (chips inside a field), `md` 30px (default), `lg` 32px
    (`<.chip size="lg">`); padding, font and icon stay the same.

## `<.chip>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` | `:string` | `nil` |  |
| `selected` | `:boolean` | `nil` | `true`/`false` makes the chip a toggle. |
| `dashed` | `:boolean` | `false` |  |
| `tone` | `:string` | `nil` | `nil`, `default`, `acc` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` - Height: 24px, 30px or 32px. |
| `icon` | `:string` | `nil` |  |
| `count` | `:any` | `nil` |  |
| `avatar` | `:string` | `nil` |  |
| `avatar_color` | `:string` | `nil` |  |
| `avatar_src` | `:string` | `nil` |  |
| `on_remove` | `:any` | `nil` |  |
| `remove_patch` | `:string` | `nil` |  |
| `id` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `remove_label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element, including `href`, `navigate`, `patch`, `method`, `download`, `value`, `disabled`.

Slots:

- `<:inner_block>`
