defmodule Fortymm.Matches.GameScoreTest do
  use Fortymm.DataCase

  alias Fortymm.Matches.Match
  alias Fortymm.Matches.GameScore
  alias Fortymm.Repo
  import Fortymm.MatchesFixtures

  test "is valid with valid data" do
    [match_participant, _] =
      match_fixture()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      GameScore.create_changeset(%GameScore{}, %{
        score: 100,
        match_participant_id: match_participant.id
      })

    assert changeset.valid?
  end

  test "is invalid with a negative score" do
    [match_participant, _] =
      match_fixture()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      GameScore.create_changeset(%GameScore{}, %{
        score: -100,
        match_participant_id: match_participant.id
      })

    refute changeset.valid?
  end

  test "is invalid without a score" do
    [match_participant, _] =
      match_fixture()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      GameScore.create_changeset(%GameScore{}, %{
        match_participant_id: match_participant.id
      })

    refute changeset.valid?
  end

  test "is invalid without a match_participant_id" do
    changeset =
      GameScore.create_changeset(%GameScore{}, %{
        score: 100
      })

    refute changeset.valid?
  end

  test "is invalid with an invalid match_participant_id" do
    assert {:error, _changeset} =
             GameScore.create_changeset(%GameScore{}, %{
               score: 100,
               match_participant_id: -1
             })
             |> Repo.insert()
  end

  test "is invalid without a game_score_id" do
    changeset =
      GameScore.create_changeset(%GameScore{}, %{
        match_participant_id: Ecto.UUID.generate()
      })

    refute changeset.valid?
  end
end
