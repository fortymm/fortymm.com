defmodule FortymmWeb.MatchLive.NewScore do
  use FortymmWeb, :live_view

  alias Fortymm.Matches.Match
  alias Fortymm.Matches

  def render(assigns) do
    ~H"""
    <h1>New Score</h1>
    <!-- Add your form and other content here -->
    """
  end

  def handle_params(%{"match_id" => match_id, "game_id" => game_id}, _uri, socket) do
    match =
      match_id
      |> Matches.get_match!()
      |> Match.load_participants()

    Matches.ensure_game_belongs_to_match!(match, game_id)
    participant_user_ids = Enum.map(match.match_participants, & &1.user_id)

    case Enum.member?(participant_user_ids, socket.assigns.current_user.id) do
      true ->
        {:noreply, assign(socket, match: match, game_id: game_id)}

      _ ->
        {:noreply, redirect(socket, to: ~p"/matches/#{match_id}")}
    end
  end
end
