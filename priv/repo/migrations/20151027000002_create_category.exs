defmodule Chatty.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :order, :integer
      add :published, :boolean, default: false

      timestamps
    end

  end
end
