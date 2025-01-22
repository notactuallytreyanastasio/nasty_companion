defmodule NastyClone.Bookmarks do
  alias NastyClone.Repo
  alias NastyClone.Bookmarks.Bookmark
  alias Tag
  alias Cache

  def get(id), do: Repo.get!(Bookmark, id) |> Repo.preload(:tags)

  def create(attrs \\ %{}, tags) do
    # TODO tags
    bookmark =
      %Bookmark{}
      |> Bookmark.changeset(attrs)
      |> Repo.insert!()

    # we broadcast here, which will be picked up in anywhere
    # where we tell it to subscribe in the application, and
    # now can handle those messages in handle_info functions
    Phoenix.PubSub.broadcast(NastyClone.PubSub, "bookmarks", {:bookmark_created, bookmark, tags})
    bookmark
  end
end
