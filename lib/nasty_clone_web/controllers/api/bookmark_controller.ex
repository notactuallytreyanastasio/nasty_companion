defmodule NastyCloneWeb.Api.BookmarkController do
  use NastyCloneWeb, :controller

  alias NastyClone.Bookmarks

  def create(conn, %{"bookmark" => bookmark_params}) do
    # Extract tags from params or default to empty list
    tags = Map.get(bookmark_params, "tags", [])

    # Create the bookmark
    bookmark = Bookmarks.create(bookmark_params, tags)
    resp = %{
      data: %{
        id: bookmark.id,
        title: bookmark.title,
        description: bookmark.description,
        url: bookmark.url,
        public: bookmark.public,
        inserted_at: bookmark.inserted_at
      },
      message: "Bookmark created successfully"
    }

    conn
    |> put_status(:created)
    |> json(%{bookmark: resp})
  end

  # Add a fallback for invalid params
  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Invalid parameters. Expected 'bookmark' object in request body"})
  end
end
