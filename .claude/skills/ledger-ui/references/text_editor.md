# LedgerUI.Components.TextEditor

Rich text editor on a plain `contenteditable` (bold, italic, underline, strike, quote, code,
headings, lists, sub/superscript, indent, text direction, size, font, colors, alignment, links
and clean), plus its compact `variant="comment"` form for threads.

    <.text_editor field={@form[:body]} placeholder="Escreva..." />
    <.text_editor name="note" toolbar={[~w(bold italic underline), ~w(list-ordered list-bullet)]} />
    <.text_editor name="post" filled content_class="h-72" />

    <.text_editor name="comment" variant="comment" on_submit="comment"
      mentions={[%{handle: "juliana-moraes", label: "Juliana Moraes"}]}
      placeholder="Escreva um comentario" />

The HTML is submitted through a hidden input named like the field, and each edit fires a
bubbling `input` event, so `phx-change` runs. The HTML given to the editor is cleaned on the
server by `sanitize/2` (and again in the browser, as is pasted HTML): only formatting tags and
safe links stay. **Sanitize what you store as well.** A value sent by the server replaces the
text; the same value echoed back does not touch it.

`slash` opens a menu of blocks when "/" is typed at the start of a word; `variables` adds the
placeholders of a template (`{cliente}` is drawn as a chip and goes to the server as plain
text); the `:ai` slot is a button at the end of the toolbar (`on_ai` is pushed with the HTML and
the selected text; answer with `insert_html/3`); `footer` draws a bar with a hint and the word
count. In a comment, "@" opens the list of `mentions` (chips sent as `@handle`) and
Ctrl/Cmd+Enter submits (`on_submit`).

Three toolbar buttons are opt-in: `mark` (highlight), `variable` and `image`. `image` asks for
the address and description, or, with `on_image`, pushes the event so the app can upload the
file and answer with `insert_image/4`.

The behaviour lives in the `LedgerUI.TextEditor` hook (`text_editor.js`); the editor needs a
stable `id` (from `field` or `name`).

`text_editor_content/1` shows saved HTML read-only, in the editor's type.

## `<.text_editor>`

Renders a rich text editor.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `toolbar` | `:list` | `[["bold", "italic", "underline", "strike"], ["blockquote", "code-block"], ["header-1", "header-2"], ["list-ordered", "list-bullet"], ["script-sub", "script-super"], ["indent-minus1", "indent-plus1"], ["direction-rtl"], ["size"], ["header"], ["color", "background"], ["font"], ["align"], ["clean"]]` |  |
| `filled` | `:boolean` | `false` |  |
| `content_class` | `:any` | `nil` |  |
| `link_label` | `:string` | `nil` |  |
| `tool_labels` | `:map` | `%{}` |  |
| `on_image` | `:string` | `nil` |  |
| `images` | `:boolean` | `false` |  |
| `image_label` | `:string` | `nil` |  |
| `image_alt_label` | `:string` | `nil` |  |
| `image_save_label` | `:string` | `nil` |  |
| `save_label` | `:string` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `debounce` | `:integer` | `300` |  |
| `target` | `:any` | `nil` |  |
| `variant` | `:string` | `"default"` | `default`, `comment` |
| `density` | `:string` | `"comfortable"` | `comfortable`, `compact` - `compact` is the canvas frame: 12px radius, 28px toolbar buttons with small icons, a 90px text area with 12/14px padding and 14px type. |
| `loop` | `:boolean` | `false` | The canvas demo animation: the toolbar buttons light up in turn (1.2s apart, every 6s). |
| `slash` | `:boolean` | `false` |  |
| `slash_items` | `:list` | `nil` | Maps with `:label`, `:key`, `:hint` and `:icon`; default: the locale's (text, headings, lists, quote, code, divider). |
| `on_slash` | `:string` | `nil` |  |
| `slash_title` | `:string` | `nil` |  |
| `variables` | `:list` | `[]` |  |
| `variable_label` | `:string` | `nil` |  |
| `variable_title` | `:string` | `nil` |  |
| `mentions` | `:list` | `[]` |  |
| `mention_title` | `:string` | `nil` |  |
| `mention_button` | `:boolean` | `true` |  |
| `mention_label` | `:string` | `nil` |  |
| `on_ai` | `:string` | `nil` |  |
| `on_submit` | `:string` | `nil` |  |
| `submit_label` | `:string` | `nil` |  |
| `submit_key` | `:any` | `"Ctrl ↵"` |  |
| `submit_hint` | `:string` | `nil` | Text after the shortcut ("to send"). |
| `bar` | `:boolean` | `true` |  |
| `clear_on_submit` | `:boolean` | `true` |  |
| `footer` | `:boolean` | `false` |  |
| `hint` | `:string` | `nil` |  |
| `words_label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - The buttons of a comment's bar, before the submit button (attach...).
- `<:ai>` - The content of a button at the end of the toolbar that asks the assistant.
- `<:attachments>` - What a comment carries (files as chips), between the text and the bar.

## `<.text_editor_content>`

Shows saved rich text, read-only, in the editor's type. `value` is escaped unless it is already
marked safe (`{:safe, html}` / `Phoenix.HTML.raw/1`): pass safe HTML only after `sanitize/2`.
The inner block wins.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `value` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.rich_text_editor>`

