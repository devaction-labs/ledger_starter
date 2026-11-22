defmodule LedgerStarterWeb.UserLive.Confirmation do
  @moduledoc "Landing of the magic link: one click to sign in (so mail scanners do not burn the token)."
  use LedgerStarterWeb, :live_view

  import LedgerStarterWeb.AuthComponents

  alias LedgerStarter.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <.auth_screen flash={@flash} id="confirm">
      <:chip
        icon="check"
        title={gettext("Link válido")}
        subtitle={gettext("uso único")}
        top="64px"
        left="56px"
      />

      <h1>
        {if @user.confirmed_at, do: gettext("Bem-vindo de volta"), else: gettext("Confirme sua conta")}
      </h1>
      <p class="sub">{@user.email}</p>
      <.form
        for={@form}
        id="confirmation_form"
        phx-submit="submit"
        phx-mounted={JS.focus_first()}
        action={
          if @user.confirmed_at, do: ~p"/users/log-in", else: ~p"/users/log-in?_action=confirmed"
        }
        phx-trigger-action={@trigger_submit}
      >
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <input type="hidden" name={@form[:remember_me].name} value="true" />
        <.auth_submit>
          {if @user.confirmed_at, do: gettext("Entrar"), else: gettext("Confirmar e entrar")}
        </.auth_submit>
      </.form>
    </.auth_screen>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    if user = Accounts.get_user_by_magic_link_token(token) do
      form = to_form(%{"token" => token}, as: "user")

      {:ok,
       assign(socket,
         page_title: gettext("Entrar"),
         user: user,
         form: form,
         trigger_submit: false
       )}
    else
      {:ok,
       socket
       |> put_flash(:error, gettext("O link é inválido ou expirou."))
       |> push_navigate(to: ~p"/users/log-in/link")}
    end
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "user"), trigger_submit: true)}
  end
end
