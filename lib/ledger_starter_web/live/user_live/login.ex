defmodule LedgerStarterWeb.UserLive.Login do
  use LedgerStarterWeb, :live_view

  import LedgerStarterWeb.AuthComponents

  @impl true
  def render(assigns) do
    ~H"""
    <.auth_screen id="login">
      <:chip
        icon="building"
        title="3 workspaces"
        subtitle="Orbit · Bompreço · Lumen"
        top="64px"
        left="56px"
      />
      <:chip icon="kanban" title="R$ 184 mil" subtitle="em negociação" top="150px" right="48px" />
      <:quote author="Marina Costa" role="Comercial · Orbit Cloud" initials="MC">
        Configuramos o funil e convidamos o time no mesmo dia.
      </:quote>
      <h1>Entrar no StartKit</h1>
      <p class="sub">O CRM da sua empresa, com o time inteiro no mesmo funil.</p>

      <.google_button label="Continuar com Google" />
      <.button
        navigate={~p"/users/log-in/link"}
        icon="mail"
        class="w-full"
        size="lg"
        variant="outline"
      >
        Entrar com link mágico
      </.button>
      <.or_divider />

      <.form
        :let={f}
        for={@form}
        id="login_form_password"
        action={~p"/users/log-in"}
        phx-submit="submit"
        phx-trigger-action={@trigger_submit}
        class="flex flex-col gap-4"
      >
        <.auth_alert :if={@error}>E-mail ou senha inválidos.</.auth_alert>
        <.input
          field={f[:email]}
          type="email"
          label="E-mail de trabalho"
          placeholder="voce@empresa.com.br"
          autocomplete="username"
          spellcheck="false"
          required
          phx-mounted={JS.focus()}
        />
        <.password_input
          field={@form[:password]}
          label="Senha"
          autocomplete="current-password"
          show_label="Mostrar a senha"
          hide_label="Ocultar a senha"
          required
        />
        <div class="flex items-center justify-between">
          <.checkbox field={@form[:remember_me]} label="Manter conectado" />
        </div>
        <.auth_submit>Entrar</.auth_submit>
      </.form>

      <p class="text-center text-[13.5px] text-muted">
        Novo por aqui? <.link navigate={~p"/users/register"}>Criar conta grátis</.link>
      </p>
    </.auth_screen>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email, "remember_me" => "true"}, as: "user")

    {:ok,
     assign(socket,
       page_title: "Entrar",
       form: form,
       trigger_submit: false,
       error: Phoenix.Flash.get(socket.assigns.flash, :error) == "E-mail ou senha inválidos."
     )}
  end

  @impl true
  def handle_event("submit", %{"user" => _params}, socket) do
    {:noreply, assign(socket, trigger_submit: true)}
  end
end
