# Demo data: the "Orbit Cloud" workspace (orbit.<base_host>) with 5 members (Dono, Admin, 2x Vendas, Leitura) and ~25 contacts.
#
#     mix run priv/repo/seeds.exs
#
# The demo password comes from DEMO_PASSWORD (dev fallback below; never use it in production).

alias LedgerStarter.{Accounts, Companies, Contacts, Permissions, Repo}
alias LedgerStarter.Accounts.Scope

password = System.get_env("DEMO_PASSWORD") || "demo-password-2026"

# Roles/permissions catalog (also done on demand when a company is created).
Permissions.seed_templates!()

ensure_user = fn email, name ->
  user =
    case Accounts.get_user_by_email(email) do
      nil ->
        {:ok, user} =
          Accounts.register_user(%{name: name, email: email, password: password, terms: true})

        user

      user ->
        user
    end

  user
  |> Ecto.Changeset.change(
    confirmed_at: user.confirmed_at || DateTime.utc_now(:second),
    name: user.name || name
  )
  |> Repo.update!()
end

demo = ensure_user.("demo@ledger.devaction.com.br", "Alex Demo")
marina = ensure_user.("marina@ledger.devaction.com.br", "Marina Costa")
rafael = ensure_user.("rafael@ledger.devaction.com.br", "Rafael Lima")
paula = ensure_user.("paula@ledger.devaction.com.br", "Paula Reis")
davi = ensure_user.("davi@ledger.devaction.com.br", "Davi Rocha")

company =
  Companies.get_company_by_subdomain("orbit") ||
    (fn ->
       {:ok, company} = Companies.create_company(demo, %{name: "Orbit Cloud", subdomain: "orbit"})
       company
     end).()

{:ok, _} = Companies.add_member(company, marina, "admin")
{:ok, _} = Companies.add_member(company, rafael, "sales")
{:ok, _} = Companies.add_member(company, paula, "sales")
{:ok, _} = Companies.add_member(company, davi, "viewer")

scope = demo |> Scope.for_user() |> Scope.put_company(company)

if Contacts.list_contacts(scope) == [] do
  people = [
    {"Joana Prado", "Bompreço Atacado", :customer},
    {"Caio Mendes", "Lumen Studio", :qualified},
    {"Beatriz Lopes", "Rede Farol", :lead},
    {"Davi Rocha", "Vértice Engenharia", :lead},
    {"Helena Souza", "Orbit Cloud", :customer},
    {"Tiago Barros", "Nimbus Logística", :qualified},
    {"Luiza Ferraz", "Aurora Saúde", :lead},
    {"Pedro Alves", "Bompreço Atacado", :customer},
    {"Camila Nunes", "Lumen Studio", :lead},
    {"Rodrigo Pires", "Rede Farol", :qualified},
    {"Fernanda Dias", "Vértice Engenharia", :customer},
    {"Gustavo Melo", "Nimbus Logística", :lead},
    {"Isabela Cruz", "Aurora Saúde", :qualified},
    {"Marcelo Tavares", "Atlas Tecnologia", :lead},
    {"Patrícia Gomes", "Atlas Tecnologia", :customer},
    {"Vinícius Rangel", "Pixel Mídia", :lead},
    {"Larissa Moura", "Pixel Mídia", :qualified},
    {"Eduardo Braga", "Costa Verde Hotéis", :lead},
    {"Renata Siqueira", "Costa Verde Hotéis", :customer},
    {"Felipe Antunes", "Orla Seguros", :qualified},
    {"Aline Couto", "Orla Seguros", :lead},
    {"Bruno Teixeira", "Serra Alimentos", :customer},
    {"Mariana Vidal", "Serra Alimentos", :lead},
    {"Henrique Lacerda", "Delta Engenharia", :qualified},
    {"Sabrina Oliveira", "Delta Engenharia", :lead}
  ]

  owners = [demo, marina, rafael]

  people
  |> Enum.with_index()
  |> Enum.each(fn {{name, org, stage}, i} ->
    first =
      name
      |> String.split(" ")
      |> hd()
      |> String.downcase()
      |> :unicode.characters_to_nfd_binary()
      |> String.replace(~r/[^a-z]/, "")

    domain =
      org
      |> String.downcase()
      |> :unicode.characters_to_nfd_binary()
      |> String.replace(~r/[^a-z]/, "")

    {:ok, contact} =
      Contacts.create_contact(scope, %{
        name: name,
        email: "#{first}@#{domain}.com.br",
        phone:
          "(75) 9#{String.pad_leading("#{9_000 + i * 37}", 4, "0")}-#{String.pad_leading("#{1_000 + i * 113}", 4, "0")}",
        company_name: org,
        stage: stage
      })

    contact |> Ecto.Changeset.change(owner_id: Enum.at(owners, rem(i, 3)).id) |> Repo.update!()
  end)
end

IO.puts("Seeded Orbit Cloud: #{Companies.count_members(company)} members.")
