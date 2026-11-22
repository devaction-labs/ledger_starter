# LedgerUI.Components.HeroCard

The hero card: the welcome or the insight at the top of a page. The text on the left (an
eyebrow in mono caps with an optional icon, the title, the description, a goal meter or a
list of steps, and the actions) and a landscape on the right that fades into the card.

    <.hero_card eyebrow="Bem-vindo de volta" title="Metas do trimestre" description="Alinhe a equipe.">
      <:actions>
        <.button color="mono" size="lg"><.icon name="plus" />Novo pedido</.button>
      </:actions>
    </.hero_card>

    <.hero_card
      eyebrow="Bom dia, Alex"
      title="Novembro está 12% acima de outubro"
      meta="Meta de novembro"
      meta_value="R$ 184 mil de R$ 250 mil"
      meter={74}
      animated
    />

    <.hero_card
      eyebrow="Configuração"
      title="Falta pouco para emitir sua primeira NF-e"
      picture="none"
      steps={[
        %{label: "Empresa", state: "done"},
        %{label: "Série e numeração", state: "current"},
        %{label: "Teste"}
      ]}
    />

The picture on the right is the summit landscape (`picture="summit"`, drawn with the `--lu-hero-*`
tokens, so it follows the theme), an `<img>` (`src`), the `:art` slot (your own SVG) or nothing
(`picture="none"`). `size="lg"` makes the card taller; `variant="panel"` puts it on the panel color
instead of the soft gray and `variant="ai"` is the soft card with the violet eyebrow (suggestions
from the assistant). `animated` adds the canvas loop: the text rises, the landscape breathes and
the meter fills (`lu-hero-*` keyframes). Styled only with Tailwind utilities.

`hero_summit/1` is the landscape on its own, for other surfaces. Give each one on the page its
own `id` (the gradient ids derive from it).

## `<.hero_card>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `eyebrow` | `:string` | `nil` | The small mono caps line above the title. |
| `title` (required) | `:string` |  |  |
| `description` | `:string` | `nil` |  |
| `src` | `:string` | `nil` | The picture on the right (replaces the landscape). |
| `alt` | `:string` | `""` |  |
| `position` | `:string` | `"center"` | The crop of the picture (`object-position`). |
| `picture` | `:string` | `"summit"` | `summit`, `none` - The picture when there is no `src` nor `:art` slot. |
| `size` | `:string` | `"md"` | `md`, `lg` |
| `variant` | `:string` | `"soft"` | `soft`, `panel`, `ai` |
| `heading` | `:string` | `"h2"` | `h1`, `h2`, `h3` |
| `meta` | `:string` | `nil` | The label of the goal line (needs `meta_value`). |
| `meta_value` | `:string` | `nil` | The figures of the goal line, already formatted. |
| `meter` | `:integer` | `nil` | Goal progress, 0 to 100: draws the bar under `meta`. |
| `steps` | `:list` | `[]` | Chips of a checklist: `%{label: "Empresa", state: "done" \| "current" \| "todo"}`. |
| `animated` | `:boolean` | `false` | The canvas loop (`mo-hero`). |
| `id` | `:string` | `nil` | Names the card (`aria-labelledby`) and prefixes the art. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:actions>`
- `<:art>` - The picture as markup (an SVG), instead of `src`.
- `<:icon>` - An icon before the eyebrow.
- `<:inner_block>` - Under the description: a note, a form, anything of your own.

## `<.hero_summit>`

The landscape of `hero_card/1`: a thin delegate to `LedgerUI.Components.Illustration.summit/1`
(`svg.lu-summit` painted with the `--hero-*` tokens). Decorative: `aria-hidden`.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"hs"` | Prefix of the gradient ids (`hs-sky`...): one per summit on a page. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.
