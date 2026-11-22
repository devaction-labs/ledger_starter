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
      crumb="Contatos"
    >
      <.page_header title="Contatos" description={description(@count, @current_company)}>
        <:actions>
          <.button
            :if={PermitEx.can?(@current_scope, "contacts:create")}
            id="new-contact"
            navigate={~p"/contatos/novo"}
            icon="plus"
          >
            Novo contato
          </.button>
        </:actions>
      </.page_header>

      <div class="px-7 pb-8">
        <.card_table id="contacts" rows={@streams.contacts} loading={@loading}>
          <:col :let={{_id, c}} label="Nome">
            <span class="flex items-center gap-2.5">
              <.avatar initials={Layouts.initials(c.name)} size="30" />
              <span class="font-medium">{c.name}</span>
            </span>
          </:col>
          <:col :let={{_id, c}} label="E-mail" priority={2}>{c.email}</:col>
          <:col :let={{_id, c}} label="Empresa" priority={3}>{c.company_name || "—"}</:col>
          <:col :let={{_id, c}} label="Etapa" role="status">
            <.badge color={DashboardLive.stage_color(c.stage)} dot>
              {DashboardLive.stage_label(c.stage)}
            </.badge>
          </:col>
          <:col :let={{_id, c}} label="Criado" priority={4}>{format_date(c.inserted_at)}</:col>
          <:action :let={{_id, c}}>
            <.dropdown
              :if={PermitEx.can_any?(@current_scope, ["contacts:update", "contacts:delete"])}
              id={"contact-menu-#{c.id}"}
              trigger_style="ghost"
              part="action-menu"
              row_mark
              label="Ações"
              placement="bottom-end"
            >
              <.dropdown_item
                :if={PermitEx.can?(@current_scope, "contacts:update")}
                navigate={~p"/contatos/#{c.id}/editar"}
              >
                <:icon><.icon name="edit" /></:icon>
                Editar
              </.dropdown_item>
              <.dropdown_item
                :if={PermitEx.can?(@current_scope, "contacts:delete")}
                danger
                phx-click="delete"
                phx-value-id={c.id}
                data-confirm="Excluir este contato?"
              >
                <:icon><.icon name="trash" /></:icon>
                Excluir
              </.dropdown_item>
            </.dropdown>
          </:action>
          <:empty>
            <.empty_state variant="table" icon="users" title="Nenhum contato ainda">
              Cadastre o primeiro contato do workspace {@current_company.name}.
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
          title={if @live_action == :new, do: "Novo contato", else: "Editar contato"}
          description={"Ele fica visível para todo o time do #{@current_company.name}."}
          icon="user-plus"
          on_close="close_modal"
          phx-change="validate"
          phx-submit="save"
        >
          <div class="flex flex-col gap-4">
            <.input field={@form[:name]} label="Nome" autocomplete="off" required phx-debounce="200" />
            <.input field={@form[:email]} type="email" label="E-mail" required phx-debounce="200" />
            <div class="grid grid-cols-2 gap-3">
              <.input field={@form[:phone]} type="tel" label="Telefone" placeholder="(75) 99812-4410" />
              <.input field={@form[:company_name]} label="Empresa" />
            </div>
            <div class="flex flex-col gap-1.5">
              <span class="text-[13px] font-medium">Etapa</span>
              <.segmented
                id="contact-stage"
                field={@form[:stage]}
                options={[{"Lead", "lead"}, {"Qualificado", "qualified"}, {"Cliente", "customer"}]}
              />
            </div>
          </div>
          <:footer>
            <.button type="button" variant="outline" phx-click="close_modal">Cancelar</.button>
            <.button type="submit" phx-disable-with="Salvando...">Salvar contato</.button>
          </:footer>
        </.modal>
      </:aside>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if PermitEx.can?(scope, "contacts:read") do
      if connected?(socket), do: Contacts.subscribe_contacts(scope)

      {:ok,
       socket
       |> assign(page_title: "Contatos", loading: true, count: nil)
       |> assign_new(:companies, fn -> Companies.list_companies_for_user(scope.user) end)
       |> stream(:contacts, [])
       |> load_contacts()}
    else
      {:ok,
       socket
       |> put_flash(:error, "Você não tem permissão para ver contatos.")
       |> push_navigate(to: ~p"/painel")}
    end
  end

  @impl true
  def handle_params(params, _uri, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  defp apply_action(socket, :index, _params), do: assign(socket, form: nil)

  defp apply_action(socket, :new, _params) do
    scope = socket.assigns.current_scope

    if PermitEx.can?(scope, "contacts:create") do
      assign_form(socket, scope, %Contact{company_id: scope.company.id, stage: :lead})
    else
      deny(socket)
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    scope = socket.assigns.current_scope

    if PermitEx.can?(scope, "contacts:update") do
      assign_form(socket, scope, Contacts.get_contact!(scope, id))
    else
      deny(socket)
    end
  end

  defp deny(socket) do
    socket
    |> put_flash(:error, "Você não tem permissão para isso.")
    |> push_patch(to: ~p"/contatos")
    |> assign(form: nil)
  end

  defp assign_form(socket, scope, contact) do
    assign(socket, contact: contact, form: to_form(Contacts.change_contact(scope, contact)))
  end

  @impl true
  def handle_event("close_modal", _params, socket),
    do: {:noreply, push_patch(socket, to: ~p"/contatos")}

  def handle_event("validate", %{"contact" => params}, socket) do
    changeset =
      Contacts.change_contact(socket.assigns.current_scope, socket.assigns.contact, params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contact" => params}, socket),
    do: save(socket, socket.assigns.live_action, params)

  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    contact = Contacts.get_contact!(scope, id)

    case Contacts.delete_contact(scope, contact) do
      {:ok, _} ->
        {:noreply, put_toast(socket, "Contato excluído.", color: "success")}

      {:error, :unauthorized} ->
        {:noreply, put_flash(socket, :error, "Você não tem permissão para excluir.")}
    end
  end

  defp save(socket, :new, params) do
    case Contacts.create_contact(socket.assigns.current_scope, params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Contato criado.")
         |> push_patch(to: ~p"/contatos")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, :unauthorized} ->
        {:noreply, deny(socket)}
    end
  end

  defp save(socket, :edit, params) do
    case Contacts.update_contact(socket.assigns.current_scope, socket.assigns.contact, params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Contato atualizado.")
         |> push_patch(to: ~p"/contatos")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

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

  defp description(nil, company), do: "Contatos do workspace #{company.name}."

  defp description(count, company),
    do: "#{count} #{if count == 1, do: "contato", else: "contatos"} no workspace #{company.name}."

  defp format_date(dt), do: Calendar.strftime(dt, "%d/%m/%Y")
end
