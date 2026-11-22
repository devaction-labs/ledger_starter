# LedgerUI.Components.Radio

Single choice among visible options: `radio_group/1`, in six forms.

    <.radio_group field={@form[:plan]} options={[{"Free", "free"}, {"Pro", "pro"}]} color="primary" />

    <.radio_group name="basic" value="primary">
      <:radio value="default">Default</:radio>
      <:radio value="error" color="error" disabled>Error</:radio>
    </.radio_group>

    <.radio_group field={@form[:status]} variant="chip" options={[
      %{label: "Todos", value: "all", count: 128}, %{label: "Draft", value: "draft"}]} />

`variant` is `basic`/`outline` (the round radio of `checkbox/1`), `card` (with `control="end"`),
`chip` (`shape="pill"` for round ends), `segmented` (the look of
`LedgerUI.Components.Segmented`, a button per option over a real radio) and `tile` (a 52px
square with free content and an `aria_label`). Every variant keeps a real radio, so the form,
`field` errors, the arrow keys and `phx-change` work; the chosen look follows the radio
(`has-checked:` utilities, and the `LedgerUI.Segmented` hook for `segmented`).

`card` takes `<:trailing :let={opt}>`: content at the right, inside the card (a badge, a button), given
each option. The card then is a `div` (the radio, a `<label for>` stretched over the card and the trailing
box), so a button there never sits inside a `<label>`: it takes its own click and does not select
the radio, while a click on the card or on a non-interactive trailing selects it. A disabled option
makes the whole card, trailing included, inert.

    <.radio_group field={@form[:signer]} variant="card" options={@signers}>
      <:trailing :let={opt}>
        <.button :if={opt.value == "ana"} size="sm" variant="outline">Enviar certificado</.button>
      </:trailing>
    </.radio_group>

Options are `{label, value}` tuples, plain values, maps with `:label`, `:value`,
`:description`, `:count`, `:icon`, `:color`, `:disabled`, or `:radio` slots.

## `<.radio_group>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `options` | `:list` | `[]` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `variant` | `:string` | `"basic"` | `basic`, `outline`, `card`, `chip`, `segmented`, `tile` |
| `control` | `:string` | `"start"` | `start`, `end` |
| `filled` | `:boolean` | `false` |  |
| `shape` | `:string` | `"circle"` | `circle`, `squircle`, `pill` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg` |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `label_hint` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `radio_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`, `required`.

Slots:

- `<:radio>` - attrs: `value`, `label`, `color`, `disabled`, `aria_label`, `description`, `count`, `icon`, `class`, `style`, `checked`, `shape`, `filled`
- `<:trailing>` - `card` only: content at the right of each card; receives the option (`:let={opt}`).

## `<.radio_choice>`

Same as `radio_group/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `options` | `:list` | `[]` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `variant` | `:string` | `"basic"` | `basic`, `outline`, `card`, `chip`, `segmented`, `tile` |
| `control` | `:string` | `"start"` | `start`, `end` |
| `filled` | `:boolean` | `false` |  |
| `shape` | `:string` | `"circle"` | `circle`, `squircle`, `pill` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg` |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `label_hint` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `radio_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element, including `form`, `required`.

Slots:

- `<:radio>` - attrs: `value`, `label`, `color`, `disabled`, `aria_label`, `description`, `count`, `icon`, `class`, `style`, `checked`, `shape`, `filled`
- `<:trailing>` - `card` only: content at the right of each card; receives the option (`:let={opt}`).

## `<.radio>`

A radio, or a group of them: with `options` (or `<:radio>` slots) it is `radio_group/1`; without,
one radio with its `label`, `color` and `size`.

    <.radio name="plan" value="pro" label="Pro" checked />
    <.radio field={@form[:plan]} options={[{"Monthly", "m"}, {"Yearly", "y"}]} />

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `options` | `:list` | `[]` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `variant` | `:string` | `"basic"` | `basic`, `outline`, `card`, `chip`, `segmented`, `tile` |
| `control` | `:string` | `"start"` | `start`, `end` |
| `filled` | `:boolean` | `false` |  |
| `shape` | `:string` | `"circle"` | `circle`, `squircle`, `pill` |
| `size` | `:string` | `"md"` | `xs`, `sm`, `md`, `lg` |
| `label` | `:string` | `nil` |  |
| `label_class` | `:any` | `nil` |  |
| `label_hint` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `disabled` | `:boolean` | `false` |  |
| `wrapper_class` | `:any` | `nil` |  |
| `radio_class` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `checked` | `:boolean` | `false` | A lone radio (no `options`, no `<:radio>`): whether it is the chosen one. |

Any other HTML/phx attribute goes to the root element, including `form`, `required`.

Slots:

- `<:radio>` - attrs: `value`, `label`, `color`, `disabled`, `aria_label`, `description`, `count`, `icon`, `class`, `style`, `checked`, `shape`, `filled`
- `<:trailing>` - `card` only: content at the right of each card; receives the option (`:let={opt}`).
