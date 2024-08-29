defmodule Fortymm.ChallengesTest do
  use Fortymm.DataCase

  alias Fortymm.Challenges
  import Fortymm.AccountsFixtures
  import Fortymm.ChallengesFixtures

  test "get_challenge_by_slug/1 returns a challenge with a valid slug" do
    challenge = challenge_fixture()

    assert challenge == Challenges.get_challenge_by_slug!(challenge.slug)
  end

  test "get_challenge_by_slug/1 raises an error with an invalid slug" do
    assert_raise Ecto.NoResultsError, fn ->
      Challenges.get_challenge_by_slug!("invalid-slug")
    end
  end

  test "create_challenge/1 creates a challenge with valid input" do
    creator = user_fixture()

    assert {:ok, challenge} =
             Challenges.create_challenge(%{maximum_number_of_games: 3, created_by_id: creator.id})

    assert challenge.maximum_number_of_games == 3
    assert challenge.created_by_id == creator.id
    assert challenge.match_id == nil
    assert challenge.canceled_on == nil
  end

  test "create_challenge/1 returns an error with valid input" do
    assert {:error, _changeset} = Challenges.create_challenge(%{})
  end
end
