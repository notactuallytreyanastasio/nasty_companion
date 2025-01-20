defmodule NastyClone.Repo do
  use Ecto.Repo,
    otp_app: :nasty_clone,
    adapter: Ecto.Adapters.Postgres
end
