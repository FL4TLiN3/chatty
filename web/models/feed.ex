defmodule Chatty.Feed do
  use Chatty.Web, :model

  schema "feeds" do
    field :name, :string
    field :url, :string
    field :last_fetched_at, Ecto.DateTime
    field :etag, :string

    timestamps
  end

  @required_fields ~w(name url)
  @optional_fields ~w(last_fetched_at etag)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
