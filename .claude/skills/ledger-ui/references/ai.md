# LedgerUI.Components.Ai

The assistant ("Assistente (IA)"): the conversation, its messages, the proposals the user
approves, the queries the assistant shows it made, the field to ask, the list of conversations
and the starting suggestions. The assistant proposes and the user approves; nothing changes
without a confirmation.

    <.ai_chat id="assistente" messages={@messages} user={@current_user}
      on_send="send" on_approve="approve" on_reject="reject" />

Or piece by piece (`ai_message/1`, `ai_proposal/1`, `ai_tool_trace/1`, `ai_composer/1`,
`conversation_list/1`, `prompt_suggestions/1`, `ai_insights/1`, `ai_promo/1`, `ai_greeting/1`).

A message of `ai_chat` is a map: `:id`, `:role` (`:user` or `:assistant`), `:text` (paragraphs
separated by a blank line, `**bold**` is bold), `:name` (of the user, for the avatar), `:trace`
(`%{tools: [...], duration_ms: 3000, running: false}`), `:proposal` (`%{id:, title:, status:,
changes: [%{label:, from:, to:, text:}], note:, editable:}`), `:streaming` and `:status`.
`messages` can be a list or a LiveView stream (`stream(socket, :messages, ...)`).

The composer is a form: Enter sends, Shift+Enter breaks the line (hook `LedgerUI.AiComposer`,
file `priv/static/ledger_ui/hooks/ai_composer.js`). With `streaming` the form gets `data-lu-streaming` and
Enter does not send until the answer is over (the stop button replaces send; Shift+Enter still breaks the line).

## `<.ai_insights>`

Card of AI insights: icon, title, sentence with bold numbers, impact badge and action.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `insights` (required) | `:list` |  | Maps `%{icon, title, text, impact, tone, action, href, navigate, patch, style}`; `**bold**` in `text` is bold. |
| `variant` | `:string` | `"card"` | `card`, `list` - `card` has the header; `list` is the items only. |
| `title` | `:string` | `nil` |  |
| `count` | `:integer` | `nil` | Number of new insights, as a badge in the header. |
| `count_label` | `:string` | `nil` |  |
| `on_chat` | `:any` | `nil` | Shows the chat button in the header; an event name or a `JS` command. |
| `chat_label` | `:string` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.ai_promo>`

Call to the assistant pinned on the sidebar, with insight count and main action.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `title` | `:string` | `nil` |  |
| `count` | `:integer` | `nil` | Number of new suggestions/insights. |
| `subtitle` | `:string` | `nil` | Replaces the default "N novas sugestões". |
| `text` | `:string` | `nil` | A sentence under the title (card variant). |
| `action` | `:string` | `nil` | Label of the main action button (card variant). |
| `variant` | `:string` | `"card"` | `card`, `rail` |
| `tone` | `:string` | `"brand"` | `brand`, `warm` |
| `on_click` | `:any` | `nil` | Event name or `JS` command of the call (the action for `card`). |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.ai_greeting>`

The greeting of the assistant: the first line in a gradient and the question under it.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` | `:string` | `nil` | Who is greeted; `Bom dia` / `Boa tarde` / `Boa noite` by the hour. |
| `greeting` | `:string` | `nil` | Replaces the whole first line. |
| `tagline` | `:string` | `nil` |  |
| `size` | `:string` | `"lg"` | `sm`, `md`, `lg` |
| `tone` | `:string` | `"brand"` | `brand`, `warm` |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.ai_tool_trace>`

What the assistant consulted: summary (count and time) and one row per query.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `tools` | `:list` | `[]` | Maps `%{label, title, detail, ms, icon, failed, running}`. |
| `steps` | `:list` | `[]` | The same as `tools`. |
| `running` | `:boolean` | `false` | The queries are still going on. |
| `expanded` | `:boolean` | `false` | Opens the list of queries. |
| `duration_ms` | `:integer` | `nil` | The total time, shown in seconds. |
| `loop` | `:boolean` | `false` | The canvas loop: each query runs (a spinner) and ends (a check), one after the other, forever. |
| `variant` | `:string` | `"default"` | `default`, `bare` - `bare` leaves the summary header out: just the rows, without the first row's top border. |
| `summary` | `:boolean` | `true` | Shows the `<summary>` header (count and time). `false` is the same as `variant="bare"`: the box is then a `div` that is always open. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.ai_message>`

A message of the conversation.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `role` | `:string` | `"assistant"` | `user`, `assistant` |
| `variant` | `:string` | `"card"` | `card`, `plain` - `card` frames the assistant's content; `plain` is loose text beside the spark. |
| `streaming` | `:boolean` | `false` | Shows the blinking cursor after the last paragraph. |
| `thinking` | `:boolean` | `false` | Three bouncing dots in place of the content (the assistant has not started to write). |
| `status` | `:string` | `"ok"` | `ok`, `error` |
| `name` | `:string` | `nil` | The user's name: its initials make the avatar. |
| `actions` | `:list` | `[]` | Buttons under the content: `copy`, `useful`, `useless`, `regenerate`. |
| `on_action` | `:any` | `nil` | Event name (payload `%{action}`) or `JS` command. |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`
- `<:trace>` - The queries the assistant made, above the content.

## `<.ai_proposal>`

