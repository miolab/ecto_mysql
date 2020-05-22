# ElixirでMySQLを使う（Ecto / MyXQL）

`Elixir`のDatabaseラッパーでありQueryジェネレータである`Ecto`で、いろいろお試しします。

- `MySQL`に連携し、データ作成・読み出し・更新・削除（= `CRUD`）操作を行っていきます。

- Ectoアダプタには`MyXQL`を使用します。（2020年5月20日時点における最新バージョンの`0.3.4`）

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

    データベース`friendmysql_repo` が作成できています！

---

## DBセットアップ（マイグレーション 〜 テーブル作成）

Ectoでマイグレーションを実行していきます。  
マイグレーションをつくることで、データベース内のテーブル及びインデックスの作成や更新をする仕組みを整えていきます。

- bash

  ```terminal:terminal
  $ mix ecto.gen.migration create_people
  * creating priv/repo/migrations
  * creating priv/repo/migrations/20200521003013_create_people.exs
  ```

- priv/repo/migrations/20200521003013_create_people.exs

  ```priv/repo/migrations/20200521003013_create_people.exs
  def change do
    create table(:people) do    --> add
      add :first_name, :string  --> add
      add :last_name, :string   --> add
      add :age, :integer        --> add
    end
  end
  ```

- bash

  ```terminal:terminal
  $ mix ecto.migrate

  09:32:21.356 [info]  == Running 20200521003013 Friendsmysql.Repo.Migrations.CreatePeople.change/0 forward

  09:32:21.358 [info]  create table people

  09:32:21.370 [info]  == Migrated 20200521003013 in 0.0s
  ```

### 結果確認（テーブル）

```terminal:mysql
mysql> show tables;
+-----------------------------+
| Tables_in_friendsmysql_repo |
+-----------------------------+
| people                      |
| schema_migrations           |
+-----------------------------+
2 rows in set (0.00 sec)

mysql> desc people;
+------------+---------------------+------+-----+---------+----------------+
| Field      | Type                | Null | Key | Default | Extra          |
+------------+---------------------+------+-----+---------+----------------+
| id         | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
| first_name | varchar(255)        | YES  |     | NULL    |                |
| last_name  | varchar(255)        | YES  |     | NULL    |                |
| age        | int(11)             | YES  |     | NULL    |                |
+------------+---------------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)
```

- Ectoでの __テーブル作成__ に成功しました。

- （メモ）

  - マイグレーションでミスがあった場合、mix ecto.rollback で変更を元に戻すことが可能。  
  （その後、変更修正してから、再度 mix ecto.createを実行する）

  - この段階で mix ecto.rollback すると、いま作成したばかりのテーブルを削除可能。

---

## レコード作成（Create）

- insert()

### スキーマ作成

- ファイル新規作成： lib/friends/person.ex

  ```elixir:lib/friends/person.ex
  defmodule Friendsmysql.Person do
    use Ecto.Schema

    schema "people" do
      field :first_name, :string
      field :last_name, :string
      field :age, :integer
    end
  end
  ```

- `IEx` で検証していきます。

  ```terminal:terminal
  $ iex -S mix

  iex(1)> person = %Friendsmysql.Person{}
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: nil,
    first_name: nil,
    id: nil,
    last_name: nil
  }

  iex(2)> person = %Friendsmysql.Person{age: 28}
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: 28,
    first_name: nil,
    id: nil,
    last_name: nil
  }

  iex(3)> person.age
  28

  iex(4)> Friendsmysql.Repo.insert(person)

  09:39:55.834 [debug] QUERY OK db=0.9ms decode=0.8ms queue=1.8ms idle=321.1ms
  INSERT INTO `people` (`age`) VALUES (?) [28]
  {:ok,
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 28,
    first_name: nil,
    id: 1,
    last_name: nil
  }}

  iex(5)> im = %Friendsmysql.Person{first_name: "im", last_name: "miolab", age: 28}
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: 28,
    first_name: "im",
    id: nil,
    last_name: "miolab" 
  }

  iex(6)> Friendsmysql.Repo.insert(im)

  09:42:41.351 [debug] QUERY OK db=1.5ms queue=1.6ms idle=1841.3ms
  INSERT INTO `people` (`age`,`first_name`,`last_name`) VALUES (?,?,?) [28, "im", "miolab"]
  {:ok,
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 28,
    first_name: "im",
    id: 2,
    last_name: "miolab"
  }}
  ```

