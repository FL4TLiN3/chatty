defmodule Chatty.User do
  use Chatty.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :github_access_token, :string
    field :twitter_access_token, :string
    field :facebook_access_token, :string
    field :access_secret, :string
    field :access_secret_generated_at, Ecto.DateTime
    field :access_token, :string
    field :access_token_expires_at, Ecto.DateTime

    timestamps
  end

  @required_fields ~w(email)
  @optional_fields ~w(name password github_access_token twitter_access_token facebook_access_token access_secret access_secret_generated_at access_token access_token_expires_at)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
    |> crypto(params)
  end

  def crypto(model, %{"password" => password}) do
    conf = Mix.Config.read!("config/config.exs")
    model
    |> Ecto.Changeset.put_change(
      :password,
      :crypto.hash(:sha256, [password, conf[:smaug][:hash_salt]]) |> Base.encode16)
  end

  def crypto(model, _params), do: model
end
