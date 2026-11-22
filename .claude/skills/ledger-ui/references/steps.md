# LedgerUI.Components.Steps

Steps: numbered or plain points joined by a line (`steps/1`) and the progress stepper of a
wizard (`stepper/1`). Both draw the canvas steps; `stepper variant="classic"` is the old bar of
numbered squares. Styled only with Tailwind utilities; the colour enters as `--c`, `--c-on` and
`--c-ink` (see `LedgerUI.Color`; `accent` is `primary`) and every part carries `data-part`
(`steps`, `step`, `step-marker`, `step-label`, `step-sub`, `step-line`).

    <.stepper current={2}>
      <:step label="Account" sub="Tax id and address" />
      <:step label="Plan" />
      <:step label="Payment" />
    </.stepper>

    <.steps color="primary" size="sm">
      <:step label="Cart" state="done">1</:step>
      <:step label="Shipping" state="current">2</:step>
    </.steps>

`current` is the 0-based index of the step being worked on: the ones before are `done`, the
ones after `todo`; with `error` the current one is flagged. A step's own `state` wins. The
marker of a step is, in order: its `marker` text, its `icon`, a check when `done` (numbers for
the `xs`/`sm` dots), `!` when `error`, else its number.

Notes:

  * `color` and `size` on `stepper/1` are additions to the README (the canvas previews vary them).
  * Accessibility is rendered server-side: the root is `role="list"`, each step `role="listitem"`;
    the current (or flagged) one has `aria-current="step"` and, on `stepper/1`, every step has
    an `aria-label` with its label and its state name (`state_names`, e.g. "Company, Completed").
    A `:step` takes `style` (animation delays) and any other attribute.
  * The kit CSS classes the README mentions (`steps`, `step-primary`) are replaced by utilities.

## `<.steps>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `accent`, `info`, `success`, `warning`, `error` |
| `orientation` | `:string` | `"horizontal"` | `horizontal`, `vertical` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg` |
| `line_space` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:step>` (required) - attrs: `label`, `color`, `ping`, `current`, `state`, `class`, `style`

## `<.stepper>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `orientation` | `:string` | `"horizontal"` | `horizontal`, `vertical` |
| `current` | `:integer` | `nil` |  |
| `error` | `:boolean` | `false` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `classic` |
| `state_names` | `:map` | `%{"current" => "Current", "done" => "Completed", "error" => "Needs attention", "todo" => "Upcoming"}` |  |
| `color` | `:string` | `nil` | `nil`, `neutral`, `primary`, `secondary`, `accent`, `info`, `success`, `warning`, `error` |
| `size` | `:string` | `nil` | `nil`, `xs`, `sm`, `md`, `lg` |
| `loop` | `:boolean` | `false` | The animated mock: the steps fill in turn (stagger them with `style="--dl:1.4s"`); the states are not drawn. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:step>` (required) - attrs: `label`, `sub`, `state`, `marker`, `icon`, `class`, `style`
