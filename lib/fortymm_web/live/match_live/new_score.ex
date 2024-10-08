defmodule FortymmWeb.MatchLive.NewScore do
  use FortymmWeb, :live_view

  alias Fortymm.Matches.Match
  alias Fortymm.Matches

  def handle_event("save", %{"game_score_proposal" => game_score_proposal}, socket) do
    %{current_user: current_user, match_id: match_id} = socket.assigns

    case create_score_proposal(current_user, game_score_proposal) do
      {:ok, score_proposal} ->
        {:noreply,
         redirect(socket,
           to:
             ~p"/matches/#{match_id}/games/#{score_proposal.game_id}/scores/#{score_proposal.id}/validations/new"
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp create_score_proposal(current_user, game_score_proposal) do
    game_score_proposal
    |> Map.put("entered_by_id", current_user.id)
    |> Map.put("game_scores", Map.values(game_score_proposal["game_scores"]))
    |> Matches.create_score_proposal()
  end

  def handle_params(%{"match_id" => match_id, "game_id" => game_id}, _uri, socket) do
    %{current_user: current_user} = socket.assigns

    match =
      match_id
      |> Matches.get_match!()
      |> Match.load_games()
      |> Match.load_participants()

    Matches.ensure_game_belongs_to_match!(match, game_id)

    participant_user_ids = Enum.map(match.match_participants, & &1.user_id)

    opponent =
      match.match_participants
      |> Enum.find(&(&1.user_id != current_user.id))
      |> Map.get(:user)

    users_by_match_participant_id =
      match.match_participants
      |> Enum.map(fn match_participant ->
        {match_participant.id, match_participant.user}
      end)
      |> Enum.into(%{})

    case Enum.member?(participant_user_ids, socket.assigns.current_user.id) do
      true ->
        changeset = Matches.score_proposal_changeset(match, game_id)

        {:noreply,
         socket
         |> assign(game_number: length(match.games))
         |> assign(form: to_form(changeset))
         |> assign(users_by_match_participant_id: users_by_match_participant_id)
         |> assign(match_id: match_id)
         |> assign(opponent: opponent)}

      _ ->
        {:noreply, redirect(socket, to: ~p"/matches/#{match_id}")}
    end
  end
end
