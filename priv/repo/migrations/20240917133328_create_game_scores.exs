defmodule Fortymm.Repo.Migrations.CreateGameScores do
  use Ecto.Migration

  def change do
    create table(:game_scores) do
      add :score, :integer
      add :match_participant_id, references(:match_participants, on_delete: :nothing)
      add :game_score_proposal_id, references(:game_score_proposals, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:game_scores, [:match_participant_id])
    create index(:game_scores, [:game_score_proposal_id])
  end
end
