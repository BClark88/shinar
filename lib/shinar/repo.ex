defmodule Shinar.Repo do
  use Ecto.Repo,
    otp_app: :shinar,
    adapter: Ecto.Adapters.SQLite3
end
