defmodule NastyClone.Bookmarks.Simulator do
  use GenServer
  require Logger
  alias NastyClone.Bookmarks

  @interval 2_000 # 2 seconds between bookmarks = ~30 per minute
  @adjectives ~w(Amazing Brilliant Clever Dynamic Elegant Fantastic Great Helpful Innovative Joyful)
  @nouns ~w(Tutorial Guide Project Framework Library Tool Resource Platform Service Application)
  @topics ~w(Elixir Phoenix JavaScript React Vue Angular Ruby Python Go Rust)

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_next_bookmark()
    {:ok, %{count: 0}}
  end

  # make it use the link generator above...
  @impl true
  def handle_info(:create_bookmark, state) do
    create_random_bookmark()
    schedule_next_bookmark()
    {:noreply, %{state | count: state.count + 1}}
  end

  defp schedule_next_bookmark do
    Process.send_after(self(), :create_bookmark, @interval)
  end

  defp create_random_bookmark do
    LinkGenerator
    adjective = Enum.random(@adjectives)
    noun = Enum.random(@nouns)
    topic = Enum.random(@topics)

    title = "#{adjective} #{topic} #{noun}"
    description = "A #{String.downcase(adjective)} #{String.downcase(noun)} for #{topic} developers"
    url = generate_url(title)

    bookmark_params = %{
      "title" => title,
      "description" => description,
      "url" => url,
      "public" => true
    }

    tags = [topic, String.downcase(noun)]

    case Bookmarks.create(bookmark_params, tags) do
      %{id: id} ->
        Logger.info("Created simulated bookmark: #{title} (ID: #{id})")
      _ ->
        Logger.error("Failed to create simulated bookmark: #{title}")
    end
  end

  defp generate_url(title) do
    slug = title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "-")

    domains = [
      "example.com",
      "tutorial-site.dev",
      "learn-tech.io",
      "codebase.edu",
      "dev-resources.net"
    ]

    "https://#{Enum.random(domains)}/#{slug}"
  end
end
