defmodule Chatty.Repo.Migrations.CreateFeed do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :name, :string
      add :url, :string
      add :last_fetched_at, :datetime
      add :etag, :string

      timestamps
    end

  end
end
