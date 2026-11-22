defmodule LedgerStarter.Auth.Google do
  @moduledoc """
  Google OAuth (OpenID Connect) through Assent, behind a project-owned API.

  Configured by `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`
  (`config :ledger_starter, :google_oauth`). Without them `enabled?/0` is false
  and the "Google" buttons are hidden. Tests swap the adapter with
  `config :ledger_starter, :google_adapter, MyStub`.
  """

  @callback authorize_url(redirect_uri :: String.t()) ::
              {:ok, %{url: String.t(), session_params: map()}} | {:error, term()}
  @callback callback(redirect_uri :: String.t(), params :: map(), session_params :: map()) ::
              {:ok, %{String.t() => term()}} | {:error, term()}

  @behaviour __MODULE__

  def enabled? do
    config = Application.get_env(:ledger_starter, :google_oauth, [])
    present?(config[:client_id]) and present?(config[:client_secret])
  end

  defp present?(v), do: is_binary(v) and v != ""

  defp adapter, do: Application.get_env(:ledger_starter, :google_adapter, __MODULE__)

  def authorize_url(redirect_uri), do: adapter_call(:authorize_url, [redirect_uri])

  def callback(redirect_uri, params, session_params),
    do: adapter_call(:callback, [redirect_uri, params, session_params])

  defp adapter_call(fun, args) do
    case adapter() do
      __MODULE__ -> apply(__MODULE__.AssentClient, fun, args)
      mod -> apply(mod, fun, args)
    end
  end

  defmodule AssentClient do
    @moduledoc false
    alias Assent.Strategy.Google, as: GoogleStrategy

    def authorize_url(redirect_uri) do
      with {:ok, %{url: url, session_params: sp}} <-
             GoogleStrategy.authorize_url(config(redirect_uri)) do
        {:ok, %{url: url, session_params: sp}}
      end
    end

    def callback(redirect_uri, params, session_params) do
      config = Keyword.put(config(redirect_uri), :session_params, session_params)

      case GoogleStrategy.callback(config, params) do
        {:ok, %{user: claims}} -> {:ok, claims}
        {:error, error} -> {:error, error}
      end
    end

    defp config(redirect_uri) do
      oauth = Application.get_env(:ledger_starter, :google_oauth, [])

      [
        client_id: oauth[:client_id],
        client_secret: oauth[:client_secret],
        redirect_uri: redirect_uri,
        http_adapter: Assent.HTTPAdapter.Req
      ]
    end
  end
end
