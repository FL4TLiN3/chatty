defmodule Chatty.Story do
  use Chatty.Web, :model

  schema "stories" do
    field :title, :string
    field :cover, :string
    field :original_link, :string
    field :published_at, Ecto.DateTime
    field :description, :string

    belongs_to :category, Chatty.Category
    timestamps
  end

  @required_fields ~w(title)
  @optional_fields ~w(cover original_link published_at description category_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def category(query, %{ "category" => category }) do
    from story in query,
    join: category in assoc(story, :category),
    where: category.name == ^category,
    select: story
  end

  def category(query, _params) do
    from story in query,
    select: story
  end

  def paging(query, %{ "size" => size, "page" => page }) do
    size = String.to_integer size
    page = String.to_integer page

    from s in query, limit: ^size, offset: ^((page-1) * size)
  end

  def paging(query, _params) do
    from s in query, limit: 100, offset: 0
  end

  def order(query, _) do
    from s in query, order_by: [desc: s.published_at]
  end
end
