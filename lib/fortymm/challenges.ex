defmodule Fortymm.Challenges do
  alias Fortymm.Challenges.Challenge
  alias Fortymm.Repo

  def create_challenge(attrs) do
    %Challenge{}
    |> Challenge.create_changeset(attrs)
    |> Repo.insert()
  end

  def get_challenge_by_slug!(slug) do
    Repo.get_by!(Challenge, slug: slug)
  end
end
