# LedgerUI.Components.Illustration

Light illustrations for empty states and result screens, drawn with the theme tokens (or
inline SVG), so the package needs no static images. The sketch and the girl with the box are
styled only with Tailwind utilities.

    <.illustration name="empty" />
    <.illustration name="success" />
    <.empty_box class="h-28" />
    <.summit class="h-48 w-full" />
    <.scene name="voyage" />

  * `illustration/1`: a small card sketch with a round icon badge, in five states:
    `empty`, `success`, `error`, `search` and `offline`. `empty-inbox` is accepted for
    `empty`. `tone` and `icon` override the preset.
  * `empty_box/1`: a girl with a box, for an empty area.
  * `summit/1`: the landscape of `hero_card` and `auth_art` (`svg[data-part=summit]`), cropped to fill its box.
  * `scene/1`: portrait scenes (`voyage`, `lighthouse`, `balloons`, `aurora`) for the picture
    half of `auth_split`.

An illustration always comes with a title and a sentence; never alone.

## `<.illustration>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` | `:string` | `"empty"` | `empty`, `empty-inbox`, `error`, `offline`, `search`, `success` |
| `tone` | `:string` | `nil` | `nil`, `primary`, `neutral`, `success`, `error`, `info`, `warning` - Overrides the preset's colour. |
| `color` | `:string` | `nil` | `nil`, `primary`, `neutral`, `success`, `error`, `info`, `warning` - The same as `tone`; `tone` wins when both are given. |
| `icon` | `:string` | `nil` | Overrides the preset's icon. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.empty_box>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `"h-36"` | Sets the size; the width follows the height. |
| `label` | `:string` | `nil` | The accessible name; default: the locale's "Empty". |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

## `<.summit>`

The summit landscape of the design: sky, sun, stars, three ridges and a dotted trail, painted with
the `--lu-hero-*` tokens (light, dark and `crepusculo`, defined by the theme: no host class needed).
It fills its box, cropping the sides (give it a size: `class="size-full"`). The groups keep the
short names `sun`, `sun-c`, `st`, `m1`..`m3` and `ln` as hooks for animations. Decorative: `aria-hidden`. This is the only drawing of it: `hero_summit/1` and `auth_art/1` render it.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `"hs"` | Prefix of the SVG's gradient ids (`hs-sky`...); give each summit on a page its own. |
| `tone` | `:string` | `"teal"` | Kept for compatibility; the palette follows the theme (`--lu-hero-*`). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

## `<.scene>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` (required) | `:string` |  | `voyage`, `lighthouse`, `balloons`, `aurora` |
| `position` | `:string` | `"xMidYMid"` | Where the crop holds (`preserveAspectRatio`): `xMidYMax` keeps the bottom, `xMinYMid` the left. |
| `label` | `:string` | `""` | Read by screen readers; leave empty for decoration. |
| `class` | `:any` | `"h-full w-full"` |  |

Any other HTML/phx attribute goes to the root element.
