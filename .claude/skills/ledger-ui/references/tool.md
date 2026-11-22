# LedgerUI.Components.Tool

A tool call an agent makes (running a command, reading a file), from input to output, as a line
of a `LedgerUI.Components.Trace.trace/1`: a plain line while it runs, a step that opens on its
output once it has one, red when it fails. A call that waits for the user is a
`tool_approval/1` card with Deny and Approve.

    <.trace>
      <.tool id="t1" state="running" subject="pnpm install" />
      <.tool id="t2" state="done" subject="node --version" output="v24.18.0" />
      <.tool id="t3" state="error" subject="pnpm lint" output={@stderr} />
    </.trace>

## States

| `state`   | line                | title (en / pt_BR)                  |
|-----------|---------------------|-------------------------------------|
| `running` | `running` (spinner) | Running ... / Rodando ...           |
| `waiting` | `pending` (faded)   | Waiting to run ... / Aguardando ... |
| `done`    | plain               | Ran ... / Rodou ...                 |
| `error`   | `error` (red)       | Failed to run ... / Falhou ao rodar ... |
| `denied`  | plain               | Denied ... / Negado ...             |

`verbs` overrides them per state (`verbs={%{done: "Read", running: "Reading"}}`) and `title`
replaces the whole title. `subject` is drawn as code.

`variant="panel"` draws the call as a panel (tool icon, title, state badge or spinner) instead
of a line of a trace; `input` / `output` are only shown by the `line` variant.

## `<.tool>`

One tool call, as a line of a `trace/1` (or a panel).

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  | Names the output block. |
| `state` | `:string` | `"done"` | `running`, `waiting`, `done`, `error`, `denied` |
| `subject` | `:string` | `nil` | What the tool acted on, drawn as code. |
| `title` | `:string` | `nil` | The whole title, in place of verb and subject. |
| `verbs` | `:map` | `%{}` | Verbs per state (atom keys), over the `locale` ones. |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `icon` | `:string` | `"terminal"` |  |
| `description` | `:any` | `nil` |  |
| `input` | `:string` | `nil` |  |
| `output` | `:string` | `nil` |  |
| `open` | `:boolean` | `false` |  |
| `variant` | `:string` | `"line"` | `line`, `panel` |
| `indicator` | `:string` | `"badge"` | `badge`, `ring` - `panel` only: the state badge, or a spinner while `running`. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.tool_approval>`

A tool call that waits for the user: the question, the input and Deny / Approve.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `subject` | `:string` | `nil` | What would run, drawn as code in the question. |
| `title` | `:string` | `nil` | The question, in place of "Run `subject`?". |
| `description` | `:string` | `nil` |  |
| `input` | `:string` | `nil` |  |
| `icon` | `:string` | `"terminal"` |  |
| `value` | `:any` | `nil` | Sent with both events. |
| `on_approve` | `:any` | `nil` |  |
| `on_deny` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `approve_label` | `:string` | `nil` |  |
| `deny_label` | `:string` | `nil` |  |
| `locale` | `:string` | `"en"` | `en`, `pt_BR` |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
