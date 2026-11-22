defmodule LedgerStarterWeb.PageHTML do
  use LedgerStarterWeb, :html

  attr :flash, :map, default: %{}
  attr :title, :string, required: true
  slot :inner_block, required: true
  def legal(assigns)

  embed_templates "page_html/*"

  defp features do
    [
      %{
        icon: "lock",
        title: "Auth completa",
        text: "Google OAuth, e-mail e senha e link mágico. Sessão compartilhada entre workspaces."
      },
      %{
        icon: "building",
        title: "Multiempresa",
        text: "Cada empresa é um tenant: dados isolados, subdomínio próprio e troca rápida."
      },
      %{
        icon: "users",
        title: "Time e papéis",
        text: "Convites por e-mail, papéis Dono, Admin e Membro com permissões por empresa."
      },
      %{
        icon: "kanban",
        title: "Funil de vendas",
        text: "Contatos com etapas Lead, Qualificado e Cliente."
      },
      %{
        icon: "card",
        title: "Limite por assento",
        text: "Assentos por workspace, prontos para ligar ao seu gateway de cobrança."
      },
      %{
        icon: "sparkles",
        title: "Ledger UI",
        text: "140 componentes HEEx em Tailwind, tema claro e escuro e paletas."
      }
    ]
  end

  defp plans do
    [
      %{
        name: "Starter",
        price: "R$ 0",
        note: "Para testar com o time",
        items: ["1 workspace", "3 assentos", "Contatos e funil"],
        cta: "Escolher"
      },
      %{
        name: "Pro",
        badge: "Mais escolhido",
        price: "R$ 49",
        note: "por assento / mês",
        items: ["Workspaces ilimitados", "Google OAuth e SSO", "Automações e relatórios"],
        cta: "Começar teste"
      },
      %{
        name: "Business",
        price: "R$ 89",
        note: "por assento / mês",
        items: ["Domínio próprio", "Auditoria e logs", "Suporte dedicado"],
        cta: "Escolher"
      }
    ]
  end
end
