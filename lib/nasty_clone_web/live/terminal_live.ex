defmodule NastyCloneWeb.TerminalLive do
  use NastyCloneWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(NastyClone.PubSub, "bookmarks")
    end

    {:ok, assign(socket,
      bookmarks: [],
      cursor_visible: true
    )}
  end

  @impl true
  def handle_info({:bookmark_created, bookmark, tags}, socket) do
    timestamp = DateTime.utc_now() |> DateTime.to_string() |> String.slice(0..18)
    entry = %{
      timestamp: timestamp,
      bookmark: bookmark,
      tags: tags
    }

    # Keep only the last 20 bookmarks
    updated_bookmarks = Enum.take([entry | socket.assigns.bookmarks], 20)

    {:noreply, assign(socket, bookmarks: updated_bookmarks)}
  end
end
