defmodule NastyClone.Bookmarks.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :title, :string
    field :description, :string
    field :url, :string
    field :public, :boolean, default: true

    belongs_to :user, NastyClone.Accounts.User
    many_to_many :tags, NastyClone.Bookmarks.Tag, join_through: NastyClone.Bookmarks.BookmarkTag

    timestamps()
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:title, :description, :url, :public])
    |> cast_assoc(:tags)
    |> validate_required([:title, :url])
    |> validate_url(:url)
  end

  def new_changeset do
    %__MODULE__{
      public: true,
      tags: []
    }
    |> changeset(%{})
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, url ->
      case URI.parse(url) do
        %URI{scheme: scheme, host: host} when not is_nil(scheme) and not is_nil(host) ->
          []

        _ ->
          [{field, "must be a valid URL"}]
      end
    end)
  end
end
