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
        title="Pronto em 2 minutos"
        subtitle="conta, empresa e funil"
        top="64px"
        left="56px"
      />
      <:quote author="Rafael Lima" role="Fundador · Lumen Studio" initials="RL">
        Saímos da planilha para um funil de verdade em uma tarde.
      </:quote>
      <h1>Crie sua conta</h1>
      <p class="sub">14 dias grátis, sem cartão. Você convida o time depois.</p>

      <.google_button label="Cadastrar com Google" />
      <.or_divider :if={LedgerStarter.Auth.Google.enabled?()} />

      <.form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        class="flex flex-col gap-4"
      >
        <.auth_alert :if={@check_errors}>Revise os campos destacados.</.auth_alert>
        <.input
          field={@form[:name]}
          label="Seu nome"
          autocomplete="name"
          required
          phx-mounted={JS.focus()}
        />
        <.input
          field={@form[:email]}
          type="email"
          label="E-mail de trabalho"
          autocomplete="username"
          spellcheck="false"
          required
        />
        <.password_input
          field={@form[:password]}
          label="Senha"
          autocomplete="new-password"
          strength={@strength}
          show_label="Mostrar a senha"
          hide_label="Ocultar a senha"
          help="Forte: 12+ caracteres com número e símbolo."
          phx-debounce="200"
          required
        />
        <.checkbox field={@form[:terms]}>
          Li e aceito os <.link href={~p"/termos"} target="_blank">Termos</.link>
          e a <.link href={~p"/privacidade"} target="_blank">Política de Privacidade</.link>
        </.checkbox>
        <.auth_submit>Criar conta</.auth_submit>
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
        Já tem conta? <.link navigate={~p"/users/log-in"}>Entrar</.link>
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
     |> assign(page_title: "Criar conta")
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
    case Accounts.register_user(user_params) do
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
    assign(socket, form: to_form(changeset, as: "user"))
  end
end
