defmodule Fortymm.Challenges.Updates do
  alias Phoenix.PubSub
  @pubsub Fortymm.PubSub

  def broadcast(challenge) do
    PubSub.broadcast(@pubsub, topic(challenge.id), challenge)
  end

  def subscribe(challenge_id) do
    PubSub.subscribe(@pubsub, topic(challenge_id))
  end

  defp topic(challenge_id) do
    "challenge:#{challenge_id}"
  end
end
