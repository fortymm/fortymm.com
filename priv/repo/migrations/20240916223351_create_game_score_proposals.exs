defmodule Fortymm.Repo.Migrations.CreateGameScoreProposals do
  use Ecto.Migration

  def change do
    create table(:game_score_proposals) do
      add :accepted_on, :utc_datetime
      add :rejected_on, :utc_datetime
      add :game_id, references(:games, on_delete: :nothing)
      add :entered_by_id, references(:users, on_delete: :nothing)
      add :accepted_by_id, references(:users, on_delete: :nothing)
      add :rejected_by_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    execute("""
      CREATE OR REPLACE FUNCTION check_one_active_proposal_per_game()
      RETURNS trigger AS $$
      BEGIN
        IF (SELECT COUNT(*) FROM game_score_proposals
            WHERE game_id = NEW.game_id AND accepted_on IS NULL AND rejected_on IS NULL) >= 1 THEN
          RAISE EXCEPTION 'Only one active proposal per game is allowed' USING ERRCODE = 'check_violation', CONSTRAINT = 'game_score_proposals_one_active_per_game';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER one_active_proposal_per_game
    BEFORE INSERT ON game_score_proposals
    FOR EACH ROW
    EXECUTE FUNCTION check_one_active_proposal_per_game();
    """)

    execute("""
      CREATE OR REPLACE FUNCTION check_no_new_proposal_after_acceptance()
      RETURNS trigger AS $$
      BEGIN
        IF (SELECT COUNT(*) FROM game_score_proposals
            WHERE game_id = NEW.game_id AND accepted_on IS NOT NULL) > 0 THEN
          RAISE EXCEPTION 'No new proposal is allowed after acceptance' USING ERRCODE = 'check_violation', CONSTRAINT = 'game_score_proposals_no_new_proposal_after_acceptance';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    """)

    execute("""
      CREATE TRIGGER no_new_proposal_after_acceptance
      BEFORE INSERT OR UPDATE ON game_score_proposals
      FOR EACH ROW
      EXECUTE FUNCTION check_no_new_proposal_after_acceptance();
    """)

    create index(:game_score_proposals, [:game_id])
    create index(:game_score_proposals, [:entered_by_id])
    create index(:game_score_proposals, [:accepted_by_id])
    create index(:game_score_proposals, [:rejected_by_id])
  end
end
