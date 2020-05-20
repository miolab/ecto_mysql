defmodule Friendsmysql.Repo do
  use Ecto.Repo,
    otp_app: :friendsmysql,
    adapter: Ecto.Adapters.MyXQL
end
