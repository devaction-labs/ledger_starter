defmodule LedgerStarter.Auth.GoogleStub do
  @moduledoc """
  Test double for `LedgerStarter.Auth.Google` (Assent mocked): the callback
  result is read from `:persistent_term` so tests choose the claims.
  """
  @behaviour LedgerStarter.Auth.Google

  def set_claims(claims), do: :persistent_term.put({__MODULE__, :claims}, claims)

  @impl true
  def authorize_url(redirect_uri) do
    {:ok,
     %{
       url: "https://accounts.google.test/auth?redirect_uri=#{URI.encode_www_form(redirect_uri)}",
       session_params: %{state: "state-123"}
     }}
  end

  @impl true
  def callback(_redirect_uri, %{"error" => _}, _session_params), do: {:error, :access_denied}

  def callback(_redirect_uri, _params, %{state: "state-123"}),
    do: {:ok, :persistent_term.get({__MODULE__, :claims})}

  def callback(_, _, _), do: {:error, :invalid_state}
end
