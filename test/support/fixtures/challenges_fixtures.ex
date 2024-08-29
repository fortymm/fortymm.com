defmodule Fortymm.ChallengesFixtures do
  import Fortymm.AccountsFixtures

  def valid_challenge_attributes(attrs \\ %{}) do
    created_by_id =
      case attrs[:created_by_id] do
        nil -> user_fixture().id
        _ -> attrs[:created_by_id]
      end

    Enum.into(attrs, %{
      maximum_number_of_games: 3,
      created_by_id: created_by_id
    })
  end

  def challenge_fixture(attrs \\ %{}) do
    {:ok, challenge} =
      attrs
      |> valid_challenge_attributes()
      |> Fortymm.Challenges.create_challenge()

    challenge
  end
end
