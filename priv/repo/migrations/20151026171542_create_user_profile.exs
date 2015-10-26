defmodule Chatty.Repo.Migrations.CreateUserProfile do
  use Ecto.Migration

  def change do
    create table(:user_profiles) do
      add :user_id, :integer
      add :name, :string
      add :location, :string
      add :bio, :text

      timestamps
    end

  end
end
