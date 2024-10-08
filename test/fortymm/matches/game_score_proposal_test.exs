defmodule Fortymm.Matches.GameScoreProposalTest do
  use Fortymm.DataCase

  alias Fortymm.Matches.GameScoreProposal
  alias Fortymm.Matches.Match
  alias Fortymm.Matches
  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures

  test "is valid with valid data" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 11
          },
          %{
            match_participant_id: second_participant.id,
            score: 9
          }
        ]
      })

    assert changeset.valid?
  end

  test "is invalid with no game_id" do
    user = user_fixture()

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: nil,
        entered_by_id: user.id
      })

    refute changeset.valid?
  end

  test "is invalid with an invalid game_id" do
    user = user_fixture()

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: Ecto.UUID.generate(),
        entered_by_id: user.id
      })

    refute changeset.valid?
  end

  test "is invalid with no entered_by_id" do
    game = game_fixture()

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: nil
      })

    refute changeset.valid?
  end

  test "is invalid with an invalid entered_by_id" do
    game = game_fixture()

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: Ecto.UUID.generate()
      })

    refute changeset.valid?
  end

  test "is invalid without score proposals" do
  end

  test "is invalid with fewer than 2 score proposals" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, _second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 11
          }
        ]
      })

    refute changeset.valid?
  end

  test "is invalid with more than 2 score proposals" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 11
          },
          %{
            match_participant_id: second_participant.id,
            score: 7
          },
          %{
            match_participant_id: second_participant.id,
            score: 9
          }
        ]
      })

    refute changeset.valid?
  end

  test "is invalid if any of the participants are not in the match" do
    game = game_fixture()
    other_game = game_fixture()
    user = user_fixture()

    [first_participant, _second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    [_first_participant, second_participant] =
      other_game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 11
          },
          %{
            match_participant_id: second_participant.id,
            score: 9
          }
        ]
      })

    refute changeset.valid?
  end

  test "is invalid if the scores are for the same match participant" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, _second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 11
          },
          %{
            match_participant_id: first_participant.id,
            score: 9
          }
        ]
      })

    refute changeset.valid?
  end

  test "is invalid if nobody has won" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 8
          },
          %{
            match_participant_id: second_participant.id,
            score: 8
          }
        ]
      })

    refute changeset.valid?
  end

  test "is valid if the game went to deuce and the scores are within 2 points of each other" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 13
          },
          %{
            match_participant_id: second_participant.id,
            score: 11
          }
        ]
      })

    assert changeset.valid?
  end

  test "is invalid if the game went to deuce and the scores are not within 2 points of each other" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    changeset =
      %GameScoreProposal{}
      |> GameScoreProposal.create_changeset(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 13
          },
          %{
            match_participant_id: second_participant.id,
            score: 10
          }
        ]
      })

    refute changeset.valid?
  end

  test "is invalid if there is a pending proposal for the same game" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    {:ok, _proposal} =
      Matches.create_score_proposal(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 11
          },
          %{
            match_participant_id: second_participant.id,
            score: 9
          }
        ]
      })

    assert {:error, _changeset} =
             Matches.create_score_proposal(%{
               game_id: game.id,
               entered_by_id: user.id,
               game_scores: [
                 %{
                   match_participant_id: first_participant.id,
                   score: 11
                 },
                 %{
                   match_participant_id: second_participant.id,
                   score: 9
                 }
               ]
             })
  end

  test "is invalid if the game has already been scored" do
    game = game_fixture()
    user = user_fixture()

    [first_participant, second_participant] =
      game
      |> Map.get(:match_id)
      |> Matches.get_match!()
      |> Match.load_participants()
      |> Map.get(:match_participants)

    {:ok, proposal} =
      Matches.create_score_proposal(%{
        game_id: game.id,
        entered_by_id: user.id,
        game_scores: [
          %{
            match_participant_id: first_participant.id,
            score: 11
          },
          %{
            match_participant_id: second_participant.id,
            score: 9
          }
        ]
      })

    proposal
    |> cast(%{accepted_on: DateTime.utc_now(), accepted_by_id: first_participant.user_id}, [
      :accepted_on,
      :accepted_by_id
    ])
    |> Repo.update()

    assert {:error, _changeset} =
             Matches.create_score_proposal(%{
               game_id: game.id,
               entered_by_id: user.id,
               game_scores: [
                 %{
                   match_participant_id: first_participant.id,
                   score: 11
                 },
                 %{
                   match_participant_id: second_participant.id,
                   score: 9
                 }
               ]
             })
  end
end
