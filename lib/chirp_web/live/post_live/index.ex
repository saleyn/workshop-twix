defmodule ChirpWeb.PostLive.Index do
  use ChirpWeb, :live_view

  alias Chirp.Timeline
  alias Chirp.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    socket =
      socket
      |> stream_configure(:post_collection, dom_id: &"post-#{&1.id}")
      |> stream(:post_collection, Timeline.list_post())
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {title, post} =
      case socket.assigns.live_action do
        :index -> {"Listing Post", nil}
        :new   -> {"New Post",     %Post{}}
        :edit  -> {"Edit Post",    Timeline.get_post!(params["id"])}
      end
    {:noreply, socket |> assign(:page_title, title) |> assign(:post, post)}
  end

  @impl true
  def handle_info({ChirpWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :post_collection, post)}
  end

  def handle_info({:post_created, post}, socket) do
    IO.puts("Inserting new post #{post.id}")
    {:noreply, stream_insert(socket, :post_collection, post, at: 0) |> tap(& IO.inspect(&1.assigns.streams.post_collection))}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, stream_insert(socket, :post_collection, post, at: -1)}
  end

  def handle_info({:post_deleted, post}, socket) do
    {:noreply, stream_delete(socket, :post_collection, post)}
  end

end
