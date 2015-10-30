defmodule Chatty.Service.FeedService do
  use HTTPotion.Base
  use Timex

  def process_url(url), do: url

  def process_request_headers(headers) do
    Dict.put headers, :"Accept", "application/rss+xml,application/rdf+xml,application/atom+xml"
  end

  def process_response_body(body) do
    body = IO.iodata_to_binary body
    cond do
      body |> val("rss") ->
        {:ok, parse_feed(body, :rss)}
      body |> val("feed") ->
        {:ok, parse_feed(body, :atom)}
      true ->
        {:error, "Got non-feed response body"}
    end
  end

  def parse_feed(document, :rss) do
    feed = %{
      title:         document |> val("channel > title"),
      link:          document |> val("channel > link"),
      description:   document |> val("channel > description")
    }

    stories = document
    |> Floki.find("channel > item")
    |> Enum.map(
      fn(item) ->
        story = %{
          title:         item |> val("title"),
          original_link: item |> val("guid"),
          published_at:  item |> Floki.find("pubdate")
                              |> Floki.text
                              |> DateFormat.parse!("{RFC1123}")
                              |> DateConvert.to_erlang_datetime
                              |> Ecto.DateTime.from_erl,
          description:   item |> val("description"),
          category_id:   1
        }

        cond do
          !is_nil(item |> val("enclosure", "url")) ->
            story = Dict.put(story, :cover, item |> val("enclosure", "url"))
          !is_nil(item |> val("image")) ->
            story = Dict.put(story, :cover, item |> val("image"))
          !is_nil(img_in_description(item, :rss)) ->
            story = Dict.put(story, :cover, img_in_description(item, :rss))
          true ->
        end

        story
      end)

    feed
    |> Map.put(:stories, stories)
  end

  def parse_feed(document, :atom) do
    feed = %{
      title:         document |> val("feed > title"),
      link:          document |> val("feed > link[rel='alternate']", "href"),
      description:   document |> val("feed > subtitle")
    }

    stories = document
    |> Floki.find("feed > entry")
    |> Enum.map(
      fn(item) ->
        story = %{
          title:         item |> val("title"),
          original_link: item |> val("link", "href"),
          published_at:  item |> Floki.find("published")
                              |> Floki.text
                              |> DateFormat.parse!("{ISO}")
                              |> DateConvert.to_erlang_datetime
                              |> Ecto.DateTime.from_erl,
          description:   item |> val("content"),
          category_id:   1
        }

        if !is_nil(img_in_description(item, :atom)) do
          story = Dict.put(story, :cover, img_in_description(item, :atom))
        end

        story
      end)

    feed
    |> Map.put(:stories, stories)
  end

  def val(document, selector) do
    value = document |> Floki.find(selector) |> Floki.text
    if String.length(value) > 0 do
      value
    else
      nil
    end
  end

  def val(document, selector, attr_name) do
    value = document |> Floki.find(selector) |> Floki.attribute(attr_name) |> Floki.text
    if String.length(value) > 0 do
      value
    else
      nil
    end
  end

  def img_in_description(document, :rss) do
    value = document |> val("description") |> Floki.parse |> Floki.find("img") |> hd |> Floki.attribute("src") |> Floki.text
    if String.length(value) > 0 do
      value
    else
      nil
    end
  end

  def img_in_description(document, :atom) do
    value = document |> val("content") |> Floki.parse |> Floki.find("img") |> hd |> Floki.attribute("src") |> Floki.text
    if String.length(value) > 0 do
      value
    else
      nil
    end
  end
end
