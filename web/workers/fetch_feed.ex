defmodule Chatty.Worker.FetchFeed do
  use Chatty.Web, :worker

  alias Chatty.Service.FeedService
  alias Chatty.Feed
  alias Chatty.Story

  def perform do
    feed = Repo.one(from f in Feed, order_by: [asc: f.last_fetched_at], limit: 1)
    IO.puts "Start Fetching Feed. URL: " <> feed.url
    case FeedService.get(feed.url, [timeout: 100_000]).body do
      {:ok, body} ->
        saveStory body.stories
      _ ->
    end

    feed
    |> Feed.changeset(%{
      # etag: headers[:ETag],
      last_fetched_at: Ecto.DateTime.local})
    |> Repo.update!
  end

  def saveStory([head|tail]) do
    story = Repo.one(from s in Story, where: s.original_link == ^head.original_link, limit: 1)

    if story do
      story |> Story.changeset(head) |> Repo.update!
    else
      %Story{} |> Story.changeset(head) |> Repo.insert!
    end

    saveStory tail
  end

  def saveStory(_), do: nil
end
