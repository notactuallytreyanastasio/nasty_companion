defmodule NastyClone.Bookmarks do
  alias NastyClone.Repo
  alias NastyClone.Bookmarks.{Bookmark, Tag, BookmarkTag}
  import Ecto.Query
  # alias NastyClone.Bookmarks.Cache

  def get(id), do: Repo.get!(Bookmark, id) |> Repo.preload(:tags)

  def create(attrs \\ %{}, tags_string) when is_binary(tags_string) do
    # Start a transaction since we're doing multiple operations
    Repo.transaction(fn ->
      # First create the bookmark
      case %Bookmark{}
           |> Bookmark.changeset(attrs)
           |> Repo.insert() do
        {:ok, bookmark} ->
          # Process tags and create associations
          tags = process_tags(tags_string)

          # Create bookmark_tag associations
          bookmark_with_tags = associate_tags(bookmark, tags)

          # Broadcast with the processed tag names
          tag_names = Enum.map(tags, & &1.name)
          Phoenix.PubSub.broadcast(
            NastyClone.PubSub,
            "firehose",
            {:bookmark_created, bookmark_with_tags, tag_names}
          )

          bookmark_with_tags

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  # Split tags string and process each tag
  defp process_tags(tags_string) do
    tags_string
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&create_or_get_tag/1)
  end

  # Create or get existing tag
  defp create_or_get_tag(name) do
    name = String.downcase(name)

    case Repo.get_by(Tag, name: name) do
      nil ->
        # Create new tag if it doesn't exist
        {:ok, tag} = %Tag{}
                    |> Tag.changeset(%{name: name})
                    |> Repo.insert()

        # Broadcast tag creation
        Phoenix.PubSub.broadcast(
          NastyClone.PubSub,
          "tags",
          {:tag_created, tag}
        )

        tag

      tag -> tag
    end
  end

  # Associate tags with bookmark
  defp associate_tags(bookmark, tags) do
    # Create BookmarkTag records for each tag
    Enum.each(tags, fn tag ->
      %BookmarkTag{}
      |> BookmarkTag.changeset(%{
        bookmark_id: bookmark.id,
        tag_id: tag.id
      })
      |> Repo.insert!()
    end)

    # Return bookmark with preloaded tags
    Repo.preload(bookmark, :tags)
  end
end
