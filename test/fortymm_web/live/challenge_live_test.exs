defmodule FortymmWeb.ChallengeLiveTest do
  use FortymmWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Fortymm.AccountsFixtures

  test "renders challenge title when a user is logged in", %{conn: conn} do
    {:ok, _lv, html} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/challenges/asdf")

    assert html =~ "challenge"
  end
end
