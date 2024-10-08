defmodule Fortymm.Matches do
  alias Fortymm.Challenges.Updates
  alias Fortymm.Repo
  alias Fortymm.Challenges.Challenge
  alias Fortymm.Matches.Match
  alias Fortymm.Matches.MatchParticipant
  alias Fortymm.Accounts.User
  alias Fortymm.Matches.Game
  alias Ecto.Multi
  alias Fortymm.Matches.GameScoreProposal
  import Ecto.Query

  def create_score_proposal(attrs) do
    %GameScoreProposal{}
    |> GameScoreProposal.create_changeset(attrs)
    |> Repo.insert()
  end

  def score_proposal_changeset(%Match{match_participants: match_participants}, game_id) do
    match_participant_ids = Enum.map(match_participants, & &1.id)

    %GameScoreProposal{}
    |> GameScoreProposal.propose_scoring_changeset(%{
      game_id: game_id,
      match_participant_ids: match_participant_ids
    })
  end

  def ensure_game_belongs_to_match!(match, game_id) do
    Game
    |> Game.for_match(match.id)
    |> Repo.get!(game_id)
  end

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
    {:ok, %{match: match, challenge: challenge, first_game: first_game}} =
      Multi.new()
      |> Multi.one(
        :existing_challenge,
        from(c in Challenge,
          where: c.id == ^challenge_id,
          where: is_nil(c.match_id)
        )
      )
      |> Multi.insert(:match, Match.create_from_challenge_changeset(challenge))
      |> Multi.insert(:first_game, fn %{match: match} ->
        Game.create_changeset(%Game{}, %{match_id: match.id})
      end)
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

    {:ok, %{match | games: [first_game]}}
  end
end
