defmodule Twix.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Twix.Repo

  alias Twix.Timeline.Post

  @doc """
  Returns the list of post.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(opts \\ []) do
    offset = Keyword.get(opts, :offset, 0)
    limit  = Keyword.get(opts, :limit, nil)
    # NULL limit is unlimited
    Repo.all(from p in Post, order_by: [desc: p.id], offset: ^offset, limit: ^limit)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:post_created)
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update(set: [updated_at: NaiveDateTime.utc_now()])
    |> broadcast(:post_updated)
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
    |> broadcast(:post_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Twix.PubSub, "posts")
  end

  defp broadcast({:ok, post} = msg, event) do
    Phoenix.PubSub.broadcast(Twix.PubSub, "posts", {:timeline, self(), event, post})
    msg
  end
  defp broadcast({:error, _} = msg, _event), do: msg

  def inc_likes(id) do
    {1, [post]} =
      from(p in Post, where: p.id == ^id, select: p)
      |> Repo.update_all(inc: [likes_count: 1], set: [updated_at: NaiveDateTime.utc_now()])
    broadcast({:ok, post}, :post_updated)
  end

  def inc_reposts(id) do
    {1, [post]} =
      from(p in Post, where: p.id == ^id, select: p)
      |> Repo.update_all(inc: [repost_count: 1], set: [updated_at: NaiveDateTime.utc_now()])
    broadcast({:ok, post}, :post_updated)
  end
end
