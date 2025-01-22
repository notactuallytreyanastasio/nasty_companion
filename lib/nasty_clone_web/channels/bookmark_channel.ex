defmodule NastyCloneWeb.BookmarkChannel do
  use NastyCloneWeb, :channel

  @impl true
  def join("bookmarks:firehose", _payload, socket) do
    Phoenix.PubSub.subscribe(NastyClone.PubSub, "bookmarks")
    {:ok, socket}
  end

  @impl true
  def handle_info({:bookmark_created, bookmark, tags}, socket) do
    broadcast_bookmark = %{
      id: bookmark.id,
      title: bookmark.title,
      description: bookmark.description,
      url: bookmark.url,
      public: bookmark.public,
      tags: tags,
      inserted_at: bookmark.inserted_at
    }

    push(socket, "bookmark_created", broadcast_bookmark)
    {:noreply, socket}
  end
end
