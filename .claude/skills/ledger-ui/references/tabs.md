# LedgerUI.Components.Tabs

Tabs: `line`, `boxed`, `pill`, `text`, `segmented` and `nav`, plus the `classic` underline tabs
with count badges, horizontal or vertical. Styled only with Tailwind utilities; the selected tab
carries `data-state="on"` (and `aria-selected`) and the utilities read it (`data-[state=on]:text-ink`...).

    <.tabs id="profile" selected="home" on_change="select_tab">
      <:tab name="home">Home</:tab>
      <:tab name="profile" count={4}>Profile</:tab>
      <:panel name="home">...</:panel>
      <:panel name="profile">...</:panel>
    </.tabs>

Switching happens in the browser through the hook `LedgerUI.Tabs`
(`priv/static/ledger_ui/hooks/tabs.js`): click, ←/→ (↑/↓ when vertical), Home and End, no
round trip. A choice made in the browser survives patches; when the server changes
`selected` the server wins. `on_change` (an event name or a `%JS{}`) is pushed with
`%{"id" => id, "value" => name, "tab" => name}`, and every selection dispatches a
bubbling `ledger:change` event with `detail: {id, value, tab}`.

Tabs with `patch`, `navigate` or `href` are links (`aria-current="page"` when selected).

## Notes on the markup

The server renders the ARIA: `role="tablist"` (+ `aria-orientation` when vertical), tab buttons
with `role="tab"`, `aria-selected`, the roving `tabindex` and `aria-controls` (when there is a
panel); the hook only updates `aria-selected`/`tabindex`/`data-state` as the selection changes.
`color` (`primary`, the default look, or `neutral`) tints the `pill` and `text` variants. Panels
are `role="tabpanel"` boxes that the hook shows/hides; there is no sliding transition,
`transition` is exposed as `data-transition` for apps that style it (and `loop` runs the
canvas demo where the panels come in from the left or from below by themselves). `bordered`, `overlap` and
`grow` are kept for compatibility and have no visual effect.

Every part carries `data-part`: `tabs`, `tabs-list`, `tab`, `tab-count`, `tabs-panels`, `tabs-panel`.

Additive tab attrs: `role` (pass `nil` to drop it) and `count_tone` (`acc`, `neg`...).

## `<.tabs>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `selected` | `:string` | `nil` |  |
| `variant` | `:string` | `"line"` | `line`, `boxed`, `pill`, `text`, `segmented`, `nav`, `classic` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md` |
| `color` | `:string` | `nil` | `nil`, `primary`, `neutral` |
| `orientation` | `:string` | `"horizontal"` | `horizontal`, `vertical` |
| `bordered` | `:boolean` | `false` |  |
| `overlap` | `:boolean` | `false` |  |
| `grow` | `:boolean` | `false` |  |
| `transition` | `:string` | `"left"` | `left`, `up`, `none` |
| `loop` | `:boolean` | `false` | The canvas demo (`variant="line"`, up to 3 tabs): the indicator slides under the tabs, the tab text follows it and the panels come in (`transition` left or up) every 6s, by themselves. |
| `loop_widths` | `:list` | `~c"nnn"` | `loop`: the widths in px of the tabs (set them yourself, e.g. `class="w-[110px]"`) to place the indicator; the gap is the 22px of the line list. |
| `on_change` | `:any` | `nil` |  |
| `soon_label` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `list_class` | `:any` | `nil` |  |
| `panels_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:panel>` - attrs: `name` (required), `class`
- `<:tab>` (required) - attrs: `name`, `active`, `disabled`, `count`, `overdue`, `count_tone`, `patch`, `navigate`, `href`, `replace`, `soon`, `role`, `aria-selected`, `title`, `id`, `class`, `phx-click`, `phx-target`, `phx-value-id`, `phx-value-name`
