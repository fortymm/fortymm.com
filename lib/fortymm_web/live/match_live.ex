defmodule FortymmWeb.MatchLive do
  use FortymmWeb, :live_view

  alias Fortymm.Matches

  def render(assigns) do
    ~H"""
    <h1>Match</h1>
    """
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    {:noreply, socket |> assign(match: Matches.get_match!(id))}
  end
end
