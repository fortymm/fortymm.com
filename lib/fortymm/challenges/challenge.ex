defmodule Fortymm.Challenges.Challenge do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Matches.Match
  alias Fortymm.Accounts.User

  schema "challenges" do
    field :canceled_on, :utc_datetime
    field :maximum_number_of_games, :integer
    field :slug, :string

    belongs_to :created_by, User
    belongs_to :match, Match

    timestamps(type: :utc_datetime)
  end

  def create_changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:maximum_number_of_games, :created_by_id])
    |> validate_required([:maximum_number_of_games, :created_by_id])
    |> put_change(:slug, build_slug())
    |> validate_inclusion(:maximum_number_of_games, Match.valid_maximum_number_of_games())
    |> foreign_key_constraint(:created_by_id)
  end

  def build_slug() do
    alphabet = Enum.concat([?a..?z, ?0..?9])

    1..5
    |> Enum.map(fn _ -> Enum.random(alphabet) end)
    |> List.to_string()
  end
end
