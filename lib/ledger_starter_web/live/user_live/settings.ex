defmodule LedgerStarterWeb.UserLive.Settings do
  use LedgerStarterWeb, :live_view

  on_mount {LedgerStarterWeb.UserAuth, :require_sudo_mode}

  alias LedgerStarter.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-page">
      <.toaster flash={@flash} />
      <.navbar>
        <.brand_logo />
        <:end>
          <.theme_switch id="theme-settings" size="sm" />
          <.button navigate={~p"/workspaces"} variant="ghost" size="sm">Meus workspaces</.button>
        </:end>
      </.navbar>
      <main class="mx-auto flex max-w-[560px] flex-col gap-5 px-6 py-10">
        <div>
          <h1 class="m-0 font-display text-[28px] font-[650] tracking-[-.03em]">Minha conta</h1>
          <p class="m-0 mt-1 text-muted">Gerencie seu e-mail e sua senha.</p>
        </div>

        <.card>
          <.card_header>
            <.card_heading>E-mail</.card_heading>
          </.card_header>
          <.card_body>
            <.form
              for={@email_form}
              id="email_form"
              phx-submit="update_email"
              phx-change="validate_email"
              class="flex flex-col gap-4"
            >
              <.input
                field={@email_form[:email]}
                type="email"
                label="E-mail"
                autocomplete="username"
                spellcheck="false"
                required
              />
              <div>
                <.button type="submit" phx-disable-with="Alterando...">Alterar e-mail</.button>
              </div>
            </.form>
          </.card_body>
        </.card>

        <.card>
          <.card_header>
            <.card_heading>Senha</.card_heading>
          </.card_header>
          <.card_body>
            <.form
              for={@password_form}
              id="password_form"
              action={~p"/users/update-password"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
              class="flex flex-col gap-4"
            >
              <input
                name={@password_form[:email].name}
                type="hidden"
                id="hidden_user_email"
                spellcheck="false"
                value={@current_email}
              />
              <.password_input
                field={@password_form[:password]}
                label="Nova senha"
                autocomplete="new-password"
                show_label="Mostrar a senha"
                hide_label="Ocultar a senha"
                required
              />
              <.password_input
                field={@password_form[:password_confirmation]}
                label="Confirmar nova senha"
                autocomplete="new-password"
                show_label="Mostrar a senha"
                hide_label="Ocultar a senha"
              />
              <div><.button type="submit" phx-disable-with="Salvando...">Salvar senha</.button></div>
            </.form>
          </.card_body>
        </.card>
      </main>
    </div>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "E-mail alterado.")

        {:error, _} ->
          put_flash(socket, :error, "O link de alteração de e-mail é inválido ou expirou.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = "Enviamos um link de confirmação para o novo e-mail."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end
