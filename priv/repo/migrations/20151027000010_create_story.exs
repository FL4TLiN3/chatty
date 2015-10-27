defmodule Chatty.Repo.Migrations.CreateStory do
  use Ecto.Migration

  def change do
    create table(:stories) do
      add :title, :string
      add :original_link, :string
      add :cover, :string
      add :published_at, :datetime
      add :description, :text
      add :category_id, :integer

      timestamps
    end

  end
end
