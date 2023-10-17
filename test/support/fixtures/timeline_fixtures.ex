defmodule Chirp.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chirp.Timeline` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        likes_count: "some likes_count",
        repos_count: "some repos_count",
        username: "some username"
      })
      |> Chirp.Timeline.create_post()

    post
  end

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        likes_count: 42,
        repos_count: 42,
        username: "some username"
      })
      |> Chirp.Timeline.create_post()

    post
  end
end
