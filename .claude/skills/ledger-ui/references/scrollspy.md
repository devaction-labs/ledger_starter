# LedgerUI.Components.Scrollspy

A list of links to the sections of the page that marks the section in view.

    <.scrollspy id="settings-nav" offset={96}>
      <:item href="#profile">Profile</:item>
      <:item href="#security">Security</:item>
    </.scrollspy>

The hook `LedgerUI.Scrollspy` (`priv/static/ledger_ui/hooks/scrollspy.js`) watches the elements
the links point at and moves `aria-current="true"` to the link of the
section at the top of the view (`offset` pixels from the top, 120 by default). A click scrolls
to the section smoothly (instantly with `prefers-reduced-motion`). The marked link turns `ink`
and a 2px bar on the left edge slides to it: the hook writes `--spy-y` and `--spy-h` (the
link's offset and height) on the nav and the bar follows them.

The server renders `aria-current="true"` on an item given `active` (the initial
state); the hook only updates it as the page scrolls.

The root is a `<nav>`; wrap it in a grid yourself. `label: nil` omits the `aria-label`.
`demo` is the animated mock (the marker walks over the links by itself: stagger them with
`style="--dl:2s"`), which does not need the hook. Styled only with Tailwind utilities; the parts are
`data-part="scrollspy"` and `"scrollspy-link"`.

## `<.scrollspy>`

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` (required) | `:string` |  |  |
| `label` | `:any` | `"On this page"` |  |
| `offset` | `:integer` | `120` |  |
| `target` | `:string` | `nil` | A selector (`"#doc"`) of the element that scrolls the sections, when it is not the page. |
| `demo` | `:boolean` | `false` | The animated mock: the marker walks over the links, no hook needed. |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:item>` (required) - attrs: `href`, `active`, `class`, `style`, `id`
