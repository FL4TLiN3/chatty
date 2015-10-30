
defmodule Chatty.TimelineComponent do

  use Chatty.Web, :channel
  alias Chatty.Story
  alias Phoenix.View

  @size 20

  def join("timeline:unauthorized", _message, socket) do
    query = from s in Story,
            where: not is_nil(s.cover),
            order_by: [desc: s.inserted_at],
            limit: @size

    stories = Repo.all(query) |> Repo.preload([:category])

    html = View.render_to_string(Chatty.TimelineComponentView, "index.html", stories: stories)
    dom = html |> Floki.parse

    socket = socket
    |> assign(:stories, stories)
    |> assign(:dom, dom)

    {:ok, %{html: html}, socket}
  end

  def handle_in("older", payload, socket) do
    %Story{inserted_at: oldest_inserted_at} = List.last socket.assigns[:stories]

    query = from s in Story,
            where: not is_nil(s.cover) and s.inserted_at < ^oldest_inserted_at,
            order_by: [desc: s.inserted_at],
            limit: @size

    stories = socket.assigns[:stories] ++ (Repo.all(query) |> Repo.preload([:category]))

    html = View.render_to_string(Chatty.TimelineComponentView, "index.html", stories: stories)
    dom = html |> Floki.parse

    socket = socket
    |> assign(:stories, stories)
    |> assign(:dom, dom)

    push socket, "patch", %{html: html, ts: payload["ts"]}

    {:noreply, socket}
  end
end
