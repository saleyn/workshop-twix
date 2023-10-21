defmodule Twix.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:post) do
      add :username,    :string
      add :body,        :string
      add :likes_count, :integer
      add :repost_count, :integer

      timestamps(type:  :naive_datetime)
    end
  end
end
