# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ledger_starter, :scopes,
  user: [
    default: true,
    module: LedgerStarter.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :binary_id,
    schema_table: :users,
    test_data_fixture: LedgerStarter.AccountsFixtures,
    test_setup_helper: :register_and_log_in_user
  ],
  company: [
    module: LedgerStarter.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:company, :id],
    route_prefix: "/",
    schema_key: :company_id,
    schema_type: :binary_id,
    schema_table: :companies,
    test_data_fixture: LedgerStarter.CompaniesFixtures,
    test_setup_helper: :register_and_log_in_user_with_company
  ]

config :permit_ex, repo: LedgerStarter.Repo, cache: false

config :ledger_starter, :google_oauth, client_id: nil, client_secret: nil

config :ledger_starter,
  base_host: "lvh.me",
  session_cookie_domain: ".lvh.me",
  seats_limit: 10,
  mail_from: {"StartKit", "no-reply@ledger.devaction.com.br"},
  ecto_repos: [LedgerStarter.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure the endpoint
config :ledger_starter, LedgerStarterWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LedgerStarterWeb.ErrorHTML, json: LedgerStarterWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LedgerStarter.PubSub,
  live_view: [signing_salt: "jKKhxF6k"]

# Configure LiveView
config :phoenix_live_view,
  # the attribute set on all root tags. Used for Phoenix.LiveView.ColocatedCSS.
  root_tag_attribute: "phx-r"

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ledger_starter, LedgerStarter.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  ledger_starter: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.3.3",
  ledger_starter: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
