defmodule NastyCloneWeb.TagChannel do
  use NastyCloneWeb, :channel
  require Logger

  @impl true
  def join("bookmarks:tag:" <> tag_name, _payload, socket) do
    # Subscribe to the firehose to filter messages
    Phoenix.PubSub.subscribe(NastyClone.PubSub, "firehose")

    # Store the tag name in socket assigns for filtering
    {:ok, assign(socket, :tag, String.downcase(tag_name))}
  end

  @impl true
  def handle_info({:bookmark_created, bookmark, tags}, socket) do
    # Only push if the bookmark has the tag we're interested in
    if tag_matches?(tags, socket.assigns.tag) do
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
    end

    {:noreply, socket}
  end

  defp tag_matches?(tags, tag) when is_list(tags) do
    Enum.any?(tags, &(String.downcase(&1) == tag))
  end
end
