defmodule Fortymm.MatchesFixtures do
  import Fortymm.ChallengesFixtures
  import Fortymm.AccountsFixtures

  def match_fixture() do
    challenge = challenge_fixture()
    user = user_fixture()
    {:ok, match} = Fortymm.Matches.create_match(challenge, user)
    match
  end
end
