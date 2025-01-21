defmodule NastyClone.Bookmarks.Cache do
  use GenServer
  require Logger

  @table_name :bookmarks_cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Lol, maybe we store these as key-values with a query
  # params relation irl or something, this is a bit crude
  # it could also just key on a UUID and then let us have
  # all the dupes in the world etc
  def init(_) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    {:ok, %{table: table}}
  end

  def handle_cast({:create_bookmark, attrs, tags}, state) do
    key = Ecto.UUID.generate()
    :ets.insert(@table_name, {key, attrs})
    :ets.tab2list(@table_name)
    {:noreply, state}
  end

  # Server callbacks
  def handle_cast({:update_bookmark, key, attrs}, state) do
    :ets.insert(@table_name, {key, attrs})
    {:noreply, state}
  end
end
