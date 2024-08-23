defmodule FortymmWeb.DashboardLiveTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.AccountsFixtures

  test "renders dashboard", %{conn: conn} do
    {:ok, _lv, html} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/dashboard")

    assert html =~ "Dashboard"
  end

  test "redirects to the log in page if nobody is logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, ~p"/dashboard")
  end
end
