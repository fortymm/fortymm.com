defmodule Fortymm.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Challenges.Challenge
  alias __MODULE__

  schema "matches" do
    field :maximum_number_of_games, :integer
    field :status, :string

    has_one :challenge, Challenge

    timestamps(type: :utc_datetime)
  end

  def valid_maximum_number_of_games() do
    [1, 3, 5, 7]
  end

  def create_from_challenge_changeset(%Challenge{} = challenge) do
    %Match{}
    |> cast(%{}, [])
    |> put_change(:maximum_number_of_games, challenge.maximum_number_of_games)
    |> put_change(:status, "pending")
    |> validate_inclusion(:maximum_number_of_games, valid_maximum_number_of_games())
  end
end
