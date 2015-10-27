defmodule Chatty.StoryController do
  use Chatty.Web, :controller

  alias Chatty.Story
  alias Chatty.Category

  plug :scrub_params, "story" when action in [:create, :update]
  plug :put_layout, :admin

  def index(conn, params) do
    stories = Story
    |> Story.paging(params)
    |> Story.category(params)
    |> Story.order(params)
    |> Repo.all
    |> Repo.preload [:category]

    render(conn, :index, stories: stories)
  end

  def new(conn, _params) do
    changeset = Story.changeset(%Story{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"story" => story_params}) do
    changeset = Story.changeset(%Story{}, story_params)

    case Repo.insert(changeset) do
      {:ok, _story} ->
        conn
        |> put_flash(:info, "Story created successfully.")
        |> redirect(to: story_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    story = Repo.get!(Story, id) |> Repo.preload [:category]
    render(conn, :show, story: story)
  end

  def edit(conn, %{"id" => id}) do
    story = Repo.get!(Story, id)
    changeset = Story.changeset(story)
    render(conn, "edit.html", story: story, changeset: changeset)
  end

  def update(conn, %{"id" => id, "story" => story_params}) do
    story = Repo.get!(Story, id)
    changeset = Story.changeset(story, story_params)

    case Repo.update(changeset) do
      {:ok, story} ->
        conn
        |> put_flash(:info, "Story updated successfully.")
        |> redirect(to: story_path(conn, :show, story))
      {:error, changeset} ->
        render(conn, "edit.html", story: story, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    story = Repo.get!(Story, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(story)

    conn
    |> put_flash(:info, "Story deleted successfully.")
    |> redirect(to: story_path(conn, :index))
  end
end
