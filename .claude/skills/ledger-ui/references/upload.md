# LedgerUI.Components.Upload

File uploads built on LiveView uploads: the drop panel with each file's progress, errors and
cancel button (shown on finished entries too, so a sent file can be removed before submitting), and the styled "Choose File" button.

    # mount
    socket |> allow_upload(:photos, accept: ~w(.jpg .png), max_entries: 4)

    <.form for={@form} phx-change="validate" phx-submit="save">
      <.upload upload={@uploads.photos} on_cancel="cancel-upload" columns={2}
        hint="PDF, XML ou CSV · até 10 MB cada" />
    </.form>

    def handle_event("cancel-upload", %{"ref" => ref}, socket),
      do: {:noreply, cancel_upload(socket, :photos, ref)}

`upload/1` renders `live_file_input` itself, so it must sit inside the form that has the
`phx-change` LiveView uploads need. Dropping files on the panel works through `phx-drop-target`;
the `LedgerUI.Upload` hook (`priv/static/ledger_ui/hooks/upload.js`) only sets `data-state="over"`
(which paints the `over` state) while files are dragged over it.

The pieces it is made of are public and stateless, for custom layouts and for the design
gallery: `upload_drop/1` (the dashed drop area), `upload_zone/1` (the compact zone with the
kit's variants), `upload_file/1` (a file card), `upload_thumbs/1` and `upload_button/1`.

Deviation from the README: `upload_button/1` is a `<label>` around the file input (as the
README says), so the design's `<button>` is not reproduced byte for byte; `variant` accepts the
design's zone variants too (`solid glow outline soft bordered flat glass dim`).

## `<.upload_drop>`

The dashed drop area: icon, label with the browse link, and a hint.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `drop_label` | `:string` | `"Drag & Drop your files or"` |  |
| `browse_label` | `:string` | `"Browse"` |  |
| `hint` | `:string` | `nil` |  |
| `over` | `:boolean` | `false` | Draws the drag-over state. |
| `error` | `:boolean` | `false` |  |
| `loop` | `:boolean` | `false` | The canvas demo animation: the area takes the drag-over look and lets go, every 5s. |
| `circle` | `:boolean` | `false` | A round area (the `circle` layout). |
| `for` | `:string` | `nil` | Id of the file input: the area becomes its `<label>`. |
| `icon_path` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:label>` - Replaces the text of the area.

## `<.upload_zone>`

The compact drop zone with the kit's variants, colors, shapes and sizes.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `variant` | `:string` | `"canvas"` | `canvas`, `pond`, `solid`, `glow`, `outline`, `soft`, `bordered`, `flat`, `glass`, `dim` |
| `color` | `:string` | `"primary"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `mono`, `white`, `current` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill`, `square` |
| `size` | `:string` | `nil` | `nil`, `md`, `xl` |
| `for` | `:string` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.upload_file>`

A file card: badge, name, status, progress bar and the remove (or retry) button.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `name` (required) | `:string` |  |  |
| `ext` | `:string` | `nil` | The badge text (`XML`); the extension of `name` by default. |
| `status` | `:string` | `nil` | The line under the name. |
| `progress` | `:integer` | `0` |  |
| `loop` | `:boolean` | `false` | The canvas demo animation: the progress bar fills from 0 to 100%, every 4s. |
| `state` | `:string` | `"progress"` | `progress`, `done`, `error` |
| `remove_label` | `:string` | `"Remove"` |  |
| `retry_label` | `:string` | `nil` | On an error: a retry button with this text. |
| `removable` | `:boolean` | `true` |  |
| `on_remove` | `:any` | `nil` | An event name or a `%JS{}` for the remove button. It also shows next to the check on finished (`done`) cards. |
| `on_retry` | `:any` | `nil` |  |
| `ref` | `:string` | `nil` | Sent as `phx-value-ref` with the events. |
| `target` | `:any` | `nil` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:preview>` - Replaces the extension badge (an image preview).

## `<.upload_thumbs>`

The grid of 64px thumbnails.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `count` | `:integer` | `3` |  |
| `columns` | `:integer` | `nil` | `--cols` (3 by default). |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` - Your own tiles instead of `count` placeholders.

## `<.upload_button>`

A button that opens the file chooser: a `<label>` with the button classes holding an invisible
file input. With `upload` it renders `live_file_input`; otherwise a plain `<input type="file">`.

    <.upload_button upload={@uploads.avatar}>Choose File</.upload_button>
    <.upload_button name="doc" variant="outline" size="sm">Attach</.upload_button>

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `upload` | `{:struct, Phoenix.LiveView.UploadConfig}` | `nil` |  |
| `name` | `:string` | `nil` |  |
| `multiple` | `:boolean` | `false` |  |
| `accept` | `:string` | `nil` |  |
| `disabled` | `:boolean` | `false` |  |
| `color` | `:string` | `"neutral"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `mono`, `white`, `current` |
| `variant` | `:string` | `"solid"` | `solid`, `glow`, `outline`, `soft`, `bordered`, `flat`, `glass`, `ghost`, `dim` |
| `size` | `:string` | `nil` | `nil`, ``, `xs`, `sm`, `md`, `lg`, `xl` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill`, `square` |
| `icon` | `:boolean` | `false` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:inner_block>` (required)

## `<.upload>`

Renders the drop panel and the list of chosen files.

| Attr | Type | Default | Values / notes |
|---|---|---|---|
| `upload` (required) | `{:struct, Phoenix.LiveView.UploadConfig}` |  |  |
| `id` | `:string` | `nil` |  |
| `bordered` | `:boolean` | `false` |  |
| `filled` | `:boolean` | `false` |  |
| `columns` | `:integer` | `1` | `1`, `2`, `3`, `4` |
| `variant` | `:string` | `"canvas"` | `canvas`, `pond`, `solid`, `glow`, `outline`, `soft`, `bordered`, `flat`, `glass`, `dim` |
| `color` | `:string` | `"primary"` | `neutral`, `primary`, `secondary`, `info`, `success`, `warning`, `error`, `mono`, `white`, `current` |
| `shape` | `:string` | `"rounded"` | `rounded`, `pill`, `square` |
| `size` | `:string` | `nil` | `nil`, `md`, `xl` |
| `layout` | `:string` | `"panel"` | `panel`, `circle`, `thumbs` |
| `hint` | `:string` | `nil` |  |
| `browse` | `:string` | `nil` |  |
| `icon_path` | `:string` | `nil` |  |
| `drop_class` | `:any` | `nil` |  |
| `on_cancel` | `:any` | `nil` |  |
| `target` | `:any` | `nil` |  |
| `previews` | `:boolean` | `true` |  |
| `error_texts` | `:map` | `%{too_large: "File is too large", too_many_files: "Too many files", external_client_failure: "Upload failed", not_accepted: "File of invalid type"}` |  |
| `browse_label` | `:string` | `"Browse"` |  |
| `drop_label` | `:string` | `"Drag & Drop your files or"` |  |
| `remove_label` | `:string` | `"Remove"` |  |
| `uploading_label` | `:string` | `"Uploading"` |  |
| `complete_label` | `:string` | `"Upload complete"` |  |
| `class` | `:any` | `nil` |  |

Any other HTML/phx attribute goes to the root element.

Slots:

- `<:label>` - Replaces the text of the drop panel.
