# LedgerUI.Components.Avatar

Avatars: an image or initials in a circle, a square, a squircle or any mask shape, with a
status dot, a gradient ring, and stacked in groups.

    <.avatar name="Ana Souza" color="auto" size="md" status="online" />
    <.avatar initials="jd" color="info" variant="soft" />
    <.avatar src="/images/jane.jpg" alt="Jane" gradient="sky-blue" size="lg" />
    <.avatar kind="assistant" size="md" />

    <.avatar_group more={3} size="sm">
      <.avatar :for={user <- @users} name={user.name} color="auto" size="sm" ring />
    </.avatar_group>

`size` takes the names (`3xs` 16px, `2xs` 20px, `xs` 24px, `xs-plus` 26px, `sm` 30px,
`md` 36px, `lg` 44px, `xl` 56px, `2xl` 72px, `sm-plus` 32px) or any number of pixels
(`"40"`). The legacy palette of the canvas is available with `color` `t1`..`t5`
(pastel tones), and `color="none"` leaves only the base face. `variant="mono"` is the dense
table avatar: initials in the mono font on a ring. Styled only with Tailwind utilities.

## `<.avatar>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `src` | `:string` | `nil` |  |
| `alt` | `:string` | `nil` | The picture's text; the `name` when not given. |
| `initials` | `:string` | `nil` | Shown (upper-cased) when there is no `src`. |
| `name` | `:string` | `nil` | Gives the initials (first and last word) and `color="auto"`. |
| `icon` | `:string` | `nil` | An icon drawn on the sunken face. |
| `kind` | `:string` | `nil` | `nil`, `company`, `customer`, `supplier`, `assistant`, `invite` |
| `size` | `:string` | `"sm"` | A size name or a number of pixels. |
| `shape` | `:string` | `"circle"` | `circle`, `square`, `rounded`, `squircle`, `reuleaux-triangle`, `diamond`, `hexagon`, `hexagon-2`, `octagon`, `star`, `star-2`, `heart` |
| `tint` | `:string` | `nil` | CSS color for the initials' background (white text). |
| `background` | `:string` | `nil` | Any CSS `background` for the face (white text). |
| `color` | `:string` | `"neutral"` | `auto`, `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `t1`, `t2`, `t3`, `t4`, `t5`, `none` |
| `variant` | `:string` | `"solid"` | `solid`, `soft`, `bordered`, `skeleton`, `mono` |
| `status` | `:any` | `nil` | Presence (`online`, `away`, `busy`, `offline`) or a tone; `nil`/`false` shows no dot. |
| `status_position` | `:string` | `nil` | `nil`, `bottom-left`, `bottom-right`, `top-left`, `top-right` |
| `ping` | `:boolean` | `false` | Animates the status dot. |
| `ring` | `:any` | `false` | `true`, `1`, `2` or `4`. |
| `speak` | `:boolean` | `false` | Speaking: a 2px page-colour gap, a 4px accent ring that pulses (`mo-speak`). |
| `ring_color` | `:string` | `nil` | `nil`, `white`, `panel`, `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error` |
| `face_class` | `:any` | `nil` |  |
| `gradient` | `:string` | `nil` | `nil`, `sky-blue`, `amber-orange`, `pink-rose`, `purple-orange`, `green-fuchsia`, `purple-indigo`, `fuchsia-pink` |
| `style` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` - Replaces the initials (an icon, a counter).

## `<.avatar_group>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `pulse` | `:boolean` | `false` |  |
| `overlap` | `:string` | `"2"` | `2`, `3`, `7`, `auto` |
| `more` | `:integer` | `nil` | Draws a "+N" avatar at the end. |
| `hidden` | `:list` | `nil` | The people that did not fit (maps with `:name`, optional `:src`). Needs `id`. |
| `id` | `:string` | `nil` |  |
| `size` | `:string` | `"xs"` |  |
| `spread` | `:boolean` | `false` |  |
| `ring_color` | `:string` | `"white"` | `white`, `panel` |
| `label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
