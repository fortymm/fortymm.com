defmodule Fortymm.MatchesFixtures do
  import Fortymm.ChallengesFixtures

  def match_fixture() do
    challenge = challenge_fixture()
    {:ok, match} = Fortymm.Matches.create_match(challenge)
    match
  end
end
