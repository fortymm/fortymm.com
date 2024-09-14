defmodule Fortymm.Matches.Game do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Fortymm.Matches.Match

  schema "games" do
    field :status, :string

    belongs_to :match, Match

    timestamps(type: :utc_datetime)
  end

  def for_match(query, match_id) do
    from(g in query, where: g.match_id == ^match_id)
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
