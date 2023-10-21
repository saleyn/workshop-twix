defmodule TwixWeb.PostLive.PostComponent do
  use TwixWeb, :live_component

  alias Twix.Timeline

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:updated_at, format_time(assigns.post.updated_at))
      |> assign(:likes_icon, assigns.post.likes_count > 0 && "hero-heart-solid" || "hero-heart")
      |> assign(:likes_class, assigns.post.likes_count > 0 && "text-red-600")
      |> assign(:robot_icon, Integer.to_string(Kernel.rem(100 + assigns.post.id, 10)))
    ~H"""
    <div class="rounded border flex flex-col p-4 mt-2 bg-slate-50">
      <div class="flex">
        <div class="pr-2 pb-2">
          <img class="w-14 h-14 rounded-full bg-gray-300" src={"https://robohash.org/#{@robot_icon}.png?set=set3"} alt="Avatar"/>
        </div>
        <div class="w-full">
          <div class="flex place-content-between w-full">
            <div class="bg-blue-100 rounded-lg px-1"><b>@<%= @post.username %></b></div>
            <div><%= @updated_at %></div>
          </div>
          <div><.link navigate={~p"/posts/#{@id}"}><pre><%= @post.body %></pre></.link></div>
        </div>
      </div>
      <div class="flex gap-2 w-full place-content-between">
        <div class="flex gap-5">
          <div><.link phx-click="like" phx-target={@myself}><.icon name={@likes_icon} class={@likes_class} title="Like"/></.link> <%= @post.likes_count %></div>
          <div><.link phx-click="repost" phx-target={@myself}><.icon name="hero-arrow-path" title="Repost"/></.link> <%= @post.repos_count %></div>
        </div>
        <div>
          <.link patch={~p"/posts/#{@id}/edit"}><.icon name="hero-pencil-square" class="w-6 h-6 text-green-600" title="Edit"/></.link>
          <.link phx-click="delete" phx-target={@myself} data-confirm="Are you sure?">
            <.icon name="hero-trash" class="w-6 h-6 text-red-400" title="Delete"/>
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
    send(self(), {__MODULE__, {:deleted, post}})
    {:noreply, socket}
  end

  def handle_event("like", _, socket) do
    {:ok, post} = Timeline.inc_likes(socket.assigns.post.id)
    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("repost", _, socket) do
    {:ok, post} = Timeline.inc_reposts(socket.assigns.post.id)
    {:noreply, assign(socket, :post, post)}
  end

  def format_time(ts) do
    ts
    |> NaiveDateTime.to_erl()
    |> :erlang.universaltime_to_localtime()
    |> then(fn {{yy, mm, dd}, {h, m, s}} ->
      :io_lib.format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w", [yy, mm, dd, h, m, s])
    end)
  end

end
