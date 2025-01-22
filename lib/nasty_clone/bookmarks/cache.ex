defmodule NastyClone.Bookmarks.Cache do
  use GenServer
  require Logger
  alias NastyClone.Bookmarks.Bookmark

  @table_name :bookmarks_cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Phoenix.PubSub.subscribe(NastyClone.PubSub, "bookmarks")
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    {:ok, %{table: table}}
  end

  def handle_info({:bookmark_created, bookmark, _tags}, state) do
    # TODO tags
    key = Ecto.UUID.generate()
    :ets.insert(@table_name, {key, bookmark})
    {:noreply, state}
  end
end
