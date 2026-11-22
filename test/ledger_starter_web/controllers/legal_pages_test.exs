defmodule LedgerStarterWeb.LegalPagesTest do
  use LedgerStarterWeb.ConnCase, async: true

  test "GET /privacidade is public and describes the data used", %{conn: conn} do
    html = conn |> get(~p"/privacidade") |> html_response(200)

    assert html =~ "Política de Privacidade"
    assert html =~ "alex@devaction.com.br"
    assert html =~ "foto do seu perfil"
  end

  test "GET /termos is public", %{conn: conn} do
    html = conn |> get(~p"/termos") |> html_response(200)

    assert html =~ "Termos de Serviço"
    assert html =~ ~p"/privacidade"
  end

  test "tenant hosts redirect to the root host", %{conn: conn} do
    conn = %{conn | host: "orbit.example.com"} |> get(~p"/termos")
    assert redirected_to(conn) == "http://example.com/termos"
  end

  test "landing, register and login link to both pages", %{conn: conn} do
    for path <- [~p"/", ~p"/users/register", ~p"/users/log-in"] do
      html = conn |> get(path) |> html_response(200)

      assert html =~ ~s(href="/privacidade")
      assert html =~ ~s(href="/termos")
    end
  end
end
