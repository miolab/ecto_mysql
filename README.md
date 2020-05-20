# Ecto & MySQL

`Elixir`のDatabaseラッパーでありQueryジェネレータである`Ecto`で、いろいろお試しします。

- `MySQL`に連携し、データ作成・読み出し・更新・削除（= `CRUD`）操作を行っていきます。

- Ectoドライバーには`MyXQL`を使用します。（2020年5月20日時点における最新バージョンの`0.3.4`）

- `IEx`で動作確認をします。

### 実行環境

| | バージョン| 備考 |
| :-- | :-- | :-- |
| macOS | 10.14.6 | |
| MySQL | 5.7.29 | ローカル環境（localhost / rootユーザー / passwordなし） |
| Elixir | 1.9.2 | Erlang/OTP 22 |

### 参考

- [Ecto_SQL (Hex)](https://hex.pm/packages/ecto_sql)

- [Ecto (Hexdocs)](https://hexdocs.pm/ecto/Ecto.html)

  - こちらの[Getting Started](https://hexdocs.pm/ecto/getting-started.html)ドキュメントを参考としつつ、`MySQL`バージョンにアレンジして実装を進めていきます。
  （ドキュメント本家では`PostgreSQL`を使用）

- [MyXQL (Hex)](https://hex.pm/packages/myxql)

- [MyXQL (Hexdocs)](https://hexdocs.pm/myxql/0.3.4/readme.html)

---

## プロジェクト作成とEctoセットアップ

プロジェクト名を`friendsmysql`として、以下の通りセットアップしていきます。

- ターミナル

  ```bash
  $ mix new friendsmysql --sup
  * creating README.md
  * creating .formatter.exs
  * creating .gitignore
  * creating mix.exs
  * creating lib
  * creating lib/friendsmysql.ex
  * creating lib/friendsmysql/application.ex
  * creating test
  * creating test/test_helper.exs
  * creating test/friendsmysql_test.exs

  Your Mix project was created successfully.
  You can use "mix" to compile it, test it, and more:

      cd friendsmysql
      mix test

  Run "mix help" for more commands.
  ```

  ```bash
  $ cd friendsmysql
  ```

- mix.exs

  ```elixir:mix.exs
  defp deps do
    [
      {:ecto_sql, "~> 3.4"},    -> add
      {:myxql, "~> 0.4.0"}      -> add
  ```

- ターミナル

  ```bash
  $ mix deps.get
  Resolving Hex dependencies...
  Dependency resolution completed:
  New:
    connection 1.0.4
    db_connection 2.2.2
    decimal 1.8.1
    ecto 3.4.4
    ecto_sql 3.4.4
    myxql 0.4.0
    telemetry 0.4.1
  * Getting ecto_sql (Hex package)
  * Getting myxql (Hex package)
  * Getting db_connection (Hex package)
  * Getting decimal (Hex package)
  * Getting connection (Hex package)
  * Getting ecto (Hex package)
  * Getting telemetry (Hex package)
  ```

  ```bash
  $ mix ecto.gen.repo -r Friendsmysql.Repo
  ==> connection
  Compiling 1 file (.ex)
  Generated connection app
  ===> Compiling telemetry
  ==> decimal
  Compiling 1 file (.ex)
  Generated decimal app
  ==> db_connection
  Compiling 14 files (.ex)
  Generated db_connection app
  ==> ecto
  Compiling 55 files (.ex)
  Generated ecto app
  ==> myxql
  Compiling 15 files (.ex)
  Generated myxql app
  ==> ecto_sql
  Compiling 26 files (.ex)
  Generated ecto_sql app
  ==> friendsmysql
  * creating lib/friendsmysql
  * creating lib/friendsmysql/repo.ex
  * creating config/config.exs
  Don't forget to add your new repo to your supervision tree
  (typically in lib/friendsmysql/application.ex):

      {Friendsmysql.Repo, []}

  And to add it to the list of ecto repositories in your
  configuration files (so Ecto tasks work as expected):

      config :friendsmysql,
        ecto_repos: [Friendsmysql.Repo]

  ```

- config/config.exs

  ```elixir:config/config.exs
  config :friendsmysql, Friendsmysql.Repo,
    adapter: Ecto.Adapters.MyXQL,          --> add
    database: "friendsmysql_repo",
    username: "root",                      --> update
    password: "",                          --> update
    hostname: "localhost"                  --> update

  config :friendsmysql,                    --> add
    ecto_repos: [Friendsmysql.Repo]        --> add
  ```

- lib/friendsmysql/application.ex

  ```elixir:lib/friends/application.ex
  def start(_type, _args) do
    children = [
      Friendsmysql.Repo,        --> add
  ```

  ```elixir:lib/friendsmysql/repo.ex
  defmodule Friendsmysql.Repo do
    use Ecto.Repo,
      otp_app: :friendsmysql,
      adapter: Ecto.Adapters.MyXQL
  end
  ```

- ターミナル

  ```
  $ mix ecto.create
  Compiling 3 files (.ex)
  Generated friendsmysql app
  The database for Friendsmysql.Repo has been created
  ```

  - 結果確認（DB）

    ```mysql
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    |  .                 |
    |  .                 |
    | friendsmysql_repo  |
    |  .                 |
    |  .                 |

    ```



---
---
# on going
