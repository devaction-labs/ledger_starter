defmodule LedgerStarterWeb.UserLive.Registration do
  use LedgerStarterWeb, :live_view

  import LedgerStarterWeb.AuthComponents

  alias LedgerStarter.Accounts
  alias LedgerStarter.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <.auth_screen flash={@flash} id="register">
      <:chip
        icon="sparkles"
        title={gettext("Pronto em 2 minutos")}
        subtitle={gettext("conta, empresa e funil")}
        top="64px"
        left="56px"
      />
      <:quote author="Rafael Lima" role={gettext("Fundador · Lumen Studio")} initials="RL">
        {gettext("Saímos da planilha para um funil de verdade em uma tarde.")}
      </:quote>
      <h1>{gettext("Crie sua conta")}</h1>
      <p class="sub">{gettext("14 dias grátis, sem cartão. Você convida o time depois.")}</p>

      <.google_button label={gettext("Cadastrar com Google")} />
      <.or_divider :if={LedgerStarter.Auth.Google.enabled?()} />

      <.form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        class="flex flex-col gap-4"
      >
        <.auth_alert :if={@check_errors}>
          {gettext("Revise os campos destacados.")}
        </.auth_alert>
        <.input
          field={@form[:name]}
          label={gettext("Seu nome")}
          autocomplete="name"
          required
          phx-mounted={JS.focus()}
        />
        <.input
          field={@form[:email]}
          type="email"
          label={gettext("E-mail de trabalho")}
          autocomplete="username"
          spellcheck="false"
          required
        />
        <.password_input
          field={@form[:password]}
          label={gettext("Senha")}
          autocomplete="new-password"
          strength={@strength}
          show_label={gettext("Mostrar a senha")}
          hide_label={gettext("Ocultar a senha")}
          help={gettext("Forte: 12+ caracteres com número e símbolo.")}
          phx-debounce="200"
          required
        />
        <.checkbox field={@form[:terms]}>
          {gettext("Li e aceito os")}
          <.link href={~p"/termos"} target="_blank">{gettext("Termos")}</.link>
          {gettext("e a")}
          <.link href={~p"/privacidade"} target="_blank">{gettext("Política de Privacidade")}</.link>
        </.checkbox>
        <.auth_submit>{gettext("Criar conta")}</.auth_submit>
      </.form>

      <form
        id="login_after_register"
        action={~p"/users/log-in"}
        method="post"
        phx-trigger-action={@trigger_submit}
      >
        <input type="hidden" name="_csrf_token" value={Phoenix.Controller.get_csrf_token()} />
        <input type="hidden" name="user[email]" value={@form[:email].value} />
        <input type="hidden" name="user[password]" value={@registered_password} />
        <input type="hidden" name="user[remember_me]" value="true" />
      </form>

      <p class="text-center text-[13.5px] text-muted">
        {gettext("Já tem conta?")}
        <.link navigate={~p"/users/log-in"}>{gettext("Entrar")}</.link>
      </p>
    </.auth_screen>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    attrs = %{"email" => params["email"]} |> Enum.reject(fn {_, v} -> is_nil(v) end) |> Map.new()

    changeset =
      Accounts.change_user_registration(%User{}, attrs,
        validate_unique: false,
        hash_password: false
      )

    {:ok,
     socket
     |> assign(page_title: gettext("Criar conta"))
     |> assign(
       trigger_submit: false,
       registered_password: nil,
       strength: nil,
       check_errors: false
     )
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(Map.put(user_params, "locale", socket.assigns.locale)) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> assign(trigger_submit: true, registered_password: user_params["password"])
         |> assign_form(
           Accounts.change_user_registration(%User{}, user_params,
             hash_password: false,
             validate_unique: false
           )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      Accounts.change_user_registration(%User{}, user_params,
        validate_unique: false,
        hash_password: false
      )

    {:noreply,
     socket
     |> assign(strength: password_strength(user_params["password"]))
     |> assign_form(Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: translated_form(changeset, as: "user"))
  end
end
