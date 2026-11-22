# LedgerUI.Components.Chart

Charts drawn by the package itself, as SVG (axis labels, grid lines, legend, tooltips, light and
dark). Styled only with Tailwind utilities: series take their colour from the chart tokens
(`--lu-chart-1` ... `--lu-chart-5`, derived from the accent) or from the `color` you give, so a theme
recolours them. Old names such as `var(--chart-3)` and `var(--accent)` are read as the `--lu-` tokens.

The look-alike canvas charts are rendered **on the server**, so they show without JavaScript; a small
hook only adds the hover guide and tooltip:

  * `line_chart/1` (hook `LedgerUI.LineChart`): lines and areas, with head, legend and tooltip.
    The server draws the SVG at `width`; the hook then measures the container (`ResizeObserver`)
    and lays the same geometry out at the real width, so axis text and strokes stay at their CSS
    size on any screen. The lines draw in once on mount (no loop; not with
    `prefers-reduced-motion`).
  * `donut_chart/1` (hook `LedgerUI.DonutChart`): the ring and its plan rows.
  * `waterfall_chart/1`: floating steps and totals.
  * `bar_chart/1`: the column strip (`lu-bars`).
  * `cohort_heatmap/1`: the retention grid.
  * `bar_list/1` and `heatmap/1`: a ranking over tracks and a grid of dots.

`chart/1` is the generic, options-driven chart (an ApexCharts-shaped subset: `line`, `area`,
`bar`, `donut`/`pie`) drawn by the `LedgerUI.Chart` hook into an element LiveView leaves alone.

Cards, headers and segmented controls around a chart are separate components; these functions
render only the chart (and, for `line_chart/1`, its head and legend).

