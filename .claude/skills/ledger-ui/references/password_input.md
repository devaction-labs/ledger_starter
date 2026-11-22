# LedgerUI.Components.PasswordInput

A password field with the eye button that shows what was typed.

    <.password_input name="password" placeholder="Enter password" />
    <.password_input field={@form[:password]} label="Senha" autocomplete="new-password" />

It is an `input/1` of `type="password"` (it takes every attr of `input/1`) with a lock at the
start and an eye at the end. The button flips the `type` between `password` and `text`, swaps
the icon and the accessible name with `Phoenix.LiveView.JS`, so it needs no hook.

## `<.password_input>`

Renders the field and the eye.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `id` | `:string` | `nil` | Defaults to the field id, then `name`; characters that break a CSS selector are replaced. |
| `show_label` | `:string` | `nil` |  |
| `hide_label` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |
| `field` | `{:struct, Phoenix.HTML.FormField}` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `value` | `:any` | `nil` |  |
| `label` | `:string` | `nil` |  |
| `help` | `:string` | `nil` |  |
| `errors` | `:list` | `[]` |  |
| `placeholder` | `:string` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `size` | `:string` | `"md"` | `sm`, `md`, `lg` |
| `variant` | `:string` | `"outlined"` | `outlined`, `filled`, `plain` |
| `state` | `:string` | `nil` | `nil`, ``, `success`, `error` |
| `visible` | `:boolean` | `false` | Starts with the text shown (the eye crossed out); the button hides it. |
| `loop` | `:boolean` | `false` | Demo animation (CSS only): the dots and the text of `value` swap by themselves. The field is `type="text"` and the dots are drawn over it. |
| `strength` | `:string` | `nil` | `nil`, `weak`, `fair`, `good`, `strong` - Draws the strength meter (1 to 4 bars) under the field; scoring the password is yours. |
| `autocomplete` | `:string` | `nil` |  |
| `required` | `:boolean` | `nil` |  |
| `minlength` | `:integer` | `nil` |  |
| `maxlength` | `:integer` | `nil` |  |
| `form` | `:string` | `nil` |  |
| `locale` | `:string` | `nil` | `"en"` or `"pt_BR"`; default: the process locale, the app config, `"en"` (see `LedgerUI.I18n`). |

Any other HTML/phx attribute goes to the root element, including `label_hint`, `layout`, `wrapper_class`, `shape`, `align`, `readonly`.

Slots:

- `<:below>`
- `<:label_aside>`
