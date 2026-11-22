# LedgerUI.Components.EmptyState

Empty state: what the area is, why it is empty and the one next step. Styled only with Tailwind
utilities.

    <.empty_state icon="inbox" title="No orders yet">
      Orders from the counter and the site show up here.
      <:action><.button size="sm">New order</.button></:action>
    </.empty_state>

    <.empty_state variant="inline" icon="inbox" title="No comments yet.">
      <a href="#">Write the first</a>
    </.empty_state>

Variants:

  * `canvas` (default) - icon tile with two dashed frames, title, reason, actions;
  * `card` - centered block for a whole area, icon with pulsing rings (`tone` default,
    `gradient` or `positive`) and an optional `kicker`;
  * `inline` - compact dashed notice for lists and results (`color` neutral/success/error);
  * `table` - centered notice for the body of an empty table (a disc tinted by `color`);
  * `plain` - the faint one-line notice inside a card.

`color` also tints the `plain` line (a green "all caught up"). `loop` plays the canvas loop (`mo-stg`,
CSS only): the notice fades in, stays and leaves, forever. `inline_empty/1` (the one-line notice of
a panel or a table cell) takes `loop` too.

`level` (2, 3 or 4) marks the title of a `card` as a heading (`aria-level`); without it the
title is a plain bold line.

## `<.empty_state>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"canvas"` | `canvas`, `card`, `inline`, `table`, `plain` |
| `title` (required) | `:string` |  |  |
| `kicker` | `:string` | `nil` |  |
| `icon` | `:string` | `nil` |  |
| `tone` | `:string` | `"default"` | `default`, `gradient`, `positive` |
| `color` | `:string` | `"neutral"` | `neutral`, `success`, `error` |
| `level` | `:integer` | `nil` | `nil`, `2`, `3`, `4` |
| `loop` | `:boolean` | `false` | The canvas loop (`mo-stg`): it fades in, stays, leaves, forever. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - The next step.
- `<:illustration>` - Replaces the icon.
- `<:inner_block>` - The reason it is empty.

## `<.empty_state_card>`

Same as `empty_state/1` (same attributes and slots), under the name the design vitrine uses.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"canvas"` | `canvas`, `card`, `inline`, `table`, `plain` |
| `title` (required) | `:string` |  |  |
| `kicker` | `:string` | `nil` |  |
| `icon` | `:string` | `nil` |  |
| `tone` | `:string` | `"default"` | `default`, `gradient`, `positive` |
| `color` | `:string` | `"neutral"` | `neutral`, `success`, `error` |
| `level` | `:integer` | `nil` | `nil`, `2`, `3`, `4` |
| `loop` | `:boolean` | `false` | The canvas loop (`mo-stg`): it fades in, stays, leaves, forever. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - The next step.
- `<:illustration>` - Replaces the icon.
- `<:inner_block>` - The reason it is empty.

## `<.inline_empty>`

The one-line empty state inside a panel or a table cell: an icon and a sentence, in a dashed box
with no background (13/18px text, 8px gap).

    <.inline_empty icon="inbox" text="No comments yet" />

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `text` (required) | `:string` |  |  |
| `icon` | `:string` | `nil` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `success`, `error` |
| `loop` | `:boolean` | `false` | The canvas loop (`mo-stg`): it fades in, stays, leaves, forever. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:action>` - The next step.
