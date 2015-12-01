
defmodule Chatty.TimelineComponent do
  use Chatty.Web, :channel
  import Chatty.Component

  alias Chatty.State
  alias Chatty.Story

  @size 10

  def init(context, payload) do
    context
    |> noop payload
  end

  def older({socket, state}, payload) do
    if !is_nil(State.get(state, :stories)) do
      %Story{inserted_at: oldest_inserted_at} = List.last State.get(state, :stories)
    end

    query = from s in Story, order_by: [desc: s.inserted_at], limit: @size

    if oldest_inserted_at do
      query = from s in query, where: not is_nil(s.cover) and s.inserted_at < ^oldest_inserted_at
    end

    stories = query
    |> Repo.all
    |> append_to(State.get(state, :stories))
    |> Repo.preload([:category])

    State.set(state, :stories, stories)
    patch({socket, state}, "index.html", stories: stories)
  end

  defp append_to(new_list, append_to) do
    if is_nil append_to do
      new_list
    else
      new_list = append_to ++ new_list
    end
  end
end
