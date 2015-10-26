defmodule Chatty.UserProfile do
  use Chatty.Web, :model

  schema "user_profiles" do
    field :user_id, :integer
    field :name, :string
    field :location, :string
    field :bio, :string

    timestamps
  end

  @required_fields ~w(user_id)
  @optional_fields ~w(name location bio)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def set_user_id(model, id) do
    model
    |> Ecto.Changeset.put_change(:user_id, id)
  end
end
