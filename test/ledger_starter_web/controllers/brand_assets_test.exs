defmodule LedgerStarterWeb.BrandAssetsTest do
  use LedgerStarterWeb.ConnCase, async: true

  test "serves the favicon and the web manifest", %{conn: conn} do
    svg = get(conn, "/favicon.svg")
    assert response(svg, 200) =~ "<svg"
    assert [ctype] = get_resp_header(svg, "content-type")
    assert ctype =~ "image/svg+xml"

    manifest = get(conn, "/site.webmanifest")
    assert %{"name" => "StartKit", "icons" => [_ | _]} = Jason.decode!(response(manifest, 200))

    assert get(conn, "/favicon.ico").status == 200
    assert get(conn, "/apple-touch-icon.png").status == 200
    assert get(conn, "/images/mark.svg").status == 200
  end

  test "root layout links the icons", %{conn: conn} do
    html = conn |> get("/") |> html_response(200)
    assert html =~ ~s(href="/favicon.svg")
    assert html =~ ~s(rel="manifest")
    assert html =~ "/images/mark.svg"
  end
end
