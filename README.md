# Ecto & MySQL

`Elixir` の __Databaseラッパー__ であり __Queryジェネレータ__ である `Ecto` で、いろいろお試しします。

- `MySQL` に連携し、データ作成・読み出し・更新・削除（= `CRUD`）操作を行います。

### 実行環境

| | バージョン| 備考 |
| :-- | :-- | :-- |
| macOS | 10.14.6 | |
| MySQL | 5.7.29 | ローカル環境（localhost / rootユーザー / passwordなし） |
| Elixir | 1.9.2 | Erlang/OTP 22 |

### 参考

- [Ecto_SQL (Hex)](https://hex.pm/packages/ecto_sql)

- [Ecto (Hexdocs)](https://hexdocs.pm/ecto/Ecto.html)

  - [Getting Started](https://hexdocs.pm/ecto/getting-started.html) のドキュメントを参考としつつ、`MySQL` バージョンへアレンジして実装を進めていきます。（ドキュメントでは `PostgreSQL` を使用）

ーーー

## プロジェクト作成とEctoセットアップ

プロジェクト名を `friendsmysql` としてセットアップしていきます。

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
  $ cd friendsmysql/
  ```
