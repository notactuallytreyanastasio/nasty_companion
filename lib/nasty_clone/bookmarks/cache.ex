defmodule NastyClone.Bookmarks.Cache do
  use GenServer
  require Logger

  @table_name :bookmarks_cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    {:ok, %{table: table}}
  end

  def handle_cast({:create_bookmark, attrs, tags}, state) do
    key = Ecto.UUID.generate()
    bookmark = %Bookmark{
      title: attrs["title"],
      description: attrs["description"],
      url: attrs["url"],
      public: attrs["public"]
      # TODO tags
      # tags: tags
    }
    :ets.insert(@table_name, {key, bookmark})
    {:noreply, state}
  end

  def handle_cast({:update_bookmark, key, attrs}, state) do
    :ets.insert(@table_name, {key, attrs})
    {:noreply, state}
  end
end
