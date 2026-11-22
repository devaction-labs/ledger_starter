defmodule LedgerStarterWeb.ForbiddenLive do
  @moduledoc """
  The "Sem permissão" page (403): where `UserAuth`'s `:require_permission`
  sends someone whose role lacks the permission of a page. It names the page,
  the user's role and who can release access (owners and admins).
  """
  use LedgerStarterWeb, :live_view

  alias LedgerStarter.Companies
  alias LedgerStarterWeb.Layouts

  # slug => {title, "a"/"à"... phrase}
  @pages %{
    "equipe" => {"Equipe", "à Equipe"},
    "papeis" => {"Papéis e permissões", "aos Papéis e permissões"},
    "contatos" => {"Contatos", "aos Contatos"}
  }

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      companies={@companies}
      current={~p"/painel"}
      crumb={@page_name}
    >
      <.page_header title={@page_name} description={@description} />
      <div class="px-7 pb-8">
        <.error_state
          id="forbidden"
          code={403}
          title={"Você não tem acesso #{@page_phrase}"}
          description={description(@role_label)}
        >
          <:actions>
            <.button id="back-to-dashboard" navigate={~p"/painel"} icon="home">
              Voltar ao painel
            </.button>
          </:actions>
          <:more :if={@granters != []}>
            <div
              id="granters"
              class="mx-auto flex max-w-[420px] flex-col gap-2 text-left text-[13px] text-muted"
            >
              <span class="text-center font-medium text-ink">Quem pode liberar</span>
              <span :for={g <- @granters} class="flex items-center gap-2.5">
                <.avatar initials={Layouts.initials(g.user.name || g.user.email)} size="28" />
                <span class="font-medium text-ink">{g.user.name || g.user.email}</span>
                <.badge color={if g.role_label == "Dono", do: "primary", else: "neutral"}>
                  {g.role_label}
                </.badge>
              </span>
            </div>
          </:more>
        </.error_state>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    scope = socket.assigns.current_scope
    {name, phrase} = Map.get(@pages, params["pagina"], {"Sem permissão", "a esta página"})

    {:ok,
     socket
     |> assign(
       page_title: "Sem permissão",
       page_name: name,
       page_phrase: phrase,
       description: "Você está no workspace #{scope.company.name}.",
       role_label:
         scope.roles |> List.first() |> then(&(&1 && LedgerStarter.Permissions.label(&1))),
       granters: Companies.list_access_granters(scope.company)
     )
     |> assign_new(:companies, fn -> Companies.list_companies_for_user(scope.user) end)}
  end

  defp description(nil), do: "Peça a um Admin ou ao dono do workspace para liberar."

  defp description(role),
    do: "Seu papel é #{role}. Peça a um Admin ou ao dono do workspace para liberar."
end