## `<.line_chart>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `labels` | `:list` | `[]` | X axis labels, one per point. |
| `series` | `:list` | `[]` | `[%{name: .., values: [..], area: bool, dashed: bool, color: css}]`. A `nil` in `values` is a point without data: the line breaks there (no 0 is drawn), the area does not fill it and the default tooltip shows an em dash. Without series only the empty container is rendered. |
| `min` | `:any` | `nil` | Lowest value of the axis (default: lowest of the data). |
| `max` | `:any` | `nil` |  |
| `ticks` | `:integer` | `4` | Gaps of the Y axis (`ticks + 1` grid lines). |
| `label_every` | `:integer` | `1` | Draw one X label every N points. |
| `width` | `:integer` | `640` | Width of the server-rendered SVG (first paint). In the browser the hook re-lays the chart to the measured width of its container, so text and strokes keep their CSS size. |
| `height` | `:integer` | `250` | Height of the chart in CSS pixels (the same on the server and after the hook measured). |
| `label` | `:string` | `nil` | `aria-label` of the SVG. |
| `head` | `:string` | `nil` | Big figure above the chart (`+$70,320`). |
| `sub` | `:string` | `nil` | Muted text after the figure (`since January`). |
| `legend` | `:boolean` | `true` | Legend of the named series (when there is more than one). |
| `sub_delta` | `:string` | `nil` | A change after the muted text (`+12,4%`), in bold and colored by `sub_delta_tone`. |
| `sub_delta_tone` | `:string` | `"pos"` | `pos`, `neg` |
| `pin` | `:integer` | `nil` | Index whose guide and tooltip stay visible. |
| `axis_format` | `:any` | `&LedgerUI.Components.Chart.kilo/1` | Function of a value for the Y labels. |
| `value_format` | `:any` | `&LedgerUI.Components.Chart.money/1` | Function of a value for the tooltip. |
| `tip` | `:any` | `nil` | Function of an index returning tooltip rows `[[name, value, kind]]`. |
| `tip_title` | `:any` | `nil` | Function of an index returning the tooltip title. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.donut_chart>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `segments` | `:list` | `[]` | `[%{name: .., value: number, color: css, display: "$96,900"}]`. Empty: only the container. |
| `center_label` | `:string` | `nil` |  |
| `center_value` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `rows` | `:boolean` | `true` | Draw the plan rows (name, value and share) under the ring. |
| `loop` | `:boolean` | `false` | The canvas loop: the ring fades in and spins in again every 7s (`mo-donut`, `mo-dspin`). |
| `value_format` | `:any` | `&LedgerUI.Components.Chart.money/1` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.waterfall_chart>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` |  |
| `steps` | `:list` | `[]` | `[%{name:, value:, label:, color:, total: bool}]`: a step moves the running total, `total` starts from zero. |
| `max` | `:integer` | `30000` | Top of the Y axis. |
| `ticks` | `:integer` | `3` | Gaps of the Y axis. |
| `label` | `:string` | `nil` | `aria-label` of the SVG. |
| `axis_format` | `:any` | `&LedgerUI.Components.Chart.wf_axis/1` |  |
| `loop` | `:boolean` | `false` | The canvas demo: the bars grow again and again (`mo-bar`) instead of once. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.bar_chart>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `values` | `:list` | `[]` | One number per bar. |
| `data` | `:list` | `[]` | The bars as `{label, value}` tuples or `%{label:, value:}` maps, in place of `values` and `labels`. |
| `max` | `:any` | `nil` | The value of a full-height bar (the highest value, or 100 when it is lower, by default). |
| `labels` | `:list` | `[]` | Labels in a row under the bars. |
| `titles` | `:list` | `[]` | `title` (hover text) of each bar. |
| `highlight` | `:any` | `:last` | Index of the highlighted bar, or its label (`:last`, `nil` for none). |
| `shape` | `:string` | `"round"` | `round`, `square` |
| `loop` | `:boolean` | `false` | The canvas loop: the bars grow from the baseline in turn (`mo-bar`, 6s, 80ms apart). |
| `y_axis` | `:boolean` | `false` | Draws value labels to the left, at the bar heights, on "nice" ticks computed from the highest value (or `max`). The top tick is then the full height of the strip. |
| `y_ticks` | `:list` | `nil` | Explicit tick values (`[0, 1, 2]`); implies `y_axis`. The highest tick is the full height of the strip. |
| `y_format` | `:any` | `nil` | Label format of the ticks: a 1-arity function (`&Chart.format_k/1`) or the name of a kit formatter (`"thousands_br"`, `"k"`, `"brl_thousands"`, `"brl_full"`), computed on the server. Default: the number, with a decimal comma. |
| `y_grid` | `:boolean` | `false` | Horizontal grid lines at the ticks (needs `y_axis` or `y_ticks`). |
| `height` | `:any` | `nil` | CSS height of the strip (`120px`). |
| `width` | `:any` | `nil` | CSS width of the strip. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.cohort_heatmap>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `columns` (required) | `:list` |  | Header labels (`M0`, `M1`...). |
| `rows` (required) | `:list` |  | `[%{label: "Jan", values: [100, 94, nil, ...]}]`; `nil` is an empty cell. |
| `thresholds` | `:list` | `~c"VZ^d"` | Lower bounds of levels 2 to 5. |
| `suffix` | `:string` | `"%"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.bar_list>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `label` | `:string` | `nil` | The list's `aria-label`. |
| `max` | `:any` | `nil` | The amount of a full track (the largest `amount` by default). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:item>` (required) - attrs: `label`, `value`, `amount`

## `<.heatmap>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `levels` (required) | `:list` |  | One level per cell, 0 to 4, row by row. |
| `columns` | `:integer` | `20` |  |
| `size` | `:integer` | `12` | The cell size in pixels. |
| `shape` | `:string` | `"round"` | `round`, `square` |
| `label` (required) | `:string` |  | What the map shows, for assistive technology. |
| `titles` | `:list` | `nil` | A `title` per cell. |
| `less` | `:string` | `nil` | Text before the scale; no scale without it. |
| `more` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.chart>`

The generic, options-driven chart: ApexCharts-shaped options drawn as SVG by the `LedgerUI.Chart`
hook (supported subset only; everything else is ignored).

## Stacked bars

`chart: %{type: "bar", stacked: true}` with several series piles the series up, in order, from the
baseline (bottom to top for columns, left to right with `plotOptions: %{bar: %{horizontal: true}}`).
Each segment is its own `rect` with `data-part="chart-stack-segment"` (`data-series`, `data-index`).
Positive values pile up from 0, negative ones down from 0; the axis spans the stack totals (its top is raised to a round step) unless
`yaxis.min`/`max` are given. `plotOptions.bar.borderRadius` rounds only the outermost segment
(default: square).

    <.chart id="seg" options={%{
      chart: %{type: "bar", stacked: true, height: 280},
      series: [%{name: "Loja", data: [12, 18]}, %{name: "Online", data: [7, 9]}],
      xaxis: %{categories: ["Jan", "Fev"]}
    }} />

## Range band on the X axis

`annotations: %{xaxis: [%{x: "Mar", x2: "Mai", tone: "neg", label: %{text: "Ruptura"}}]}` draws a
translucent rectangle (`data-part="chart-band"`, opacity `.15`, `opacity` overrides it) behind the
series. `x`/`x2` are a category (text) or an index (number, fractions allowed); without `x2` the
band covers that one category. On bar charts the band covers whole slots; on line charts it runs
from point to point. `tone` is `neg`, `warn`, `pos` or `info` (default) and uses the theme
tokens; `fillColor` is accepted only as a theme variable (`"var(--lu-chart-3)"`), a loose hex is
ignored. `label.text` is written at the top of the band.

## Markers, curve and dashes (line and area)

  * `markers: %{size: 4}` draws a circle on every point (`data-part="chart-marker"`); a list
    (`size: [0, 4]`) sets it per series, `0` meaning none.
  * `stroke: %{curve: "straight"}`: `"straight"` or `"smooth"` (the default, as before), one value
    for all series or a list per series (`["straight", "smooth"]`).
  * `stroke: %{dashArray: [0, 6]}` becomes `stroke-dasharray`: a number for all series or a list
    per series; `0` is solid.

## Shared tooltip

With a `tooltip` map in the options (and not `enabled: false`), hovering or focusing a category
shows a vertical guide (a horizontal one for horizontal bars) and a box with the value of each
series at that category, formatted by `tooltip.y.formatter` (a name from the built-in formatters,
given through `formatters: %{"tooltip.y.formatter" => "brl_thousands"}`). A `nil` value shows
"—". `tooltip: %{total: true}` adds a total row (`totalLabel` renames it; handy when stacked).
Without a `tooltip` option nothing is drawn, so existing charts are unchanged.

Accessibility: the SVG becomes focusable (`tabindex="0"`); once focused, the arrow keys move
between categories, `Home`/`End` jump to the first/last one and `Escape` hides the tooltip. The
box is a polite live region (`role="status"`), and the SVG carries a `<desc>` with every value, so
the data is available to assistive technology without hovering. (`line_chart/1`, which is
server-rendered, has hover only.)

## Few X labels and missing points

`xaxis: %{tickAmount: 5}` writes about 5 category labels (first and last always, the others spread
evenly) instead of all of them; the grid and the data are unchanged. A `nil` in a series' `data`
is a point without data: the line breaks there (nothing is drawn at 0), an area does not fill it,
markers skip it, bars skip it, and the tooltip shows "—" for that series.

## Formatters

Formatters are named, since the options travel as JSON; give them with `formatters`
(`%{"yaxis.labels.formatter" => "k", "tooltip.y.formatter" => "brl_full"}`). Available:

| name | 12000 | 1500 | 1234.56 |
|---|---|---|---|
| `thousands_br` | `12 mil` | `1,5 mil` | `1,2 mil` |
| `k` | `12k` | `1,5k` | `1,2k` |
| `brl_thousands` | `R$ 12 mil` | `R$ 1,5 mil` | `R$ 1,2 mil` |
| `brl_full` | `R$ 12.000,00` | `R$ 1.500,00` | `R$ 1.234,56` |

plus the older `thousands` (`12k`, no rounding), `thousands_round`, `dollars`, `number_br`
(`12.000`), `brl` (`R$ 1234,5`: only swaps the decimal point; use `brl_full` for money),
`percent`, `percent_round`, `round`, `hours`, `minutes` and `none`. For the server-rendered
`line_chart/1` the same four exist as functions (`format_thousands_br/1`, `format_k/1`,
`format_brl_thousands/1`, `format_brl_full/1`) to pass as `axis_format` / `value_format`.

## Options reference

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  | DOM id; also what `push_event` payloads target. |
| `options` (required) | `:any` |  | ApexCharts-shaped options, a map (encoded to JSON) or an encoded JSON string. |
| `formatters` | `:map` | `%{}` | Options path to built-in formatter name, e.g. `%{"yaxis.labels.formatter" => "thousands"}`. |
| `table_toggle` | `:any` | `false` | Reserved: a Chart / Table switch (not drawn yet). |
| `summary` | `:boolean` | `false` | Reserved: the cursor summary line (not drawn yet). |
| `on_cursor` | `:string` | `nil` | LiveView event pushed as the cursor moves. |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.
