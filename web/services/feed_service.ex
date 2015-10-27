defmodule Chatty.Service.FeedService do
  use HTTPotion.Base
  use Timex

  def process_url(url), do: url

  def process_request_headers(headers) do
    Dict.put headers, :"Accept", "application/rss+xml,application/rdf+xml,application/atom+xml"
  end

  def process_response_body(body) do
    body = IO.iodata_to_binary body
    feed = %{
      rss_version:   body |> Floki.find("rss") |> Floki.attribute("version") |> Floki.text,
      title:         body |> Floki.find("channel > title") |> Floki.text,
      link:          body |> Floki.find("channel > link") |> Floki.text,
      description:   body |> Floki.find("channel > description") |> Floki.text,
      lastBuildDate: body |> Floki.find("channel > lastBuildDate") |> Floki.text,
      language:      body |> Floki.find("channel > language") |> Floki.text
    }

    stories = body
    |> Floki.find("channel > item")
    |> Enum.map(fn(item) -> %{
      title:         item |> Floki.find("title") |> Floki.text,
      cover:         item |> Floki.find("enclosure") |> Floki.attribute("url") |> Floki.text,
      original_link: item |> Floki.find("link") |> Floki.text,
      published_at:  item |> Floki.find("pubdate")
                          |> Floki.text
                          |> DateFormat.parse!("{RFC1123}")
                          |> DateConvert.to_erlang_datetime
                          |> Ecto.DateTime.from_erl,
      description:   item |> Floki.find("description") |> Floki.text,
      category_id:   1
    } end)

    feed
    |> Map.put(:stories, stories)

  end
end
