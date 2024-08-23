defmodule FortymmWeb.PageControllerTest do
  use FortymmWeb.ConnCase

  import Fortymm.AccountsFixtures

  describe "GET /" do
    test "shows the heading", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
    end

    test "redirects to the dashboard when a user is logged in", %{conn: conn} do
      assert conn
             |> log_in_user(user_fixture())
             |> get(~p"/")
             |> redirected_to(302) =~ "/dashboard"
    end
  end
end
