defmodule FortymmWeb.MatchLive.NewScoreTest do
  use FortymmWeb.ConnCase

  import Phoenix.LiveViewTest
  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures

  alias Fortymm.Matches.Match

  test "shows the new score page", %{conn: conn} do
    match =
      match_fixture()
      |> Match.load_participants()

    [first_game] = match.games
    first_participant = List.first(match.match_participants)

    {:ok, _view, html} =
      conn
      |> log_in_user(first_participant.user)
      |> live(~p"/matches/#{match.id}/games/#{first_game.id}/scores/new")

    assert html =~ "Enter the scores for game #1 in your match against"
  end

  test "redirects to the match page when no user is logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log_in"}}} =
             live(conn, ~p"/matches/1/games/1/scores/new")
  end

  test "redirects to the match page when the user is not a match participant", %{conn: conn} do
    match = match_fixture()
    [first_game] = match.games

    match_route = ~p"/matches/#{match.id}"

    {:error, {:redirect, %{to: ^match_route}}} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/matches/#{match.id}/games/#{first_game.id}/scores/new")
  end

  test "shows an error when the match is not found", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/matches/0/games/1/scores/new")
    end
  end

  test "shows an error when the game is not found", %{conn: conn} do
    match = match_fixture()

    assert_raise Ecto.NoResultsError, fn ->
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/matches/#{match.id}/games/0/scores/new")
    end
  end

  test "shows an error when the game is not part of the match", %{conn: conn} do
    match = match_fixture()
    game = game_fixture()

    assert_raise Ecto.NoResultsError, fn ->
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/matches/#{match.id}/games/#{game.id}/scores/new")
    end
  end

  test "redirects to the validation page when a valid score is entered", %{conn: conn} do
    match =
      match_fixture()
      |> Match.load_participants()

    [first_game] = match.games
    first_participant = List.first(match.match_participants)

    {:ok, view, _html} =
      conn
      |> log_in_user(first_participant.user)
      |> live(~p"/matches/#{match.id}/games/#{first_game.id}/scores/new")

    assert {:error, {:redirect, %{to: score_url}}} =
             view
             |> element("#new-score-form")
             |> render_submit(%{
               "game_score_proposal" => %{
                 "game_scores" => %{"0" => %{"score" => "6"}, "1" => %{"score" => "11"}}
               }
             })

    assert score_url =~
             ~r|^/matches/#{match.id}/games/#{first_game.id}/scores/\d+/validations/new$|
  end

  test "does not redirect when the score is not valid", %{conn: conn} do
    match =
      match_fixture()
      |> Match.load_participants()

    [first_game] = match.games
    first_participant = List.first(match.match_participants)

    {:ok, view, _html} =
      conn
      |> log_in_user(first_participant.user)
      |> live(~p"/matches/#{match.id}/games/#{first_game.id}/scores/new")

    assert view
           |> element("#new-score-form")
           |> render_submit(%{
             "game_score_proposal" => %{
               "game_scores" => %{"0" => %{"score" => "6"}, "1" => %{"score" => "1"}}
             }
           }) =~ "Enter the scores for game #1 in your match against"
  end
end
