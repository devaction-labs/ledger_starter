defmodule LedgerStarterWeb.UserLive.MagicLink do
  @moduledoc "Request a magic link (\"Entrar sem senha\") and the \"link enviado\" state."
  use LedgerStarterWeb, :live_view

  import LedgerStarterWeb.AuthComponents

  alias LedgerStarter.Accounts

  @impl true
  def render(%{sent_to: nil} = assigns) do
    ~H"""
    <.auth_screen flash={@flash} id="magic">
      <:chip
        icon="mail"
        title={gettext("Sem senha")}
        subtitle={gettext("um clique no e-mail")}
        top="64px"
        left="56px"
      />
      <:chip
        icon="lock"
        title={gettext("Link de uso único")}
        subtitle={gettext("expira em 15 min")}
        top="150px"
        right="48px"
      />

      <h1>{gettext("Entrar sem senha")}</h1>
      <p class="sub">
        {gettext(
          "Mandamos um link de acesso para o seu e-mail. Ele vale por 15 minutos e entra direto no seu workspace."
        )}
      </p>
      <.form for={@form} id="magic_link_form" phx-submit="send" class="flex flex-col gap-4">
        <.input
          field={@form[:email]}
          type="email"
          label={gettext("E-mail de trabalho")}
          placeholder={gettext("voce@empresa.com.br")}
          autocomplete="username"
          spellcheck="false"
          required
          phx-mounted={JS.focus()}
        />
        <.auth_submit>{gettext("Enviar link mágico")}</.auth_submit>
      </.form>
      <.or_divider label={gettext("ou")} />
      <.button navigate={~p"/users/log-in"} class="w-full" size="lg" variant="outline">
        {gettext("Entrar com senha")}
      </.button>
      <p class="text-center text-[13.5px] text-muted">
        {gettext("Novo por aqui?")}
        <.link navigate={~p"/users/register"}>{gettext("Criar conta grátis")}</.link>
      </p>
    </.auth_screen>
    """
  end

  def render(assigns) do
    ~H"""
    <.auth_screen flash={@flash} id="magic-sent">
      <:chip
        icon="check"
        title={gettext("Link enviado")}
        subtitle={gettext("agora mesmo")}
        top="64px"
        left="56px"
      />

      <h1>{gettext("Confira seu e-mail")}</h1>
      <.auth_sent id="magic-sent-notice">
        {gettext("Enviamos um link de acesso para")} <b>{@sent_to}</b>. {gettext(
          "Abra no mesmo navegador; ele vale por 15 minutos."
        )}
      </.auth_sent>
      <.button phx-click="resend" class="w-full" size="lg" variant="outline">
        {gettext("Reenviar link")}
      </.button>
      <p class="text-center text-[13.5px] text-muted">
        {gettext("Errou o e-mail?")}
        <.link patch={~p"/users/log-in/link"} phx-click="reset">{gettext("Usar outro")}</.link>
      </p>
    </.auth_screen>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: gettext("Entrar sem senha"),
       sent_to: nil,
       form: to_form(%{"email" => nil}, as: "user")
     )}
  end

  @impl true
  def handle_event("send", %{"user" => %{"email" => email}}, socket) do
    email = String.trim(email)
    deliver(email)
    {:noreply, assign(socket, sent_to: email)}
  end

  def handle_event("resend", _params, socket) do
    deliver(socket.assigns.sent_to)
    {:noreply, put_flash(socket, :info, gettext("Link reenviado."))}
  end

  def handle_event("reset", _params, socket), do: {:noreply, assign(socket, sent_to: nil)}

  # Same answer whether or not the account exists (no user enumeration).
  defp deliver(email) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(user, &url(~p"/users/log-in/#{&1}"))
    end
  end
end
