defmodule Smaug.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :name, :string
      add :password, :string
      add :github_access_token, :string
      add :twitter_access_token, :string
      add :facebook_access_token, :string
      add :access_secret, :string
      add :access_secret_generated_at, :datetime
      add :access_token, :string
      add :access_token_expires_at, :datetime

      timestamps
    end

  end
end
