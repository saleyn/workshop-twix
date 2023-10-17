defmodule ChirpWeb.PostLive.PostComponent do
  use ChirpWeb, :live_component

  alias Chirp.Timeline

  def render(assigns) do
    ~H"""
    <div id={@id} class="post rounded border flex flex-col p-4 mt-2">
      <div class="flex">
        <div class="pr-2 pb-2">
          <img class="w-14 h-14 rounded-full" src="https://robohash.org/KDU.png?set=set2" alt="Avatar"/>
        </div>
        <div class="post-body">
          <b>@<%= @post.username %></b> (<%= @post.id %>)
          <br/>
          <.link navigate={~p"/posts/#{@post.id}"}><%= @post.body %></.link>
        </div>
      </div>
      <div class="flex gap-2 w-full place-content-between">
        <div class="flex gap-5">
          <div><.link phx-click="like" phx-target={@myself}>
            <.icon name={@post.likes_count > 0 && "hero-heart-solid" || "hero-heart"} class={@post.likes_count > 0 && "text-red-600"}/>
          </.link> <%= @post.likes_count %></div>
          <div><.link phx-click="repost" phx-target={@myself}><.icon name="hero-arrow-path"/></.link> <%= @post.repos_count %></div>
        </div>
        <div class="sr-only">
          <.link navigate={~p"/posts/#{@post.id}"}>Show</.link>
        </div>
        <div class="">
          <.link patch={~p"/posts/#{@post.id}/edit"}><.icon name="hero-pencil-square" class="w-6 h-6 text-green-600" title="Edit"/></.link>
          <.link
            phx-click="delete" phx-target={@myself}
            data-confirm="Are you sure?"
          >
            <.icon name="hero-x-circle" class="w-6 h-6 text-red-500" title="Delete"/>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("delete", _, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)
    {:ok, _} = Timeline.delete_post(post)
    {:noreply, socket}
  end

  def handle_event("like", _, socket) do
    Timeline.inc_likes(socket.assigns.post.id)
    {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    Timeline.inc_reposts(socket.assigns.post.id)
    {:noreply, socket}
  end
end
