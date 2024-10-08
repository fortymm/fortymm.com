defmodule Fortymm.Matches.GameScore do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Matches.GameScoreProposal
  alias Fortymm.Matches.MatchParticipant

  schema "game_scores" do
    field :score, :integer

    belongs_to :match_participant, MatchParticipant
    belongs_to :game_score_proposal, GameScoreProposal

    timestamps(type: :utc_datetime)
  end

  def create_changeset(game_score, attrs) do
    game_score
    |> cast(attrs, [:score, :match_participant_id])
    |> validate_required([:score, :match_participant_id])
    |> validate_number(:score, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:match_participant_id)
  end

  @doc false
  def changeset(game_score, attrs) do
    game_score
    |> cast(attrs, [:match_participant_id])
    |> validate_required([:match_participant_id])
  end
end