An action the assistant proposes, which only happens when the user approves.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `title` (required) | `:string` |  | What will be done. |
| `heading` | `:string` | `nil` | Title of the card header. |
| `status` | `:any` | `"pending"` | `pending`, `applying`, `approved`, `rejected` or `failed`, as an atom or a string. |
| `pending_label` | `:string` | `nil` |  |
| `pending_note` | `:string` | `nil` |  |
| `layout` | `:string` | `"list"` | `list`, `definition`, `table` |
| `headers` | `:list` | `nil` | Column headers of the `table` layout. |
| `editable` | `:boolean` | `false` |  |
| `note` | `:string` | `nil` |  |
| `on_approve` | `:any` | `nil` |  |
| `on_reject` | `:any` | `nil` |  |
| `on_undo` | `:any` | `nil` |  |
| `on_edit` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - A button in the footer of a failed proposal.
- `<:change>` - attrs: `label`, `from`, `to` - A row of the proposal.
- `<:impact>` - attrs: `label` - The effect in numbers.
- `<:preview>` - attrs: `label` - A preview of the message or document.

## `<.ai_composer>`

The field to ask the assistant: context chips, text, attachment and send (a form).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` | Needed for Enter-to-send (the hook needs a stable id). |
| `variant` | `:string` | `"default"` | `default`, `canvas` |
| `send_label` | `:string` | `nil` |  |
| `mic` | `:boolean` | `false` |  |
| `on_mic` | `:any` | `nil` |  |
| `mention` | `:boolean` | `false` | Shows the mention (@) button. |
| `on_mention` | `:any` | `nil` |  |
| `mention_label` | `:string` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:string` | `nil` |  |
| `context` | `:list` | `[]` |  |
| `attachments` | `:list` | `[]` |  |
| `upload` | `:any` | `nil` |  |
| `streaming` | `:boolean` | `false` | An answer is arriving: sets `data-lu-streaming` (the hook ignores Enter) and shows the stop button. |
| `on_stop` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `placeholder` | `:string` | `nil` |  |
| `loop` | `:string` | `nil` | The canvas loop: this text is typed in place of the field, again and again, and the send button pulses. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element, including `autocomplete`, `phx-submit`, `phx-change`, `phx-target`.

Slots:

- `<:chip>` - A custom chip, after the context ones.

## `<.prompt_suggestions>`

The starting suggestions: cards, pills or a grey grid.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `items` (required) | `:list` |  | Maps `%{title, text, icon, tone, delay}`; a pill shows the `text`. |
| `tilt` | `:boolean` | `true` | Tilts the cards (decorative). |
| `variant` | `:string` | `"card"` | `card`, `pill`, `grid` |
| `columns` | `:integer` | `2` | `1`, `2`, `3`, `4` - Columns of the `card` and `grid` variants. |
| `on_pick` | `:any` | `nil` | Event name (payload `%{value, title}`) or `JS` command. |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.conversation_list>`

The conversations of the assistant, by day, with a button for a new one and a search.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `conversations` (required) | `:list` |  | Maps `%{id, title, status, day, pending, content, href, navigate, patch, style}`. |
| `active` | `:any` | `nil` | The `id` of the open conversation. |
| `current` | `:any` | `nil` | The same as `active`. |
| `search` | `:string` | `""` |  |
| `group_by` | `:atom` | `:day` | `:day` |
| `variant` | `:string` | `"card"` | `card`, `rail` |
| `title` | `:string` | `nil` |  |
| `shortcut` | `:string` | `"⌘ J"` |  |
| `new_label` | `:string` | `nil` |  |
| `on_new` | `:any` | `nil` |  |
| `on_search` | `:any` | `nil` |  |
| `on_select` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:item>` - attrs: `conversation` - The content of an item, in place of the title and status.

## `<.ai_chat>`

The whole conversation: greeting and suggestions, the messages and the field to ask.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `messages` | `:any` | `[]` | A list of message maps or a stream of them. |
| `user` | `:any` | `nil` |  |
| `streaming` | `:boolean` | `false` |  |
| `context` | `:list` | `[]` |  |
| `mention` | `:boolean` | `false` |  |
| `mention_label` | `:string` | `nil` |  |
| `variant` | `:string` | `"card"` | `card`, `default`, `canvas`, `bare`, `page` - `card` (or `default`): a bordered panel; `canvas`: a flat sunken box; `bare`: no box; `page`: a raised rounded box. |
| `compact` | `:boolean` | `false` | 12px of padding in the scroll area (instead of 18px), for a small box. |
| `draft` | `:string` | `nil` |  |
| `greeting` | `:string` | `nil` |  |
| `start` | `:boolean` | `true` | Shows the greeting and suggestions (or `:empty`) while a list has no messages. |
| `footnote` | `:string` | `nil` |  |
| `composer` | `:boolean` | `true` |  |
| `placeholder` | `:string` | `nil` |  |
| `on_send` | `:any` | `nil` |  |
| `on_change` | `:any` | `nil` |  |
| `on_stop` | `:any` | `nil` |  |
| `on_approve` | `:any` | `nil` |  |
| `on_reject` | `:any` | `nil` |  |
| `on_undo` | `:any` | `nil` |  |
| `on_pick` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:empty>` - Shown above the messages in place of the greeting and suggestions.
- `<:header>` - The title and subtitle of the conversation, in the header of the `card`.
- `<:inner_block>` - Extra content after the messages.
- `<:suggestion>` - attrs: `title`, `prompt` - A starting card; the content is its text.
