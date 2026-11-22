defmodule LedgerStarterWeb.ContactLive.Index do
  use LedgerStarterWeb, :live_view

  alias LedgerStarter.{Companies, Contacts}
  alias LedgerStarter.Contacts.Contact
  alias LedgerStarterWeb.{DashboardLive, Layouts}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      companies={@companies}
      current={~p"/contatos"}
      crumb={gettext("Contatos")}
    >
      <.page_header title={gettext("Contatos")} description={description(@count, @current_company)}>
        <:actions>
          <.button
            :if={PermitEx.can?(@current_scope, "contacts:write")}
            id="new-contact"
            patch={~p"/contatos/novo"}
            icon="plus"
          >
            {gettext("Novo contato")}
          </.button>
        </:actions>
      </.page_header>

      <div class="px-7 pb-8">
        <.card_table
          id="contacts"
          rows={@streams.contacts}
          loading={@loading}
          loading_label={gettext("Carregando")}
          retry_label={gettext("Tentar novamente")}
        >
          <:col :let={{_id, c}} label={gettext("Nome")}>
            <span class="flex items-center gap-2.5">
              <.avatar initials={Layouts.initials(c.name)} size="30" />
              <span class="font-medium">{c.name}</span>
            </span>
          </:col>
          <:col :let={{_id, c}} label={gettext("E-mail")} priority={2}>{c.email}</:col>
          <:col :let={{_id, c}} label={gettext("Empresa")} priority={3}>{c.company_name || "—"}</:col>
          <:col :let={{_id, c}} label={gettext("Etapa")} role="status">
            <.badge color={DashboardLive.stage_color(c.stage)} dot>
              {DashboardLive.stage_label(c.stage)}
            </.badge>
          </:col>
          <:col :let={{_id, c}} label={gettext("Criado")} priority={4}>
            {format_date(c.inserted_at)}
          </:col>
          <:action :let={{_id, c}}>
            <.dropdown
              :if={PermitEx.can_any?(@current_scope, ["contacts:write", "contacts:delete"])}
              id={"contact-menu-#{c.id}"}
              trigger_style="ghost"
              part="action-menu"
              row_mark
              label={gettext("Ações")}
              placement="bottom-end"
            >
              <.dropdown_item
                :if={PermitEx.can?(@current_scope, "contacts:write")}
                patch={~p"/contatos/#{c.id}/editar"}
              >
                <:icon><.icon name="edit" /></:icon>
                {gettext("Editar")}
              </.dropdown_item>
              <.dropdown_item
                :if={PermitEx.can?(@current_scope, "contacts:delete")}
                danger
                phx-click="delete"
                phx-value-id={c.id}
                data-confirm={gettext("Excluir este contato?")}
              >
                <:icon><.icon name="trash" /></:icon>
                {gettext("Excluir")}
              </.dropdown_item>
            </.dropdown>
          </:action>
          <:empty>
            <.empty_state variant="table" icon="users" title={gettext("Nenhum contato ainda")}>
              {gettext("Cadastre o primeiro contato do workspace %{name}.",
                name: @current_company.name
              )}
            </.empty_state>
          </:empty>
        </.card_table>
      </div>

      <:aside>
        <.modal
          :if={@live_action in [:new, :edit]}
          id="contact-modal"
          layout="page"
          open
          title={
            if @live_action == :new, do: gettext("Novo contato"), else: gettext("Editar contato")
          }
          description={
            gettext("Ele fica visível para todo o time do %{name}.", name: @current_company.name)
          }
          icon="user-plus"
          on_close="close_modal"
          phx-change="validate"
          phx-submit="save"
        >
          <div class="flex flex-col gap-4">
            <.input
              field={@form[:name]}
              label={gettext("Nome")}
              autocomplete="off"
              required
              phx-debounce="200"
            />
            <.input
              field={@form[:email]}
              type="email"
              label={gettext("E-mail")}
              required
              phx-debounce="200"
            />
            <div class="grid grid-cols-2 gap-3">
              <.input
                field={@form[:phone]}
                type="tel"
                label={gettext("Telefone")}
                placeholder="(75) 99812-4410"
              />
              <.input field={@form[:company_name]} label={gettext("Empresa")} />
            </div>
            <div class="flex flex-col gap-1.5">
              <span class="text-[13px] font-medium">{gettext("Etapa")}</span>
              <.segmented
                id="contact-stage"
                field={@form[:stage]}
                options={[
                  {gettext("Lead"), "lead"},
                  {gettext("Qualificado"), "qualified"},
                  {gettext("Cliente"), "customer"}
                ]}
              />
            </div>
          </div>
          <:footer>
            <.button type="button" variant="outline" phx-click="close_modal">
              {gettext("Cancelar")}
            </.button>
            <.button type="submit" phx-disable-with={gettext("Salvando...")}>
              {gettext("Salvar contato")}
            </.button>
          </:footer>
        </.modal>
      </:aside>
    </Layouts.app>
    """
  end

  on_mount {LedgerStarterWeb.UserAuth, {:require_permission, "contacts:read", :contatos}}

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    if connected?(socket), do: Contacts.subscribe_contacts(scope)

    {:ok,
     socket
     |> assign(page_title: gettext("Contatos"), loading: true, count: nil)
     |> assign_new(:companies, fn -> Companies.list_companies_for_user(scope.user) end)
     |> stream(:contacts, [])
     |> load_contacts()}
  end

  @impl true
  def handle_params(params, _uri, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  defp apply_action(socket, :index, _params), do: assign(socket, form: nil)

  defp apply_action(socket, :new, _params) do
    scope = socket.assigns.current_scope

    if PermitEx.can?(scope, "contacts:write") do
      assign_form(socket, scope, %Contact{company_id: scope.company.id, stage: :lead})
    else
      deny(socket)
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    scope = socket.assigns.current_scope

    with true <- PermitEx.can?(scope, "contacts:write"),
         %Contact{} = contact <- Contacts.get_contact(scope, id) do
      assign_form(socket, scope, contact)
    else
      false ->
        deny(socket)

      nil ->
        socket
        |> put_flash(:error, gettext("Contato não encontrado."))
        |> push_patch(to: ~p"/contatos")
        |> assign(form: nil)
    end
  end

  defp deny(socket) do
    socket
    |> put_flash(:error, gettext("Você não tem permissão para isso."))
    |> push_patch(to: ~p"/contatos")
    |> assign(form: nil)
  end

  defp assign_form(socket, scope, contact) do
    assign(socket,
      contact: contact,
      form: translated_form(Contacts.change_contact(scope, contact))
    )
  end

  @impl true
  def handle_event("close_modal", _params, socket),
    do: {:noreply, push_patch(socket, to: ~p"/contatos")}

  # Forged events without an open form are ignored.
  def handle_event(event, _params, %{assigns: %{form: nil}} = socket)
      when event in ~w(validate save),
      do: {:noreply, socket}

  def handle_event("validate", %{"contact" => params}, socket) do
    changeset =
      Contacts.change_contact(socket.assigns.current_scope, socket.assigns.contact, params)

    {:noreply, assign(socket, form: translated_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contact" => params}, socket),
    do: save(socket, socket.assigns.live_action, params)

  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope

    with %Contact{} = contact <- Contacts.get_contact(scope, id),
         {:ok, _} <- Contacts.delete_contact(scope, contact) do
      {:noreply, put_toast(socket, gettext("Contato excluído."), color: "success")}
    else
      nil ->
        {:noreply, put_flash(socket, :error, gettext("Contato não encontrado."))}

      {:error, :unauthorized} ->
        {:noreply, put_flash(socket, :error, gettext("Você não tem permissão para excluir."))}
    end
  end

  defp save(socket, :new, params) do
    case Contacts.create_contact(socket.assigns.current_scope, params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Contato criado."))
         |> push_patch(to: ~p"/contatos")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: translated_form(changeset))}

      {:error, :unauthorized} ->
        {:noreply, deny(socket)}
    end
  end

  defp save(socket, :edit, params) do
    case Contacts.update_contact(socket.assigns.current_scope, socket.assigns.contact, params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Contato atualizado."))
         |> push_patch(to: ~p"/contatos")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: translated_form(changeset))}

      {:error, :unauthorized} ->
        {:noreply, deny(socket)}
    end
  end

  @impl true
  def handle_async(:load, {:ok, contacts}, socket) do
    {:noreply,
     socket
     |> assign(loading: false, count: length(contacts))
     |> stream(:contacts, contacts, reset: true)}
  end

  def handle_async(:load, {:exit, _reason}, socket),
    do: {:noreply, assign(socket, loading: false)}

  # Another member changed a contact: reload the list.
  @impl true
  def handle_info({type, %Contact{}}, socket) when type in [:created, :updated, :deleted],
    do: {:noreply, load_contacts(socket)}

  defp load_contacts(socket) do
    if connected?(socket) do
      scope = socket.assigns.current_scope
      start_async(socket, :load, fn -> Contacts.list_contacts(scope) end)
    else
      socket
    end
  end

  defp description(nil, company),
    do: gettext("Contatos do workspace %{name}.", name: company.name)

  defp description(count, company),
    do:
      ngettext(
        "%{count} contato no workspace %{name}.",
        "%{count} contatos no workspace %{name}.",
        count,
        name: company.name
      )

  # The date format is a translation too: %d/%m/%Y in pt_BR, %m/%d/%Y in en.
  defp format_date(dt), do: Calendar.strftime(dt, pgettext("date format", "%d/%m/%Y"))
end
