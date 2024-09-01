defmodule Fortymm.Matches.MatchParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Fortymm.Accounts.User

  schema "match_participants" do
    field :match_id, :id

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match_participant, attrs) do
    match_participant
    |> cast(attrs, [:user_id, :match_id])
    |> validate_required([:user_id, :match_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:match_id)
  end
end
