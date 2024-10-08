defmodule Fortymm.Matches.GameScoreProposal do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Fortymm.Matches.GameScore
  alias Fortymm.Matches.MatchParticipant
  alias Fortymm.Repo

  schema "game_score_proposals" do
    field :accepted_on, :utc_datetime
    field :rejected_on, :utc_datetime
    field :game_id, :id

    field :entered_by_id, :id
    field :accepted_by_id, :id
    field :rejected_by_id, :id

    has_many :game_scores, GameScore

    timestamps(type: :utc_datetime)
  end

  def create_changeset(game_score_proposal, attrs) do
    game_score_proposal
    |> cast(attrs, [:game_id, :entered_by_id])
    |> validate_required([:game_id, :entered_by_id])
    |> foreign_key_constraint(:game_id)
    |> foreign_key_constraint(:entered_by_id)
    |> cast_assoc(:game_scores, with: &GameScore.create_changeset/2, required: true)
    |> validate_length(:game_scores, min: 2, max: 2)
    |> validate_match_participants()
    |> validate_different_match_participants()
    |> validate_somebody_has_won()
    |> validate_deuce_scores()
    |> check_constraint(:game_id, name: "game_score_proposals_one_active_per_game")
    |> check_constraint(:game_id, name: "game_score_proposals_no_new_proposal_after_acceptance")
  end

  def propose_scoring_changeset(game_score_proposal, attrs) do
    game_score_proposal
    |> cast(attrs, [:game_id])
    |> validate_required([:game_id])
    |> put_game_scores(attrs[:match_participant_ids])
  end

  defp validate_deuce_scores(changeset) do
    case changeset.valid? do
      true ->
        changeset
        |> Ecto.Changeset.get_assoc(:game_scores)
        |> Enum.map(fn game_score -> game_score.changes end)
        |> Enum.map(fn match_participant -> match_participant.score end)
        |> Enum.any?(fn score -> score > 11 end)
        |> maybe_add_deuce_error(changeset)

      false ->
        changeset
    end
  end

  defp maybe_add_deuce_error(false, changeset), do: changeset

  defp maybe_add_deuce_error(true, changeset) do
    [first_score, second_score] =
      changeset
      |> Ecto.Changeset.get_assoc(:game_scores)
      |> Enum.map(fn game_score -> game_score.changes end)
      |> Enum.map(fn match_participant -> match_participant.score end)

    if abs(first_score - second_score) != 2 do
      add_error(
        changeset,
        :game_scores,
        "Game went to deuce but scores are not within 2 points of each other"
      )
    else
      changeset
    end
  end

  defp validate_somebody_has_won(changeset) do
    case changeset.valid? do
      true ->
        changeset
        |> Ecto.Changeset.get_assoc(:game_scores)
        |> Enum.map(fn game_score -> game_score.changes end)
        |> Enum.map(fn match_participant -> match_participant.score end)
        |> Enum.any?(fn score -> score > 10 end)
        |> maybe_add_no_winner_error(changeset)

      false ->
        changeset
    end
  end

  defp maybe_add_no_winner_error(true, changeset), do: changeset

  defp maybe_add_no_winner_error(false, changeset),
    do: add_error(changeset, :game_scores, "Somebody has to win")

  defp validate_different_match_participants(changeset) do
    case changeset.valid? do
      true ->
        changeset
        |> Ecto.Changeset.get_assoc(:game_scores)
        |> Enum.map(fn game_score -> game_score.changes end)
        |> Enum.map(fn match_participant -> match_participant.match_participant_id end)
        |> Enum.uniq()
        |> ensure_length_is_2(changeset)

      _ ->
        changeset
    end
  end

  defp ensure_length_is_2(match_participant_ids, changeset) do
    cond do
      length(match_participant_ids) == 2 ->
        changeset

      true ->
        add_error(changeset, :game_scores, "Must have two participants")
    end
  end

  defp validate_match_participants(changeset) do
    case changeset.valid? do
      true ->
        changeset
        |> Ecto.Changeset.get_assoc(:game_scores)
        |> Enum.map(fn game_score -> game_score.changes end)
        |> Enum.map(fn match_participant -> match_participant.match_participant_id end)
        |> ensure_participants_are_in_the_same_match(changeset)

      false ->
        changeset
    end
  end

  defp ensure_participants_are_in_the_same_match(match_participant_ids, changeset) do
    unique_match_ids =
      MatchParticipant
      |> where([p], p.id in ^match_participant_ids)
      |> Repo.all()
      |> Enum.map(fn match_participant -> match_participant.match_id end)
      |> Enum.uniq()

    cond do
      length(unique_match_ids) == 1 ->
        changeset

      true ->
        add_error(changeset, :game_scores, "Participants must be in the same match")
    end
  end

  defp put_game_scores(changeset, match_participant_ids) do
    game_scores =
      match_participant_ids
      |> Enum.map(fn match_participant_id ->
        %{
          match_participant_id: match_participant_id,
          score: 0
        }
      end)

    changeset
    |> put_assoc(:game_scores, game_scores)
  end
end
