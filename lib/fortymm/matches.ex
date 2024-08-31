defmodule Fortymm.Matches do
  alias Fortymm.Challenges.Updates
  alias Fortymm.Repo
  alias Fortymm.Challenges.Challenge
  alias Fortymm.Matches.Match
  alias Ecto.Multi

  import Ecto.Query

  def get_match!(id) do
    Repo.get!(Match, id)
  end

  def create_match(%Challenge{id: nil}), do: {:error, :invalid_challenge}

  def create_match(%Challenge{id: challenge_id} = challenge) do
    {:ok, %{match: match, challenge: challenge}} =
      Multi.new()
      |> Multi.one(
        :existing_challenge,
        from(c in Challenge,
          where: c.id == ^challenge_id,
          where: is_nil(c.match_id)
        )
      )
      |> Multi.insert(:match, Match.create_from_challenge_changeset(challenge))
      |> Multi.update(
        :challenge,
        fn %{match: match, existing_challenge: existing_challenge} ->
          Challenge.set_match_changeset(existing_challenge, match)
        end
      )
      |> Repo.transaction()

    Updates.broadcast(challenge)

    {:ok, match}
  end
end
