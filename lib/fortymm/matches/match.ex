defmodule Fortymm.Matches.Match do
  use Ecto.Schema

  schema "matches" do
    field :maximum_number_of_games, :integer
    field :status, :string

    timestamps(type: :utc_datetime)
  end

  def valid_maximum_number_of_games() do
    [1, 3, 5, 7]
  end
end
