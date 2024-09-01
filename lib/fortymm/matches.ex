defmodule Fortymm.Matches do
  alias Fortymm.Challenges.Updates
  alias Fortymm.Repo
  alias Fortymm.Challenges.Challenge
  alias Fortymm.Matches.Match
  alias Fortymm.Matches.MatchParticipant
  alias Fortymm.Accounts.User
  alias Ecto.Multi

  import Ecto.Query

  def list_matches_for_user(user) do
    Match
    |> Match.for_participant(user)
    |> Repo.all()
  end

  def get_match!(id) do
    Repo.get!(Match, id)
  end

  def create_match(%Challenge{id: nil}, _accepted_by), do: {:error, :invalid_challenge}
  def create_match(_challenge, %User{id: nil}), do: {:error, :invalid_user}

  def create_match(%Challenge{id: challenge_id} = challenge, %User{id: accepted_by_id}) do
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
      |> Multi.insert_all(
        :match_participants,
        MatchParticipant,
        fn %{match: match, existing_challenge: existing_challenge} ->
          now =
            DateTime.utc_now()
            |> DateTime.truncate(:second)

          [
            %{
              match_id: match.id,
              user_id: accepted_by_id,
              inserted_at: now,
              updated_at: now
            },
            %{
              match_id: match.id,
              user_id: existing_challenge.created_by_id,
              inserted_at: now,
              updated_at: now
            }
          ]
        end
      )
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
