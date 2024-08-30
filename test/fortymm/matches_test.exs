defmodule Fortymm.MatchesTest do
  use Fortymm.DataCase

  alias Fortymm.Matches
  alias Fortymm.Challenges.Challenge
  alias Fortymm.Challenges

  import Fortymm.MatchesFixtures
  import Fortymm.ChallengesFixtures

  test "get_match! returns the match with the given id" do
    match = match_fixture()

    assert ^match = Matches.get_match!(match.id)
  end

  test "get_match! raises an error if the match does not exist" do
    assert_raise Ecto.NoResultsError, fn ->
      Matches.get_match!(0)
    end
  end

  test "create_match/1 creates a new match" do
    challenge = challenge_fixture()

    {:ok, match} = Matches.create_match(challenge)
    challenge = Challenges.get_challenge_by_slug!(challenge.slug)

    assert challenge.match_id == match.id
    assert match.status == "pending"
    assert match.maximum_number_of_games == challenge.maximum_number_of_games
  end

  test "create_match/1 returns an error with invalid input" do
    assert {:error, _changeset} = Matches.create_match(%Challenge{})
  end

  test "create_match/1 returns an error when a match has already been created for a challenge" do
    challenge = challenge_fixture()
    Matches.create_match(challenge)

    assert_raise FunctionClauseError, fn ->
      Matches.create_match(challenge)
    end
  end
end
