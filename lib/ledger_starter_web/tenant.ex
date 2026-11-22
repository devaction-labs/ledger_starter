defmodule LedgerStarterWeb.Tenant do
  @moduledoc """
  Host helpers. The tenant is the subdomain of `config :ledger_starter, :base_host`.
  The base host (and `www.`) serves landing + auth; `<tenant>.<base_host>` serves the app.
  """

  alias LedgerStarter.Companies.Company

  def base_host, do: Application.fetch_env!(:ledger_starter, :base_host)

  def cookie_domain, do: Application.get_env(:ledger_starter, :session_cookie_domain)

  @doc """
  The cookie domain to use for `host`: only when the host is the base host or one
  of its subdomains (a browser rejects a cookie whose domain does not match, e.g.
  `localhost` while the base host is `lvh.me`).
  """
  def cookie_domain_for(host) do
    with domain when is_binary(domain) <- cookie_domain(),
         bare = String.trim_leading(domain, "."),
         true <- host == bare or String.ends_with?(host, "." <> bare) do
      domain
    else
      _ -> nil
    end
  end

  @doc "`:root` for the base host (or www), `{:tenant, subdomain}` for one label below it."
  def classify(host) when is_binary(host) do
    base = base_host()
    host = String.downcase(host)

    cond do
      host == base or host == "www." <> base ->
        :root

      String.ends_with?(host, "." <> base) ->
        sub = String.replace_suffix(host, "." <> base, "")
        if String.contains?(sub, "."), do: :unknown, else: {:tenant, sub}

      true ->
        # Unknown host (health checks by IP, localhost): behave as the root host.
        :root
    end
  end

  @doc "Absolute URL on the root host."
  def root_url(path \\ "/"), do: build(base_host(), path)

  @doc "Absolute URL on a company's subdomain."
  def company_url(%Company{subdomain: sub}, path \\ "/"), do: build("#{sub}.#{base_host()}", path)

  def company_host(%Company{subdomain: sub}), do: "#{sub}.#{base_host()}"

  defp build(host, path) do
    uri = LedgerStarterWeb.Endpoint.struct_url()
    port = if uri.port in [80, 443], do: nil, else: uri.port

    URI.to_string(%URI{
      scheme: uri.scheme,
      host: host,
      port: port,
      path: path |> URI.parse() |> Map.get(:path),
      query: URI.parse(path).query
    })
  end

  @doc "True when `url` is an http(s) URL under the base host (safe redirect target)."
  def trusted_url?(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host, scheme: scheme} when scheme in ["http", "https"] and is_binary(host) ->
        host == base_host() or String.ends_with?(host, "." <> base_host())

      _ ->
        false
    end
  end

  def trusted_url?(_), do: false
end
