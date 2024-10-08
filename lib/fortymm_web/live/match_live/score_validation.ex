defmodule FortymmWeb.MatchLive.ScoreValidation do
  use FortymmWeb, :live_view

  alias Fortymm.Matches
  alias Fortymm.Matches.Match

  def handle_params(%{"match_id" => match_id, "game_id" => game_id}, _uri, socket) do
    match =
      match_id
      |> Matches.get_match!()
      |> Match.load_participants()

    Matches.ensure_game_belongs_to_match!(match, game_id)
    participant_user_ids = Enum.map(match.match_participants, & &1.user_id)

    case Enum.member?(participant_user_ids, socket.assigns.current_user.id) do
      true ->
        {:noreply, socket}

      _ ->
        {:noreply, redirect(socket, to: ~p"/matches/#{match_id}")}
    end
  end
end
