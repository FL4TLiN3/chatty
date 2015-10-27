defmodule Chatty.Worker.FetchFeed do
  use Chatty.Web, :worker

  alias Chatty.Service.FeedService
  alias Chatty.Feed
  alias Chatty.Story

  def perform do
    feed = Repo.one(from f in Feed, order_by: [asc: f.last_fetched_at], limit: 1)
    headers = FeedService.head(feed.url).headers

    if feed.etag != headers[:ETag] do
      body = FeedService.get(feed.url).body
      saveStory body.stories

      feed
      |> Feed.changeset(%{
        etag: headers[:ETag],
        last_fetched_at: Ecto.DateTime.local})
      |> Repo.update!
    end
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
