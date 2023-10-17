defmodule TwixWeb.PostLive.Index do
  use TwixWeb, :live_view

  alias Twix.Timeline
  alias Twix.Timeline.Post

  @page_limit 25
  @client_max_pages 2

  # For progressive pagination see:
  # https://hexdocs.pm/phoenix_live_view/bindings.html#scroll-events-and-infinite-stream-pagination

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    offset = 0
    posts  = Timeline.list_posts(offset: offset, limit: @page_limit)
    socket =
      socket
      |> assign(:offset, offset)
      |> assign(:limit, @page_limit)
      |> assign(:end_of_timeline, length(posts) < @page_limit)
      |> stream_configure(:posts, dom_id: &"post-#{&1.id}")
      |> stream(:posts, posts, at: 0)
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
    {:noreply, assign(socket, page_title: title, post: post)}
  end

  @impl true
  def handle_info({TwixWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  def handle_info({TwixWeb.PostLive.PostComponent, {:deleted, post}}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end

  def handle_info({:timeline, pid, _event, _msg}, socket) when pid == self(), do:
    {:noreply, socket}

  def handle_info({:timeline, _, :post_created, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  def handle_info({:timeline, _, :post_updated, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  def handle_info({:timeline, _, :post_deleted, post}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_event("next-page", _, socket) do
    socket =
      socket
      #|> update(:offset, & &1 + socket.assigns.limit)
      #|> stream_new_posts()
      |> paginate_posts(socket.assigns.offset + socket.assigns.limit)
    {:noreply, socket}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.offset > 0 do
      {:noreply, paginate_posts(socket, max(0, socket.assigns.offset - socket.assigns.limit))}
    else
      {:noreply, socket}
    end
  end

  defp paginate_posts(socket, new_offset) when new_offset >= 0 do
    %{offset: offset, limit: limit} = socket.assigns
    posts = Timeline.list_posts(offset: new_offset, limit: limit)
    len   = length(posts)
    new_offset = new_offset >= offset && offset + len || offset - len
    {posts, at, limit} =
      if new_offset >= offset do
        {posts, -1, -limit * @client_max_pages}
      else
        {Enum.reverse(posts), 0, limit * @client_max_pages}
      end

    case posts do
      [] ->
        assign(socket, end_of_timeline: new_offset == offset)
      _ ->
        socket
        |> assign(end_of_timeline: false, offset: new_offset)
        |> stream(:posts, posts, at: at, limit: limit)
    end
  end
end
