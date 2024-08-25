defmodule Fortymm.Challenges do
  alias Fortymm.Challenges.Challenge
  alias Fortymm.Repo

  def create_challenge(attrs) do
    %Challenge{}
    |> Challenge.create_changeset(attrs)
    |> Repo.insert()
  end
end
