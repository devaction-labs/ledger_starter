# LedgerUI.Components.Select

Select: the styled native `<select>` (`native`) and a searchable listbox driven by the
`LedgerUI.Select` hook (`priv/static/ledger_ui/hooks/select.js`).

    <.select native label="Type" options={~w(Wedding Birthday Other)} />
    <.select field={@form[:plan]} options={["Pro", "Scale", "Starter"]} />
    <.select field={@form[:states]} options={@states} multiple removable clearable />
    <.select field={@form[:author]} options={@authors} on_search="search_authors" target={@myself}>
      <:option :let={author}>{author.label} · {author.data.job}</:option>
    </.select>

Options are strings, `{label, value}` tuples, maps or `{group, options}` (see
`LedgerUI.Components.Select.Options`).

The listbox submits through a hidden `<select>` named like the field (`name[]` when
`multiple`) and fires a bubbling `input` event when the choice changes, so a surrounding
`phx-change` runs. Opening, closing, keyboard and filtering never leave the browser; a
value sent by the server wins over the one in the browser.

**Width:** the root is `w-[260px]` by default. In a form or a grid pass `class="w-full"` so the
control and the panel take the whole column (like the inputs next to it):

    <.select field={@form[:status]} options={@statuses} multiple class="w-full" />

**Search:** `search` is `"auto"` by default: the filter box is in the control for a single
select and at the top of the panel (focused when it opens) when `multiple`, where the
control is taken by the chips and the `+N`. `"control"`, `"panel"` and `"none"` are kept as
given.

**Height:** with `overflow="count"` (default) a `multiple` control has the height of an
input of the same `size` with 0, 1 or many chips; `overflow="wrap"` grows with the chips.

`on_search` pushes `%{"id" => id, "query" => text}` (after `debounce` ms) and
`on_load_more` pushes `%{"id" => id, "query" => text, "offset" => n}` to `target` or the
LiveView.

## `<.select>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `label_hint` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `options` | `:list` | `[]` |  |
| `prompt` | `:string` | `nil` |  |
| `placeholder` | `:string` | `nil` |  |
| `multiple` | `:boolean` | `false` |  |
| `disabled` | `:boolean` | `false` |  |
| `native` | `:boolean` | `false` |  |
| `variant` | `:string` | `"outline"` | `outline`, `filled` |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill` |
| `inline` | `:boolean` | `false` |  |
| `icon` | `:string` | `nil` | An icon before the text. |
| `removable` | `:boolean` | `false` |  |
| `clearable` | `:boolean` | `false` |  |
| `clear_label` | `:string` | `"Clear"` |  |
| `remove_label` | `:string` | `"Remove"` |  |
| `create` | `:boolean` | `false` |  |
| `create_label` | `:string` | `"Add"` |  |
| `create_hint` | `:string` | `nil` |  |
| `persist` | `:boolean` | `true` |  |
| `restore_on_backspace` | `:boolean` | `false` |  |
| `max` | `:integer` | `nil` |  |
| `overflow` | `:string` | `"count"` | `count`, `wrap` |
| `footer` | `:boolean` | `false` |  |
| `footer_count` | `:string` | `"%{count} of %{total}"` |  |
| `footer_hint` | `:string` | `"Esc to close"` |  |
| `more_label` | `:string` | `"more"` |  |
| `no_results` | `:string` | `"No results found"` |  |
| `search` | `:string` | `"auto"` | `auto`, `control`, `panel`, `none` - Where the filter box is: `auto` is `panel` when `multiple` and `control` otherwise. |
| `search_placeholder` | `:string` | `"Search…"` |  |
| `panel_min_width` | `:string` | `nil` |  |
| `panel_class` | `:any` | `nil` |  |
| `on_search` | `:string` | `nil` |  |
| `debounce` | `:integer` | `300` |  |
| `target` | `:any` | `nil` |  |
| `on_load_more` | `:string` | `nil` |  |
| `has_more` | `:boolean` | `false` |  |
| `loading_label` | `:string` | `"Loading…"` |  |
| `open` | `:boolean` | `false` | Renders the list open (static previews). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`, `autocomplete`, `required`.

Slots:

- `<:below>`
- `<:item>`
- `<:label_aside>`
- `<:option>`
- `<:suffix>`

## `<.listbox>`

A static list of choices (the open panel of a select, without the trigger): the chosen row is
bold with a check, a `disabled` option is dimmed and a `hint` goes at the right.

    <.listbox value="pro" class="w-[280px]" options={[
      {"Pro", "pro"}, "Scale", "Starter",
      {"", [%{label: "Enterprise", hint: "Soon", disabled: true}]}]} />

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `options` (required) | `:list` |  | Options as in `select/1`; a `{label, [options]}` group is set apart by a divider (its label is drawn when not empty). |
| `value` | `:any` | `nil` | The chosen value (or list of values): its row is bold with a check. |
| `label` | `:string` | `nil` | Accessible name of the list. |
| `class` | `:any` | `nil` | Layout classes of the panel (`w-[280px]`). |

Slots:

- `<:option>` - Content of a row (receives the normalized option).
