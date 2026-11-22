# LedgerUI.Components.Aura

Ring of light that runs along the border of any element while something works in the background.
Styled only with Tailwind utilities; the light is a `::before` cone that turns (`lu-aura-spin`).

    <.aura tone="ai"><.toast_card title="Reading the invoice" /></.aura>
    <.aura tone="ai" radius="pill" width="sm"><button>Summarize</button></.aura>
    <.aura mode="glow" tone="warn" shadow>…needs you…</.aura>

`mode` is `spin` (a light turns while it works), `dual` (two colours, a result is ready) or
`glow` (pulses when it needs the person). `tone` picks the light (`ai` is the assistant's teal
and violet).

## `<.aura>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `mode` | `:string` | `"spin"` | `spin`, `dual`, `glow` |
| `motion` | `:string` | `nil` | `nil`, `spin`, `dual`, `glow` - Alias of `mode`. |
| `tone` | `:string` | `"accent"` | `accent`, `ai`, `info`, `pos`, `warn`, `neg`, `violet` |
| `width` | `:string` | `"default"` | `xs`, `sm`, `default`, `lg` |
| `radius` | `:string` | `"default"` | `default`, `pill`, `r12` |
| `shadow` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
