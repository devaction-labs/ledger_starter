# LedgerUI.Components.Stat

Short figures side by side: the label over the number, a divider between them, inside a card, a
sunken strip or a bare row.

    <.stat_group>
      <.stat_item label="Subtotal" value="R$ 3.240" />
      <.stat_item label="Desconto" value="− R$ 120" />
      <.stat_item label="Total" value="R$ 3.120" tone="accent" />
    </.stat_group>

    <.stat_group animated>
      <.stat_item
        icon="huge-wallet"
        label="Faturamento"
        value="R$ 184.320"
        change="12,4%"
        note="vs. outubro"
        sparkline={[0, 3.5, 2.3, 6.1, 5.2, 8.7, 11, 9.8, 13.3, 15.1, 17.7, 22]}
      />
    </.stat_group>

The vitrine names work as aliases: `delta` (`change`), `hint` (`note`), `goal` (`meter`), `spark`
(`sparkline`) and `delta_tone` (`change_tone`, with `good`/`bad`).

`stat_item/1` carries everything a figure can say: a `unit` (`dias`, `un`), a `change` with its
direction (`trend`) and tone (good or bad news), a `note` under the figure, a goal `meter` and a
`sparkline` (a list of numbers). `tone="accent"` highlights the total of a strip and `size="sm"`
sets a word (`Boleto`) instead of a number. `stat_group` draws the strip: `card` (the default) frames it,
`card={false}` leaves a bare row, `variant="sunken"` fills it with the sunken background, and
`animated` adds the canvas loop: the figures rise, the lines draw and the changes pop in. Styled
only with Tailwind utilities; the group exposes `data-variant`, `data-card` and `data-animated`,
which the items read with `group-data-[...]/stats:` variants.

`badge` puts a small caps badge beside the label (`badge_tone` is a `LedgerUI.Color` name, `primary`
by default; `badge_dot` adds a dot, `"live"` pulses it: `<.stat_item badge="Ao vivo" badge_dot="live" .../>`).
For free content use `<:label_badge>`, which replaces the text. `prefix` is a small raised mark before the
figure (`R$`). Without them the markup does not change.

`value_id` sets the `id` of the figure element (to update or test it). The default slot is free
content after the figure and its charts; `<:footer>` is a last line (a link, a caption).

## `<.stat_item>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` (required) | `:string` |  |  |
| `value` (required) | `:string` |  | The figure, already formatted. |
| `unit` | `:string` | `nil` | A smaller faint suffix beside the figure. |
| `icon` | `:string` | `nil` | An icon name before the label. |
| `tone` | `:string` | `"default"` | `default`, `accent` |
| `size` | `:string` | `"md"` | `default`, `md`, `sm` - `sm` sets a word instead of a number. |
| `delta` | `:string` | `nil` | The variation, already formatted (`12,4%`). |
| `change` | `:string` | `nil` | Alias of `delta`. |
| `trend` | `:string` | `"up"` | `up`, `down`, `flat` - The arrow of `delta`. |
| `delta_tone` | `:string` | `nil` | `nil`, `good`, `bad`, `pos`, `neg`, `flat` - Good (`good`/`pos`) or bad (`bad`/`neg`) news; by default good, or flat when `trend` is flat. |
| `change_tone` | `:string` | `nil` | `nil`, `pos`, `neg`, `flat` - Alias of `delta_tone`. |
| `hint` | `:string` | `nil` | The faint line under the figure (`vs. outubro`). |
| `note` | `:string` | `nil` | Alias of `hint`. |
| `goal` | `:integer` | `nil` | Goal progress, 0..100: draws the bar. |
| `meter` | `:integer` | `nil` | Alias of `goal`. |
| `goal_label` | `:string` | `nil` | The line under the goal bar. |
| `spark` | `:list` | `nil` | Numbers of a trend (at least two); the last one is the dot. |
| `sparkline` | `:list` | `nil` | Alias of `spark`. |
| `spark_tone` | `:string` | `"accent"` | `accent`, `acc`, `pos`, `muted`, `mut` |
| `sparkline_tone` | `:string` | `nil` | `nil`, `accent`, `acc`, `pos`, `muted`, `mut` - Alias of `spark_tone`. |
| `badge` | `:string` | `nil` | A badge beside the label (`Ao vivo`). |
| `badge_tone` | `:string` | `"primary"` | `current`, `dark`, `error`, `info`, `light`, `lime`, `mono`, `neutral`, `primary`, `secondary`, `success`, `warning`, `white` - The colour of the badge. |
| `badge_dot` | `:any` | `false` | A dot in the badge; `"live"` makes it pulse. |
| `prefix` | `:string` | `nil` | A small raised mark before the figure (`R$`). |
| `value_id` | `:string` | `nil` | The `id` of the figure element. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:footer>` - A last line of the item (a link, a caption), after everything else.
- `<:inner_block>` - Free content under the figure, its changes and its charts.
- `<:label_badge>` - Free content for the badge beside the label (instead of `badge`).

## `<.stat_group>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `card` | `:boolean` | `true` | Frames the strip; `false` leaves a bare row. |
| `variant` | `:string` | `"default"` | `default`, `sunken` |
| `animated` | `:boolean` | `false` | The canvas loop: figures rise, lines draw, changes pop in. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
