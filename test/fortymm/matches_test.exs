defmodule Fortymm.MatchesTest do
  alias Fortymm.Challenges.Updates
  use Fortymm.DataCase

  alias Fortymm.Matches
  alias Fortymm.Challenges.Challenge
  alias Fortymm.Challenges

  import Fortymm.MatchesFixtures
  import Fortymm.ChallengesFixtures
  import Fortymm.AccountsFixtures

  test "list_matches_for_user/1 returns the matches for the given user" do
    user_one = user_fixture()
    user_two = user_fixture()
    user_three = user_fixture()
    user_four = user_fixture()

    challenge_one = challenge_fixture(%{created_by_id: user_one.id})
    challenge_two = challenge_fixture(%{created_by_id: user_three.id})

    {:ok, match_one} = Matches.create_match(challenge_one, user_two)
    {:ok, match_two} = Matches.create_match(challenge_two, user_four)

    matches_for_user_one = Matches.list_matches_for_user(user_one)
    matches_for_user_two = Matches.list_matches_for_user(user_two)
    matches_for_user_three = Matches.list_matches_for_user(user_three)
    matches_for_user_four = Matches.list_matches_for_user(user_four)

    assert matches_for_user_one == matches_for_user_two
    assert matches_for_user_three == matches_for_user_four

    assert [match_one.id] == Enum.map(matches_for_user_one, & &1.id)
    assert [match_two.id] == Enum.map(matches_for_user_three, & &1.id)
  end

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
    user = user_fixture()

    {:ok, match} = Matches.create_match(challenge, user)
    challenge = Challenges.get_challenge_by_slug!(challenge.slug)

    assert challenge.match_id == match.id
    assert match.status == "pending"
    assert match.maximum_number_of_games == challenge.maximum_number_of_games
  end

  test "create_match/1 returns an error with invalid input" do
    user = user_fixture()
    assert {:error, _changeset} = Matches.create_match(%Challenge{}, user)
  end

  test "create_match/1 broadcasts a challenge update" do
    user = user_fixture()
    challenge = challenge_fixture()
    Updates.subscribe(challenge.id)

    assert {:ok, match} = Matches.create_match(challenge, user)

    assert_receive challenge_update
    assert challenge_update.match_id == match.id
    assert challenge_update.id == challenge.id
  end

  test "create_match/1 returns an error when a match has already been created for a challenge" do
    user = user_fixture()
    challenge = challenge_fixture()
    Matches.create_match(challenge, user)

    assert_raise KeyError, fn ->
      Matches.create_match(challenge, user)
    end
  end
end
