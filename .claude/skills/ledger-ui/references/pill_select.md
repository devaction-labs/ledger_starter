# LedgerUI.Components.PillSelect

A quick filter of chips where the chosen ones take the accent: one choice by default, several
with `multiple`.

    <.pill_select field={@form[:canal]} options={["Todos", "Balcão", "Online"]} />
    <.pill_select field={@form[:categorias]} multiple options={~w(Tintas Básico Ferramentas)} />
    <.pill_select name="canal" value="todos" options={[
      %{label: "Todos", value: "todos", count: 128},
      %{label: "Balcão", value: "balcao", count: 64}
    ]} />

Options are strings, `{label, value}` tuples or maps with `:label`, `:value`, `:count` and
`:disabled`. Each pill is a chip button (`aria-pressed` draws the chosen one) and the choice is made in the
browser by the `LedgerUI.PillSelect` hook; the values travel in hidden inputs (`name`, or
`name[]` with `multiple`, preceded by an empty one so an emptied choice still reaches the
server) that fire a bubbling `input` event, so the form's `phx-change` runs. Without a form,
`on_change` is pushed on each click with `%{"id" => id, "value" => value}` to `target`.

## `<.pill_select>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `options` (required) | `:list` |  |  |
| `multiple` | `:boolean` | `false` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`.
