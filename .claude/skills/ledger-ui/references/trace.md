# LedgerUI.Components.Trace

What an agent did, one line per step: an icon, a title that truncates, an optional description
(a count, a duration, a diff) and a status. A step can open to show its output, link somewhere,
or group the steps under it.

    <.trace>
      <.trace_line icon="brain" title="Thought for 5s" />
      <.trace_line icon="terminal" description="0.4s">Ran <code>pnpm --version</code></.trace_line>
      <.trace_step icon="terminal" title="Ran node --version" open>
        <pre>v24.18.0</pre>
      </.trace_step>
      <.trace_line icon="terminal" status="error">Failed to run <code>pnpm install</code></.trace_line>
    </.trace>

`trace_line/1` also draws a timing waterfall: pass `bar` (`%{start: 18, width: 30, color:
"var(--lu-accent-400)", delay: "0.6s"}`, percentages of the total), `duration` (at the end) and
`depth` (indent) to show spans.

`trace_step/1` is a native `<details>`: the line is its summary and the block shows under it.

## `<.trace>`

The list of steps.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `spans` | `:list` | `[]` | Lines as data, before the inner block: maps with `:title` (or `:name`) and optionally `:icon`, `:description`, `:status`, `:duration`, `:depth` and the bar (`:start`, `:width`, `:color`, `:delay`, percentages of the total). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>`

## `<.trace_line>`

One step: icon, title, description and status; a link with `href`, `navigate` or `patch`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `icon` | `:string` | `nil` | A `huge-*` icon name. |
| `title` | `:string` | `nil` | The title; or pass it as the block. |
| `description` | `:any` | `nil` | Secondary text after the title: a count, a duration, a diff. |
| `status` | `:string` | `nil` | `nil`, ``, `running`, `error`, `pending` |
| `end_icon` | `:string` | `nil` |  |
| `href` | `:string` | `nil` |  |
| `navigate` | `:string` | `nil` |  |
| `patch` | `:string` | `nil` |  |
| `depth` | `:integer` | `0` | Indent level (18px each). |
| `bar` | `:map` | `nil` | `%{start, width, color, delay}`: a span bar (percentages). |
| `duration` | `:string` | `nil` | Text at the end of the row (a time). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `target`, `rel`, `download`.

Slots:

- `<:inner_block>`

## `<.trace_step>`

A step that opens: the line is the summary and the block shows under it.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `icon` | `:string` | `nil` |  |
| `title` | `:string` | `nil` |  |
| `description` | `:any` | `nil` |  |
| `status` | `:string` | `nil` | `nil`, ``, `running`, `error`, `pending` |
| `open` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
- `<:summary>` - The title with markup, in place of `title`.
