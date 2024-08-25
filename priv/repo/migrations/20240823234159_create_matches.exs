defmodule Fortymm.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :maximum_number_of_games, :integer, null: false
      add :status, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