- なお、スキーマは構造体のため、以下のようにデータを扱うことができます。

  ```
  iex(7)> im.age
  28

  iex(8)> Map.get(im, :last_name)
  "miolab"
  ```

### 結果確認（テーブル）

  ```terminal:mysql
  mysql> select * from people;
  +----+------------+-----------+------+
  | id | first_name | last_name | age  |
  +----+------------+-----------+------+
  |  1 | NULL       | NULL      |   28 |
  |  2 | im         | miolab    |   28 |
  +----+------------+-----------+------+
  2 rows in set (0.00 sec)
  ```

## バリデーション機能実装（チェンジセット）

- lib/friendsmysql/person.ex の defmodule 内に、以下を追加

  ```elixir:lib/friendsmysql/person.ex
  def changeset(person, params \\ %{}) do
    person
    |> Ecto.Changeset.cast(params, [:first_name, :last_name, :age])
    |> Ecto.Changeset.validate_required([:first_name, :last_name])
  end
  ```

- `IEx` で検証していきます。(iex -S mix)

  （バリデーションエラー パターン）

  ```terminal:terminal
  iex(1)> person = %Friendsmysql.Person{}
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: nil,
    first_name: nil,
    id: nil,
    last_name: nil
  }

  iex(2)> changeset = Friendsmysql.Person.changeset(person, %{})
  #Ecto.Changeset<
    action: nil,
    changes: %{},
    errors: [
      first_name: {"can't be blank", [validation: :required]},
      last_name: {"can't be blank", [validation: :required]}
    ],
    data: #Friendsmysql.Person<>,
    valid?: false
  >

  iex(3)> Friendsmysql.Repo.insert(changeset)
  {:error,
  #Ecto.Changeset<
    action: :insert,
    changes: %{},
    errors: [
      first_name: {"can't be blank", [validation: :required]},
      last_name: {"can't be blank", [validation: :required]}
    ],
    data: #Friendsmysql.Person<>,
    valid?: false
  >}

  iex(4)> changeset.valid?
  false

  iex(5)> {:error, changeset} = Friendsmysql.Repo.insert(changeset)
  {:error,
  #Ecto.Changeset<
    action: :insert,
    changes: %{},
    errors: [
      first_name: {"can't be blank", [validation: :required]},
      last_name: {"can't be blank", [validation: :required]}
    ],
    data: #Friendsmysql.Person<>,
    valid?: false
  >}
  ```

  ちゃんと :error が返り、バリデーションが効いていることを確認できました。

- `$ iex -S mix` で検証 （サクセス パターン）

  ```
  iex(1)> person = %Friendsmysql.Person{}
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: nil,
    first_name: nil,
    id: nil,
    last_name: nil
  }

  iex(2)> changeset = Friendsmysql.Person.changeset(person, %{first_name: "Ryan", last_name: "Bigg"})  
  #Ecto.Changeset<
    action: nil,
    changes: %{first_name: "Ryan", last_name: "Bigg"},
    errors: [],
    data: #Friendsmysql.Person<>,
    valid?: true
  >

  iex(3)> changeset.errors
  []

  iex(4)> changeset.valid?
  true

  iex(5)> Friendsmysql.Repo.insert(changeset)

  09:59:25.465 [debug] QUERY OK db=3.7ms decode=1.2ms queue=2.5ms idle=1157.6ms
  INSERT INTO `people` (`first_name`,`last_name`) VALUES (?,?) ["Ryan", "Bigg"]
  {:ok,
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: nil,
    first_name: "Ryan",
    id: 3,
    last_name: "Bigg"
  }}
  ```

### 結果確認（テーブル）

  ```terminal:mysql
  mysql> select * from people;
  +----+------------+-----------+------+
  | id | first_name | last_name | age  |
  +----+------------+-----------+------+
  |  1 | NULL       | NULL      |   28 |
  |  2 | im         | miolab    |   28 |
  |  3 | Ryan       | Bigg      | NULL |
  +----+------------+-----------+------+
  3 rows in set (0.00 sec)
  ```


---
---
# on going
