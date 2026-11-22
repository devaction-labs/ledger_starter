# LedgerUI.Components.Palette

Swatches of the kit palette: the accent scale, warm-neutral base, status signals and chart
series. Colours are read from the tokens (`var(--lu-ink)`, `bg-accent-500`), so the swatches
follow the theme (light, dark, any palette and any `--color-accent`).

    <.palette variant="ramp" />
    <.palette variant="chips" scale="gray" />
    <.palette
      cols={6}
      colors={[
        %{token: "--bg-page", name: "Página", light: "#ffffff", dark: "#0e100f"},
        %{token: "--ink", name: "Ink", light: "#141514", dark: "#f2f3f2"}
      ]}
    />

## Variants

  * `swatches` (default): a grid of cards, one per entry of `colors` with the colour, its name,
    the token and (when given) the `light` and `dark` hex values. `cols` is the number of
    columns. `token` is a kit token (`"--bg-page"` or `"--lu-bg-page"`, both read
    `var(--lu-bg-page)`).
  * `ramp`: the full `scale` (`accent` by default, or `gray`) as a strip of labelled steps
    (`steps`, `50..900` by default), the label turning white from step 400.
  * `chips`: the same scale as a row of small rounded chips, appearing one after the other.

Styled only with Tailwind utilities.

## `<.palette>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"swatches"` | `swatches`, `ramp`, `chips` |
| `colors` | `:list` | `[]` | `swatches`: maps with `:token` (`"--bg-page"`), `:name`, `:light`, `:dark`. |
| `cols` | `:integer` | `6` | `swatches`: number of columns. |
| `scale` | `:string` | `"accent"` | `accent`, `gray` - `ramp` and `chips`: the colour scale (the theme's `accent`, or `gray`). |
| `steps` | `:list` | `["50", "100", "200", "300", "400", "500", "600", "700", "800", "900"]` | `ramp` and `chips`: the steps of the scale. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
