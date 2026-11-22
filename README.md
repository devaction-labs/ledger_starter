# StartKit (Ledger UI)

CRM multiempresa pronto para virar o seu SaaS: Phoenix 1.8 + LiveView + [Ledger UI](https://hex.pm/packages/ledger_ui)
(`~> 0.6.0`), Postgres, autenticação completa, tenants por subdomínio, papéis e permissões por empresa
([PermitEx](https://github.com/devaction-labs/permit_ex)), convites por e-mail e deploy por imagem (GHCR + Openship).

## O que vem pronto

- **Auth** (`mix phx.gen.auth`): cadastro com nome, e-mail, senha (medidor de força) e aceite dos termos; login com senha;
  link mágico (15 minutos, uso único); **Google OAuth** via [Assent](https://hex.pm/packages/assent).
- **Multiempresa**: `Company` (subdomínio único), `Membership`, `Invitation`. O tenant vem do subdomínio do host
  (`orbit.starter.ledger.devaction.com.br`). O host raiz serve landing, auth, "Criar empresa" e "Escolher workspace".
  O cookie de sessão é compartilhado entre subdomínios (`domain: ".<BASE_HOST>"`).
- **Scopes do Phoenix 1.8**: `LedgerStarter.Accounts.Scope` carrega `user`, `company` e os papéis/permissões do usuário
  na empresa. Todo contexto tenant (`Contacts`, `Companies`) recebe o `scope` e filtra por `company_id`
  (gerado com `mix phx.gen.live ... --scope company`).
- **Papéis e permissões** (PermitEx, contexto = id da empresa): papéis `owner` (Dono), `admin`, `sales` (Vendas) e
  `viewer` (Leitura), mais papéis personalizados por empresa. As permissões seguem a matriz do StartKit, em grupos
  (`contacts`, `deals`, `tasks`, `reports`, `data`, `team`, `billing`, `company`) com as ações `read|write|delete`
  (`contacts:write` = criar e editar; `company:delete` = excluir o workspace) e o escopo `recurso:team|all` (sem nenhum
  dos dois = "só os seus"; o escopo é gravado e exibido, ainda não filtra dados). Os templates são semeados e clonados
  **uma vez** para cada empresa criada; depois cada empresa é dona dos seus papéis. `owner` e `admin` são `locked`
  (PermitEx) e o resto edita em **Equipe → Papéis e permissões** (`team:write`; ninguém libera o que o próprio papel não
  tem). Sem a permissão de uma página, o usuário cai na página 403 `/sem-permissao` (via `on_mount`).
- **CRM**: contatos (lead / qualificado / cliente) com lista, modal "Novo contato", edição e exclusão; equipe com membros,
  convites pendentes, gaveta "Convidar pessoas", limite de assentos, matriz "Papéis e permissões" e gaveta "Editar papel".
- **E-mail**: Swoosh; `Local` em dev (caixa em `/dev/mailbox`) e Resend em produção. Textos em pt-BR.
- **Health**: `/health/live` e `/health/ready`.

## Rodando localmente

Requisitos: Elixir 1.20 / OTP 29, Postgres local.

O desenvolvimento usa `lvh.me`: `*.lvh.me` resolve para `127.0.0.1`, então `orbit.lvh.me` funciona sem editar o `/etc/hosts`.

```sh
mix setup                       # deps, banco, migrations, seeds e assets
PORT=4740 mix phx.server        # a porta é livre; o padrão é 4000
```

Abra `http://lvh.me:4740` (host raiz). Depois de criar uma empresa você cai em `http://<subdominio>.lvh.me:4740/painel`.
O e-mail de convite e o link mágico aparecem em `http://lvh.me:4740/dev/mailbox`.

### Dados de demonstração

`mix run priv/repo/seeds.exs` cria a empresa **Orbit Cloud** (`orbit.lvh.me`) com 5 membros
(`demo@ledger.devaction.com.br` dono, `marina@...` admin, `rafael@...` membro) e 25 contatos.
A senha dos três vem de `DEMO_PASSWORD` (há um valor padrão só para dev em `priv/repo/seeds.exs`).
Em produção defina `DEMO_PASSWORD` antes de rodar `LedgerStarter.Release.seed_demo/0`, ou não rode a seed.

### Google OAuth em dev

Sem `GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET` o botão do Google fica oculto. Para testar:

```sh
export GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=...
```

A URL de retorno é `<host raiz>/auth/google/callback`. O Google só aceita `http` para `localhost`; cadastre
`http://localhost:4000/auth/google/callback` e rode com `PORT=4000` acessando por `http://localhost:4000` (nesse host não há
subdomínios: o cookie compartilhado vale só para `lvh.me`). Em produção cadastre
`https://<BASE_HOST>/auth/google/callback`.

### Testes

```sh
mix test
```

## Variáveis de ambiente (produção)

| Variável | Obrigatória | Descrição |
|---|---|---|
| `DATABASE_URL` | sim | `ecto://USER:PASS@HOST/DB` |
| `SECRET_KEY_BASE` | sim | `mix phx.gen.secret` |
| `PHX_HOST` | sim | host público da aplicação (padrão `starter.ledger.devaction.com.br`) |
| `BASE_HOST` | não | domínio base dos tenants; padrão = `PHX_HOST`. Tenants: `<sub>.<BASE_HOST>`; cookie: `.<BASE_HOST>` |
| `PORT` | não | porta HTTP (padrão `4000`) |
| `RESEND_API_KEY` | sim | chave da Resend (adapter `Swoosh.Adapters.Resend`) |
| `MAIL_FROM` | não | remetente, `Nome <email>` (padrão `StartKit <no-reply@ledger.devaction.com.br>`) |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | não | habilitam o login com Google |
| `DEMO_PASSWORD` | não | senha da seed demo (`LedgerStarter.Release.seed_demo/0`) |
| `POOL_SIZE` | não | conexões do pool (padrão `10`) |
| `SKIP_MIGRATIONS` | não | `1` pula as migrations no start |

DNS: aponte `BASE_HOST` **e** `*.BASE_HOST` (wildcard) para a aplicação e emita certificado wildcard.

## Deploy

- `Dockerfile`: release do Phoenix (`EXPOSE 4000`); `rel/entrypoint.sh` roda `LedgerStarter.Release.migrate/0` e inicia o servidor.
- `.github/workflows/main.yml`: testes (Postgres como service) em PR/push; em `main` constrói e publica
  `ghcr.io/devaction-labs/ledger_starter:sha-<sha>` e faz o deploy no Openship
  (`.github/scripts/openship-deploy.sh`). Em `release/**` ou `workflow_dispatch` com `build_image` só publica a imagem.
  `workflow_dispatch` com `deploy_version` faz rollback para uma tag existente.
- Secrets do GitHub (nível do repositório): `OPENSHIP_CLOUD_API_URL`, `OPENSHIP_CLOUD_API_TOKEN`,
  `OPENSHIP_CLOUD_PROJECT_ID`, `SECRET_KEY_BASE`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`,
  `RESEND_API_KEY`, `DEMO_PASSWORD`. Variáveis opcionais do repositório (`vars`): `PHX_HOST`, `BASE_HOST`,
  `MAIL_FROM`, `POOL_SIZE` (valores vazios são ignorados). `DATABASE_URL` não é sincronizado: o Openship injeta pela conexão do banco.
- **Sync secrets** (`.github/workflows/sync-secrets.yml`): copia esses secrets/variáveis para o ambiente do Openship
  (`.github/scripts/openship-sync-secrets.sh`) e redeploya `sha-<sha da main>`. Rode em Actions > Sync secrets > Run workflow
  (opcionalmente informando `image_version`) ou mergeie um PR com o label `deploy-secrets`. Se algum dos quatro secrets
  obrigatórios estiver vazio, nada é enviado.

## Estrutura

```
lib/ledger_starter/
  accounts/        User, Scope (user + company + permissões), notificações
  auth/google.ex   Google OAuth (Assent) atrás de uma API própria
  companies/       Company, Membership, Invitation, InvitationNotifier
  contacts/        Contact (escopado por company_id)
  permissions.ex   catálogo de papéis/permissões (PermitEx)
lib/ledger_starter_web/
  tenant.ex        host -> raiz | tenant, URLs, domínio do cookie
  plugs/           Session (cookie por subdomínio), Tenant (carrega empresa, exige membro)
  live/            auth, empresa, workspaces, dashboard, contatos, equipe
```

### Rotas

Host raiz: `/`, `/users/register`, `/users/log-in`, `/users/log-in/link`, `/users/log-in/:token`, `/users/settings`,
`/auth/google`, `/auth/google/callback`, `/convites/:token`, `/empresas/nova`, `/workspaces`.
Host do tenant: `/painel`, `/contatos` (`/novo`, `/:id/editar`), `/equipe` (`/convidar`), `/equipe/papeis` (`/novo`, `/:papel/editar`), `/sem-permissao`.
Qualquer host: `/health/live`, `/health/ready`.

## Notas

- Permissões do PermitEx precisam seguir `recurso:acao`, e **um nome com exatamente 16 bytes é lido como UUID**
  (por isso `company:delete` e não `company:destroy`/`workspace:delete`, que têm 16 bytes). Papéis do PermitEx são
  *slugs* e não têm rótulo: o nome exibido ("Vendas") fica em `description`.
- Migração dos dados: `member` virou `sales` (Vendas) no próprio registro do PermitEx, então ninguém perde o papel;
  convites pendentes de `member` viram `sales`; os templates são re-clonados e as permissões antigas
  (`contacts:create|update`, `team:invite|manage`, `company:manage`) são removidas. O Admin agora tem `team:write`.
- Um usuário que se cadastrou com senha e nunca confirmou o e-mail perde a senha ao entrar por link mágico ou Google
  (o link prova a posse do e-mail; evita *pre-hijacking*). Ele pode definir outra em `/users/settings`.
