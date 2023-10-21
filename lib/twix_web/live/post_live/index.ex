defmodule TwixWeb.PostLive.Index do
  use TwixWeb, :live_view

  alias Twix.Timeline
  alias Twix.Timeline.Post

  @page_limit Application.compile_env(Application.get_application(__MODULE__), :page_limit, 25)
  @client_max_pages Application.compile_env(Application.get_application(__MODULE__), :client_max_pages, 2)

  # For progressive pagination see:
  # https://hexdocs.pm/phoenix_live_view/bindings.html#scroll-events-and-infinite-stream-pagination

  @doc "Notify this liveview of the update of the post"
  @spec notify(:post_created | :post_updated | :post_deleted, %Post{}) :: any()
  def notify(event, post) when event in [:post_created, :post_updated, :post_deleted], do:
    send(self(), {:timeline, nil, event, post})

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    offset = 0
    {:ok,
      socket
      |> assign(offset: offset, limit: @page_limit)
      |> stream_configure(:posts, dom_id: &"post-#{&1.id}")
      |> paginate_posts(1)
    }
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
  def handle_info({:timeline, pid, _event, _msg}, socket) when pid == self(), do:
    {:noreply, socket}

  def handle_info({:timeline, _, event, post}, socket) do
    case event do
      :post_created -> {:noreply, stream_insert(socket, :posts, post, at: 0)}
      :post_updated -> {:noreply, stream_insert(socket, :posts, post)}
      :post_deleted -> {:noreply, stream_delete(socket, :posts, post)}
    end
  end

  @impl true
  def handle_event("next-page", _, socket) do
    {:noreply, paginate_posts(socket, 1)}
  end

  def handle_event("prev-page", _, socket) do
    {:noreply, paginate_posts(socket, -1)}
  end

  defp paginate_posts(%{assigns: %{offset: old_offset, limit: limit}} = socket, pages) when pages in [-1, 1] do
    offset      = pages < 0 && max(old_offset-limit,  0) || old_offset
    count       = pages < 0 && max(old_offset-offset, 0) || limit

    posts       = Timeline.list_posts(offset: offset, limit: count)
    len         = length(posts)

    new_offset  = max(0, old_offset + pages*len)
    {posts, at} = pages > 0 && {posts, -1} || {Enum.reverse(posts), 0}

    socket
    |> assign(end_of_timeline: new_offset == old_offset, offset: new_offset)
    |> stream(:posts, posts, at: at, limit: -pages * limit * @client_max_pages)
  end
end
