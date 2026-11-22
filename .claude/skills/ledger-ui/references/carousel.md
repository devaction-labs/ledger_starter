# LedgerUI.Components.Carousel

Carousels without Swiper: slides on a track, and the `LedgerUI.Carousel` hook for arrows,
pagination, autoplay, keyboard, swipe and effects.

    <.carousel id="gallery" navigation slides={3}>
      <.carousel_slide><img class="h-full w-full object-cover" src="/a.jpg" alt="" /></.carousel_slide>
      <.carousel_slide>...</.carousel_slide>
      <.carousel_slide>...</.carousel_slide>
    </.carousel>

    <.carousel id="promo" pagination="bullets" slides={3} autoplay={2000} loop>...</.carousel>
    <.carousel id="flip" effect="flip" navigation>...</.carousel>

`effect` is `slide` (the scrolling track), `fade`, `flip`, `cube`, `cards`, `coverflow` or
`creative`. `pagination` is `bullets`, `fraction`, `progress` or `scrollbar`; it is rendered
on the server, so give the number of `slides` (or one `:thumb` slot per slide). `:thumb` slots
draw a row of thumbnails under the track that pick the slide.

The server's slide is `index`; the person moves freely in the browser, and their slide survives
patches. `on_change` (an event name or `%JS{}`) runs when the slide changes; an event name is
pushed with `%{"id" => id, "index" => index}` to `target`. From the server,
`push_event(socket, "ledger:carousel", %{id: "gallery", index: 2})` moves it.

The component renders the track and, as its siblings, the pagination and the thumbnails.
The bullets are `<i role="button" tabindex="0" aria-label=...>` rendered by the server; the hook only moves `aria-current` and the slides' `aria-hidden`.
Configuration that is not the default travels in `data-*` attributes of the track's root, which
carries `phx-hook="LedgerUI.Carousel"` (`data-lu-effect` and `data-lu-direction` say what to draw). Styled
only with Tailwind utilities; the bullets and thumbnails read `aria-current`.

## `<.carousel>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `index` | `:integer` | `0` | The active slide, zero-based. |
| `effect` | `:string` | `"slide"` | `slide`, `fade`, `flip`, `cube`, `cards`, `coverflow`, `creative` |
| `direction` | `:string` | `"horizontal"` | `horizontal`, `vertical` |
| `navigation` | `:any` | `false` | `true`, `false`, `inside`, `outside` - The previous and next arrows. |
| `pagination` | `:string` | `nil` | `nil`, `bullets`, `fraction`, `progress`, `scrollbar` |
| `slides` | `:integer` | `nil` | How many slides there are, for the pagination (the `:thumb` count when omitted). |
| `autoplay` | `:integer` | `nil` | Milliseconds between slides; pauses on hover. |
| `loop` | `:boolean` | `false` |  |
| `demo` | `:boolean` | `false` | The canvas CSS loop (no hook): `slide` scrolls its track (`mo-car`, 9s), `fade` cross-fades the slides (`mo-fade3`, delay `--dl` on each slide: 0s, 3s, 6s), and the bullets light up in turn (`mo-cdot`). |
| `gap` | `:integer` | `nil` | Pixels between slides. |
| `zoom` | `:integer` | `nil` | Double-click zoom ratio. |
| `on_change` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `prev_label` | `:string` | `nil` |  |
| `next_label` | `:string` | `nil` |  |
| `bullet_label` | `:string` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `variant` | `:string` | `"canvas"` | `canvas`, `classic` |
| `thumb_label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:background>` - Behind the track, for a parallax background.
- `<:inner_block>` (required)
- `<:thumb>` - A thumbnail per slide, in order.

## `<.carousel_slide>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)
