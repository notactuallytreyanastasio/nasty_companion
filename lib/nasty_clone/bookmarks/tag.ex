defmodule NastyClone.Bookmarks.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    many_to_many :bookmarks, NastyClone.Bookmarks.Bookmark, join_through: NastyClone.Bookmarks.BookmarkTag

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> update_change(:name, &String.downcase/1)
  end
end
