defmodule LedgerStarterWeb.TeamComponents do
  @moduledoc "Pieces shared by the Equipe and Papéis e permissões pages."
  use LedgerStarterWeb, :html

  attr :current, :atom, required: true, values: [:team, :roles]
  attr :count, :integer, default: nil, doc: "people in the workspace (badge of the Equipe tab)"

  @doc "The Equipe / Papéis e permissões tabs under the page header."
  def team_tabs(assigns) do
    ~H"""
    <div class="px-7 pb-5">
      <.tabs id="team-tabs" variant="classic" selected={to_string(@current)}>
        <:tab name="team" navigate={~p"/equipe"} count={@count}>Equipe</:tab>
        <:tab name="roles" navigate={~p"/equipe/papeis"}>Papéis e permissões</:tab>
      </.tabs>
    </div>
    """
  end
end
