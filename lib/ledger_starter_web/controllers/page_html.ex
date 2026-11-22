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
        title: gettext("Auth completa"),
        text:
          gettext(
            "Google OAuth, e-mail e senha e link mágico. Sessão compartilhada entre workspaces."
          )
      },
      %{
        icon: "building",
        title: gettext("Multiempresa"),
        text:
          gettext("Cada empresa é um tenant: dados isolados, subdomínio próprio e troca rápida.")
      },
      %{
        icon: "users",
        title: gettext("Time e papéis"),
        text:
          gettext("Convites por e-mail, papéis Dono, Admin e Membro com permissões por empresa.")
      },
      %{
        icon: "kanban",
        title: gettext("Funil de vendas"),
        text: gettext("Contatos com etapas Lead, Qualificado e Cliente.")
      },
      %{
        icon: "card",
        title: gettext("Limite por assento"),
        text: gettext("Assentos por workspace, prontos para ligar ao seu gateway de cobrança.")
      },
      %{
        icon: "sparkles",
        title: gettext("Ledger UI"),
        text: gettext("140 componentes HEEx em Tailwind, tema claro e escuro e paletas.")
      }
    ]
  end

  defp plans do
    [
      %{
        name: "Starter",
        price: "R$ 0",
        note: gettext("Para testar com o time"),
        items: [gettext("1 workspace"), gettext("3 assentos"), gettext("Contatos e funil")],
        cta: gettext("Escolher")
      },
      %{
        name: "Pro",
        badge: gettext("Mais escolhido"),
        price: "R$ 49",
        note: gettext("por assento / mês"),
        items: [
          gettext("Workspaces ilimitados"),
          gettext("Google OAuth e SSO"),
          gettext("Automações e relatórios")
        ],
        cta: gettext("Começar teste")
      },
      %{
        name: "Business",
        price: "R$ 89",
        note: gettext("por assento / mês"),
        items: [
          gettext("Domínio próprio"),
          gettext("Auditoria e logs"),
          gettext("Suporte dedicado")
        ],
        cta: gettext("Escolher")
      }
    ]
  end
end
