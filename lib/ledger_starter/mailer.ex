defmodule LedgerStarter.Mailer do
  use Swoosh.Mailer, otp_app: :ledger_starter

  import Swoosh.Email

  @doc "Sender `{name, address}` from config (`MAIL_FROM` in production)."
  def from do
    Application.get_env(
      :ledger_starter,
      :mail_from,
      {"StartKit", "no-reply@ledger.devaction.com.br"}
    )
  end

  @doc "Builds a pt-BR e-mail with a plain text and a simple HTML body."
  def build(recipient, subject, heading, paragraphs, cta \\ nil) do
    text =
      Enum.join(paragraphs, "\n\n") <>
        if(cta, do: "\n\n#{elem(cta, 0)}: #{elem(cta, 1)}", else: "") <>
        "\n\n-- StartKit"

    new()
    |> to(recipient)
    |> from(from())
    |> subject(subject)
    |> text_body(text)
    |> html_body(html(heading, paragraphs, cta))
  end

  defp html(heading, paragraphs, cta) do
    paras =
      Enum.map_join(paragraphs, "", &"<p style=\"margin:0 0 16px;color:#52525b\">#{esc(&1)}</p>")

    button =
      case cta do
        {label, url} ->
          "<p style=\"margin:24px 0\"><a href=\"#{esc(url)}\" style=\"background:#18181b;color:#fff;padding:12px 20px;border-radius:10px;text-decoration:none;font-weight:600\">#{esc(label)}</a></p>" <>
            "<p style=\"margin:0;font-size:12px;color:#71717a\">Ou copie este link: #{esc(url)}</p>"

        nil ->
          ""
      end

    """
    <div style="font-family:Inter,Arial,sans-serif;max-width:480px;margin:0 auto;padding:32px 20px;color:#18181b">
      <p style="font-weight:700;font-size:16px;margin:0 0 24px"><img src="#{LedgerStarterWeb.Endpoint.url()}/icon-192.png" width="28" height="28" alt="" style="vertical-align:middle;border-radius:8px;margin-right:10px">StartKit</p>
      <h1 style="font-size:22px;margin:0 0 16px">#{esc(heading)}</h1>
      #{paras}#{button}
    </div>
    """
  end

  defp esc(text), do: text |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
end
