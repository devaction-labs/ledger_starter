defmodule LedgerStarterWeb.CompanyLive.New do
  @moduledoc "Create the tenant: name + subdomain with a live availability check."
  use LedgerStarterWeb, :live_view

  import LedgerStarterWeb.AuthComponents

  alias LedgerStarter.Companies
  alias LedgerStarter.Companies.Company
  alias LedgerStarterWeb.Tenant

  @impl true
  def render(assigns) do
    ~H"""
    <.auth_screen flash={@flash} id="company" footer_right={gettext("Ajuda")}>
      <:chip
        icon="globe"
        title={@host_preview}
        subtitle={gettext("endereço do seu workspace")}
        top="64px"
        left="56px"
      />
      <:chip
        icon="shield"
        title={gettext("Dados isolados")}
        subtitle={gettext("por empresa")}
        top="150px"
        right="48px"
      />

      <.stepper current={1}>
        <:step label={gettext("Conta")} />
        <:step label={gettext("Empresa")} />
        <:step label={gettext("Convites")} />
      </.stepper>
      <h1>{gettext("Sua empresa")}</h1>
      <p class="sub">
        {gettext("Cada empresa é um workspace separado: dados, time e permissões próprios.")}
      </p>

      <.form
        for={@form}
        id="company_form"
        phx-change="validate"
        phx-submit="save"
        class="flex flex-col gap-4"
      >
        <.input
          field={@form[:name]}
          label={gettext("Nome da empresa")}
          placeholder="Orbit Cloud"
          autocomplete="organization"
          required
          phx-debounce="200"
          phx-mounted={JS.focus()}
        />
        <.input
          field={@form[:subdomain]}
          label={gettext("Endereço do workspace")}
          placeholder="orbit"
          suffix={"." <> @base_host}
          autocomplete="off"
          spellcheck="false"
          state={@state}
          help={@help}
          required
          phx-debounce="200"
        />
        <.auth_submit>{gettext("Criar workspace")}</.auth_submit>
      </.form>
    </.auth_screen>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: gettext("Criar empresa"),
       base_host: Tenant.base_host(),
       subdomain_touched: false
     )
     |> assign_form(Companies.change_company(%Company{}, %{}, validate_unique: false))
     |> assign_availability("")}
  end

  @impl true
  def handle_event("validate", %{"company" => params} = all, socket) do
    touched = socket.assigns.subdomain_touched or all["_target"] == ["company", "subdomain"]

    params =
      if touched,
        do: params,
        else: Map.put(params, "subdomain", slugify(params["name"] || ""))

    changeset =
      %Company{}
      |> Companies.change_company(params, validate_unique: false)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(subdomain_touched: touched)
     |> assign_form(changeset)
     |> assign_availability(params["subdomain"] || "")}
  end

  def handle_event("save", %{"company" => params}, socket) do
    case Companies.create_company(socket.assigns.current_scope.user, params) do
      {:ok, company} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Workspace %{name} criado!", name: company.name))
         |> redirect(external: Tenant.company_url(company, "/painel"))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign_form(changeset)
         |> assign_availability(params["subdomain"] || "")}
    end
  end

  defp assign_form(socket, changeset),
    do: assign(socket, form: translated_form(changeset, as: "company"))

  defp assign_availability(socket, subdomain) do
    host =
      "#{if subdomain == "", do: gettext("seu-endereco"), else: subdomain}.#{Tenant.base_host()}"

    {state, help} =
      case subdomain do
        "" ->
          {nil, gettext("Seu time entra por %{host}", host: host)}

        sub ->
          case Companies.subdomain_status(sub) do
            :available ->
              {"success", gettext("Disponível: seu time entra por %{host}", host: host)}

            :taken ->
              {"error", gettext("Este endereço já está em uso.")}

            {:invalid, msg} ->
              {"error", translate_error({msg, []})}
          end
      end

    assign(socket, state: state, help: help, host_preview: host)
  end

  @doc "`\"Orbit Cloud!\"` becomes `\"orbit-cloud\"`."
  def slugify(name) do
    name
    |> String.normalize(:nfd)
    |> String.replace(~r/[^\x00-\x7F]/u, "")
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
    |> String.slice(0, 30)
    |> String.trim("-")
  end
end
