defmodule FortymmWeb.DashboardLive do
  use FortymmWeb, :live_view

  alias Fortymm.Challenges

  def handle_event(
        "create_challenge",
        %{"maximum_number_of_games" => maximum_number_of_games},
        socket
      ) do
    %{assigns: %{current_user: current_user}} = socket

    with {:ok, challenge} <-
           Challenges.create_challenge(%{
             created_by_id: current_user.id,
             maximum_number_of_games: maximum_number_of_games
           }),
         %{slug: slug} <- challenge do
      {:noreply, redirect(socket, to: ~p"/challenges/#{slug}")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating challenge")}
    end
  end
end
