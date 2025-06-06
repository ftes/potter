defmodule Potter.Repo do
  use Ecto.Repo,
    otp_app: :potter,
    adapter: Ecto.Adapters.Postgres
end
