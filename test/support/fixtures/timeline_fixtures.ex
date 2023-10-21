defmodule Twix.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Twix.Timeline` context.
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
        repost_count: "some repost_count",
        username: "some username"
      })
      |> Twix.Timeline.create_post()

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
        repost_count: 42,
        username: "some username"
      })
      |> Twix.Timeline.create_post()

    post
  end
end