Same as `text_editor/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `toolbar` | `:list` | `[["bold", "italic", "underline", "strike"], ["blockquote", "code-block"], ["header-1", "header-2"], ["list-ordered", "list-bullet"], ["script-sub", "script-super"], ["indent-minus1", "indent-plus1"], ["direction-rtl"], ["size"], ["header"], ["color", "background"], ["font"], ["align"], ["clean"]]` |  |
| `filled` | `:boolean` | `false` |  |
| `content_class` | `:any` | `nil` |  |
| `link_label` | `:string` | `nil` |  |
| `tool_labels` | `:map` | `%{}` |  |
| `on_image` | `:string` | `nil` |  |
| `images` | `:boolean` | `false` |  |
| `image_label` | `:string` | `nil` |  |
| `image_alt_label` | `:string` | `nil` |  |
| `image_save_label` | `:string` | `nil` |  |
| `save_label` | `:string` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `debounce` | `:integer` | `300` |  |
| `target` | `:any` | `nil` |  |
| `variant` | `:string` | `"default"` | `default`, `comment` |
| `density` | `:string` | `"comfortable"` | `comfortable`, `compact` |
| `loop` | `:boolean` | `false` |  |
| `slash` | `:boolean` | `false` |  |
| `slash_items` | `:list` | `nil` |  |
| `on_slash` | `:string` | `nil` |  |
| `slash_title` | `:string` | `nil` |  |
| `variables` | `:list` | `[]` |  |
| `variable_label` | `:string` | `nil` |  |
| `variable_title` | `:string` | `nil` |  |
| `mentions` | `:list` | `[]` |  |
| `mention_title` | `:string` | `nil` |  |
| `mention_button` | `:boolean` | `true` |  |
| `mention_label` | `:string` | `nil` |  |
| `on_ai` | `:string` | `nil` |  |
| `on_submit` | `:string` | `nil` |  |
| `submit_label` | `:string` | `nil` |  |
| `submit_key` | `:any` | `"Ctrl ↵"` |  |
| `submit_hint` | `:string` | `nil` | Text after the shortcut ("to send"). |
| `bar` | `:boolean` | `true` |  |
| `clear_on_submit` | `:boolean` | `true` |  |
| `footer` | `:boolean` | `false` |  |
| `hint` | `:string` | `nil` |  |
| `words_label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - The buttons of a comment's bar, before the submit button (attach...).
- `<:ai>` - The content of a button at the end of the toolbar that asks the assistant.
- `<:attachments>` - What a comment carries (files as chips), between the text and the bar.

## `<.comment_editor>`

Same as `text_editor/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `toolbar` | `:list` | `[["bold", "italic", "underline", "strike"], ["blockquote", "code-block"], ["header-1", "header-2"], ["list-ordered", "list-bullet"], ["script-sub", "script-super"], ["indent-minus1", "indent-plus1"], ["direction-rtl"], ["size"], ["header"], ["color", "background"], ["font"], ["align"], ["clean"]]` |  |
| `filled` | `:boolean` | `false` |  |
| `content_class` | `:any` | `nil` |  |
| `link_label` | `:string` | `nil` |  |
| `tool_labels` | `:map` | `%{}` |  |
| `on_image` | `:string` | `nil` |  |
| `images` | `:boolean` | `false` |  |
| `image_label` | `:string` | `nil` |  |
| `image_alt_label` | `:string` | `nil` |  |
| `image_save_label` | `:string` | `nil` |  |
| `save_label` | `:string` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `on_change` | `:string` | `nil` |  |
| `debounce` | `:integer` | `300` |  |
| `target` | `:any` | `nil` |  |
| `variant` | `:string` | `"comment"` | `default`, `comment` |
| `density` | `:string` | `"comfortable"` | `comfortable`, `compact` |
| `loop` | `:boolean` | `false` |  |
| `slash` | `:boolean` | `false` |  |
| `slash_items` | `:list` | `nil` |  |
| `on_slash` | `:string` | `nil` |  |
| `slash_title` | `:string` | `nil` |  |
| `variables` | `:list` | `[]` |  |
| `variable_label` | `:string` | `nil` |  |
| `variable_title` | `:string` | `nil` |  |
| `mentions` | `:list` | `[]` |  |
| `mention_title` | `:string` | `nil` |  |
| `mention_button` | `:boolean` | `true` |  |
| `mention_label` | `:string` | `nil` |  |
| `on_ai` | `:string` | `nil` |  |
| `on_submit` | `:string` | `nil` |  |
| `submit_label` | `:string` | `nil` |  |
| `submit_key` | `:any` | `"Ctrl ↵"` |  |
| `submit_hint` | `:string` | `nil` | Text after the shortcut ("to send"). |
| `bar` | `:boolean` | `true` |  |
| `clear_on_submit` | `:boolean` | `true` |  |
| `footer` | `:boolean` | `false` |  |
| `hint` | `:string` | `nil` |  |
| `words_label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>` - The buttons of a comment's bar, before the submit button (attach...).
- `<:ai>` - The content of a button at the end of the toolbar that asks the assistant.
- `<:attachments>` - What a comment carries (files as chips), between the text and the bar.
