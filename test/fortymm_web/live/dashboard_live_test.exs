defmodule FortymmWeb.DashboardLiveTest do
  use FortymmWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Fortymm.AccountsFixtures
  import Fortymm.ChallengesFixtures

  alias Fortymm.Matches

  test "renders dashboard", %{conn: conn} do
    {:ok, _lv, html} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/dashboard")

    assert html =~ "Challenge A Friend"
  end

  test "shows the user's matches", %{conn: conn} do
    user_one = user_fixture()
    user_two = user_fixture()

    challenge = challenge_fixture(%{created_by_id: user_one.id})
    {:ok, _match} = Matches.create_match(challenge, user_two)

    conn = log_in_user(conn, user_one)

    {:ok, _lv, html} = live(conn, ~p"/dashboard")

    assert html =~ "Your Current Matches"
  end

  test "does not show the user's matches if they have none", %{conn: conn} do
    {:ok, _lv, html} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/dashboard")

    refute html =~ "Your Current Matches"
  end

  test "redirects to the log in page if nobody is logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, ~p"/dashboard")
  end

  test "redirects to the challenge page when a challenge is created", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    {:ok, lv, _html} = live(conn, ~p"/dashboard")

    assert {:error, {:redirect, %{to: "/challenges/" <> _slug}}} =
             lv
             |> form("#challenge-to-one-game", %{maximum_number_of_games: 1})
             |> render_submit()
  end
end
