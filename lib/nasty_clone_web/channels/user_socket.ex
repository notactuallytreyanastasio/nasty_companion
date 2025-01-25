defmodule NastyCloneWeb.UserSocket do
  use Phoenix.Socket

  # Channels
  channel "bookmarks:firehose", NastyCloneWeb.BookmarkChannel
  channel "bookmarks:tag:*", NastyCloneWeb.TagChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
