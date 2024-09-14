defmodule FortymmWeb.ChallengeLiveTest do
  use FortymmWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Fortymm.AccountsFixtures
  import Fortymm.ChallengesFixtures

  test "renders an error when the challenge does not exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/challenges/invalid-slug")
    end
  end

  test "redirects to the log in page when nobody is logged in", %{conn: conn} do
    challenge = challenge_fixture()

    assert {:error, {:redirect, %{to: "/users/log_in"}}} =
             live(conn, ~p"/challenges/#{challenge.slug}")
  end

  test "renders the invite when the creator is logged in", %{conn: conn} do
    challenger = user_fixture()
    challenge = challenge_fixture(%{created_by_id: challenger.id})

    {:ok, _lv, html} =
      conn
      |> log_in_user(challenger)
      |> live(~p"/challenges/#{challenge.slug}")

    assert html =~ "To invite someone to play, share this link:"
  end

  test "renders the response form when the creator is not logged in", %{conn: conn} do
    challenger = user_fixture()
    challenge = challenge_fixture(%{created_by_id: challenger.id})

    {:ok, _lv, html} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/challenges/#{challenge.slug}")

    assert html =~ "#{challenger.username} has challenged you!"
  end

  test "allows creating the match when the creator is not logged in", %{conn: conn} do
    challenger = user_fixture()
    challenge = challenge_fixture(%{created_by_id: challenger.id})

    {:ok, lv, _html} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/challenges/#{challenge.slug}")

    assert {:error, {:redirect, %{to: "/matches/" <> _match_id}}} =
             lv
             |> element("#accept-challenge-form")
             |> render_submit()
  end

  test "redirects to the new score page after creating the match", %{conn: conn} do
    challenger = user_fixture()
    challenge = challenge_fixture(%{created_by_id: challenger.id})

    {:ok, lv, _html} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/challenges/#{challenge.slug}")

    {:error, {:redirect, %{to: score_url}}} =
      lv
      |> element("#accept-challenge-form")
      |> render_submit()

    assert {:error, {:redirect, %{to: ^score_url}}} =
             conn
             |> log_in_user(user_fixture())
             |> live(~p"/challenges/#{challenge.slug}")
  end
end
