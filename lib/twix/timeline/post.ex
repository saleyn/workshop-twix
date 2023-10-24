defmodule Twix.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post" do
    field :body, :string
    field :username, :string, default: System.get_env("USER")
    field :likes_count, :integer, default: 0
    field :repost_count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 2, max: 256)
  end
end
