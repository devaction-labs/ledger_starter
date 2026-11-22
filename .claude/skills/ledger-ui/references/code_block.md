# LedgerUI.Components.CodeBlock

Code, terminal output, logs and diffs in a dark card (the same dark palette in every theme),
styled only with Tailwind utilities: an optional header with a title and a copy button, line
numbers, wrapping, added, removed and highlighted lines, and a small size for tool output inside
a `LedgerUI.Components.Trace.trace/1`.

    <.code_block id="install" title="Terminal" icon="terminal" code={@output} line_numbers wrap />

`code` is a string split into lines. `lines` is a list instead, each a string or a map with
`:text` (or `:html`, already safe HTML) and `:variant` (`"added"`, `"removed"`, `"highlighted"`):

    <.code_block id="diff" title="mix.exs" lines={[
      "defp deps do",
      %{text: ~s(  {:phoenix, "~> 1.7"},), variant: "removed"},
      %{text: ~s(  {:phoenix, "~> 1.8"},), variant: "added"},
      "end"
    ]} />

## Syntax highlighting

`language` (`"elixir"`, `"js"`) highlights the text of each line on the server, one colour
utility per token (keyword, string/atom, comment, function/module, number); see `highlight/2`. No client library is involved. Without `language` the text is
only escaped. The block (`:inner_block`) can also hold your own safe HTML, drawn as is.

## Copy

`copy` adds a button (hook `LedgerUI.CodeBlock`, file `priv/static/ledger_ui/hooks/code_block.js`)
that copies the code without line numbers. It needs the `id`.

## `<.code_block>`

Renders the code block.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `code` | `:string` | `nil` | The code, split into lines. |
| `lines` | `:list` | `nil` | Strings or maps with `:text` (or `:html`) and `:variant` (added, removed, highlighted). |
| `language` | `:string` | `nil` | Highlights each line server-side: `elixir`, `js`. |
| `highlight` | `:list` | `[]` | Line numbers drawn highlighted. |
| `title` | `:string` | `nil` |  |
| `icon` | `:string` | `nil` |  |
| `copy` | `:boolean` | `false` |  |
| `copy_label` | `:string` | `nil` |  |
| `copy_text` | `:string` | `nil` | What the copy button copies; the code itself when `nil`. |
| `line_numbers` | `:boolean` | `false` |  |
| `start_line` | `:integer` | `1` |  |
| `wrap` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | The canvas loop: the lines appear one after the other (0.35s apart) and fade out, forever. |
| `max_height` | `:integer` | `nil` |  |
| `size` | `:string` | `"default"` | `default`, `sm` |
| `variant` | `:string` | `"default"` | `default`, `destructive` |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - Buttons next to the copy button, in the header.
- `<:footer>` - A row under the code.
- `<:inner_block>` - Code as safe HTML (highlighted), drawn as is.
