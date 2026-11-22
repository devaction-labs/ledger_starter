# LedgerUI.Components.StepGroup

A framed card for processes in steps (a build, a deploy, issuing an invoice, an import).

    <.step_group id="deploy" title="Deploy logs" status={:running} duration="1m 04s">
      <:step title="Preparing environment" status={:ok} result="12s" />
      <:step title="Updating the stack" status={:running} result="Running…" open>
        <.step_group_line n={1} at="09:41:02" tone="dim">Connecting</.step_group_line>
        <.step_group_line n={2} at="09:41:04" tone="err">Rejected</.step_group_line>
      </:step>
      <:step title="Routing traffic" status={:waiting} result="Waiting" />
    </.step_group>

`status` is one of `:ok`, `:running`, `:waiting`, `:failed`, `:skipped` and `:canceled`.

The content of a `:step` is its log (`step_group_line/1` lines). A step with a log is a
`<button>` that opens and closes the log; a step without one is a plain row. Without a
`title` the card is just the list of steps (no header, nothing to collapse).

Collapsing the card and opening a log happen in the browser (`Phoenix.LiveView.JS`), with no
round trip; `collapsed` and `open` set where the state starts. `loop` plays the canvas loop
(`mo-stg`): the rows fade in one after the other (each row's own `--dl` delay, e.g.
`style="--dl:0.7s"`), forever. Styled only with Tailwind utilities.

## `<.step_group>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` | Required with a `title` (the collapse button needs it). |
| `title` | `:string` | `nil` |  |
| `status` | `:atom` | `:waiting` | `:ok`, `:running`, `:waiting`, `:failed`, `:skipped`, `:canceled` |
| `duration` | `:string` | `nil` |  |
| `collapsed` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | The canvas loop (`mo-stg`): the rows fade in one by one. |
| `steps` | `:list` | `[]` | The steps as data, instead of `<:step>` slots: maps with `:title` and optionally `:status`, `:result`, `:id`. (No log: use the slots for that.) |
| `current` | `:integer` | `nil` | With `steps`: the position (from 1) of the step in progress; the ones before it are `:ok`, the ones after `:waiting` (unless a step has its own `:status`). |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:step>` - attrs: `title`, `status`, `result`, `open`, `id`, `class`, `style` - One step; its content is its log.

## `<.step_group_line>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `n` (required) | `:integer` |  | The line number. |
| `at` | `:string` | `nil` | The time of the line. |
| `tone` | `:string` | `nil` | `nil`, `dim`, `err`, `ok` |

Slots:

- `<:inner_block>` (required)
