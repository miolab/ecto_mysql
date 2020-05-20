import Config

config :friendsmysql, Friendsmysql.Repo,
  adapter: Ecto.Adapters.MyXQL,
  database: "friendsmysql_repo",
  username: "root",
  password: "",
  hostname: "localhost"

config :friendsmysql,
  ecto_repos: [Friendsmysql.Repo]