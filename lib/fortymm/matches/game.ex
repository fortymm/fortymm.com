defmodule Fortymm.Matches.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fortymm.Matches.Match

  schema "games" do
    field :status, :string

    belongs_to :match, Match

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(game, attrs) do
    game
    |> cast(attrs, [:match_id])
    |> validate_required([:match_id])
    |> put_change(:status, "pending")
    |> foreign_key_constraint(:match_id)
  end
end
