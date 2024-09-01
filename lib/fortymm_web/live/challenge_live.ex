defmodule FortymmWeb.ChallengeLive do
  alias Fortymm.Challenges.Updates
  use FortymmWeb, :live_view

  alias Fortymm.Challenges
  alias Fortymm.Matches
  alias Fortymm.Challenges.Challenge
  alias Fortymm.Challenges.Updates

  def handle_params(%{"slug" => slug}, uri, socket) do
    challenge = load_challenge!(slug)

    if connected?(socket) do
      Updates.subscribe(challenge.id)
    end

    case challenge.match_id do
      nil ->
        {:noreply,
         socket
         |> assign(uri: uri)
         |> assign(challenge: challenge)}

      match_id ->
        {:noreply,
         socket
         |> put_flash(:info, "The challenge has already been accepted")
         |> redirect(to: ~p"/matches/#{match_id}")}
    end
  end

  def render(assigns) do
    cond do
      assigns.challenge.created_by_id == assigns.current_user.id ->
        challenge_invite(assigns)

      true ->
        challenge_response(assigns)
    end
  end

  def handle_info(challenge, socket) do
    {:noreply, redirect(socket, to: ~p"/matches/#{challenge.match_id}")}
  end

  def handle_event("accept_challenge", _unsigned_params, socket) do
    %{current_user: current_user, challenge: challenge} = socket.assigns

    cond do
      current_user.id == challenge.created_by_id ->
        {:noreply,
         socket
         |> put_flash(:error, "You can't accept your own challenge")}

      true ->
        with {:ok, match} <- Matches.create_match(challenge, current_user) do
          {:noreply, redirect(socket, to: ~p"/matches/#{match.id}")}
        else
          _ ->
            {:noreply,
             socket
             |> put_flash(:error, "Error accepting challenge")}
        end
    end
  end

  defp challenge_invite(assigns) do
    qr_code_settings = %QRCode.Render.SvgSettings{scale: 6}

    {:ok, qr_code} =
      assigns.uri
      |> QRCode.create()
      |> QRCode.render(:svg, qr_code_settings)

    assigns =
      assigns
      |> assign(:qr_code, qr_code)

    ~H"""
    <div class="grid gap-4 sm:grid-cols-2 grid-rows-2">
      <div class="rounded-lg bg-gray-50 shadow-sm ring-1 ring-gray-900/5 grow">
        <div class="px-4 py-5 sm:p-6 flex flex-col gap-4">
          To invite someone to play, share this link:
          <div class="flex gap-2 items-center align-middle">
            <input
              disabled
              name="invite-url"
              value={@uri}
              type="text"
              class="block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 border-zinc-300 focus:border-zinc-400"
            />
            <.button phx-hook="Copy" id="copy-url-button" data-text={@uri}>
              <.icon name="hero-clipboard" />
            </.button>
          </div>
          The first person to come to this URL will play with you.
        </div>
      </div>

      <div class="rounded-lg bg-gray-50 shadow-sm ring-1 ring-gray-900/5 grow">
        <div class="h-full px-4 py-5 sm:p-6 flex items-center justify-between gap-4">
          Or let your opponent scan this QR code
          <div>
            <%= raw(@qr_code) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp challenge_response(assigns) do
    winning_game_count = ceil(assigns.challenge.maximum_number_of_games / 2)

    assigns =
      assigns
      |> assign(:winning_game_count, winning_game_count)

    ~H"""
    <section class="relative isolate overflow-hidden bg-white px-6 lg:px-8">
      <div class="mx-auto max-w-2xl lg:max-w-4xl">
        <div class="text-center text-l font-semibold leading-8 text-gray-900 sm:text-2xl sm:leading-9 flex flex-col gap-8">
          <p>
            <%= @challenge.created_by.username %> has challenged you!
          </p>
          <p>
            <%= if @winning_game_count == 1 do %>
              The first player to win a game wins the match.
            <% else %>
              The first player to win <%= @winning_game_count %> games wins the match.
            <% end %>
          </p>
        </div>
        <.simple_form
          for={}
          phx-submit="accept_challenge"
          class="flex justify-center"
          id="accept-challenge-form"
        >
          <.button>
            Accept the challenge
          </.button>
        </.simple_form>
      </div>
    </section>
    """
  end

  defp load_challenge!(slug) do
    slug
    |> Challenges.get_challenge_by_slug!()
    |> Challenge.preload_created_by()
  end
end
