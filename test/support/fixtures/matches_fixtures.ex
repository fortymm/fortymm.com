defmodule Fortymm.MatchesFixtures do
  import Fortymm.ChallengesFixtures
  import Fortymm.AccountsFixtures

  def game_fixture() do
    %Fortymm.Matches.Game{}
    |> Fortymm.Matches.Game.create_changeset(%{match_id: match_fixture().id})
    |> Fortymm.Repo.insert!()
  end

  def match_fixture() do
    challenge = challenge_fixture()
    user = user_fixture()
    {:ok, match} = Fortymm.Matches.create_match(challenge, user)
    match
  end

  def game_score_proposal_fixture() do
  end
end
