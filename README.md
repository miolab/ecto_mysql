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

- なお、スキーマは構造体であり、以下のようにデータを扱うことができます。

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

# CRUD & クエリ作成

（事前準備）データベース再作成

- 事前準備として、前回つくったデータベースを削除して、あたらしく作り直します。

  ```terminal:terminal
  $ mix ecto.drop
  Compiling 1 file (.ex)
  The database for Friendsmysql.Repo has been dropped
  ```

  ```terminal:terminal
  $ mix ecto.create
  The database for Friendsmysql.Repo has been created
  ```

  ```terminal:terminal
  $ mix ecto.migrate

  13:36:23.224 [info]  == Running 20200521003013 Friendsmysql.Repo.Migrations.CreatePeople.change/0 forward

  13:36:23.226 [info]  create table people

  13:36:23.241 [info]  == Migrated 20200521003013 in 0.0s

  13:36:23.265 [info]  == Running 20200522004701 Friendsmysql.Repo.Migrations.ApplyNotnullToNames.change/0 forward

  13:36:23.265 [info]  alter table people

  13:36:23.278 [info]  == Migrated 20200522004701 in 0.0s
  ```

- 結果確認（MySQL）

  ```terminal:terminal(MySQL)
  mysql> desc people;
  +------------+---------------------+------+-----+---------+----------------+
  | Field      | Type                | Null | Key | Default | Extra          |
  +------------+---------------------+------+-----+---------+----------------+
  | id         | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
  | first_name | varchar(255)        | NO   |     | NULL    |                |
  | last_name  | varchar(255)        | NO   |     | NULL    |                |
  | age        | int(11)             | YES  |     | NULL    |                |
  +------------+---------------------+------+-----+---------+----------------+
  4 rows in set (0.00 sec)

  mysql> select * from people;
  Empty set (0.00 sec)
  ```

  データベースと、からっぽの`people`テーブルが準備できました。

# CRUD

それでは、CRUD操作を行っていきます。

## Create（データ作成）

- `Repo.insert()`

で、以下の計4レコードを渡していきます。

```terminal:terminal
iex(1)> people = [
...(1)> %Friendsmysql.Person{first_name: "Ryan", last_name: "Bigg", age: 28},
...(1)> %Friendsmysql.Person{first_name: "John", last_name: "Smith", age: 27},
...(1)> %Friendsmysql.Person{first_name: "Jane", last_name: "Smith", age: 26},
...(1)> %Friendsmysql.Person{first_name: "im", last_name: "miolab", age: 28},
...(1)> ]
[
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: 28,
    first_name: "Ryan",
    id: nil,
    last_name: "Bigg"
  },
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: 27,
    first_name: "John",
    id: nil,
    last_name: "Smith"
  },
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: 26,
    first_name: "Jane",
    id: nil,
    last_name: "Smith"
  },
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:built, "people">,
    age: 28,
    first_name: "im",
    id: nil,
    last_name: "miolab"
  }
]
```

`Enum.each`で`insert`していきます。

```terminal:terminal
iex(2)> Enum.each(people, fn(p) -> Friendsmysql.Repo.insert(p) end)

13:45:40.520 [debug] QUERY OK db=5.9ms decode=1.3ms queue=7.0ms idle=1457.6ms
INSERT INTO `people` (`age`,`first_name`,`last_name`) VALUES (?,?,?) [28, "Ryan", "Bigg"]

13:45:40.528 [debug] QUERY OK db=1.3ms queue=4.8ms idle=1475.8ms
INSERT INTO `people` (`age`,`first_name`,`last_name`) VALUES (?,?,?) [27, "John", "Smith"]

13:45:40.531 [debug] QUERY OK db=0.4ms queue=1.8ms idle=1482.1ms
INSERT INTO `people` (`age`,`first_name`,`last_name`) VALUES (?,?,?) [26, "Jane", "Smith"]
:ok

13:45:40.534 [debug] QUERY OK db=2.3ms queue=1.0ms idle=1484.5ms
INSERT INTO `people` (`age`,`first_name`,`last_name`) VALUES (?,?,?) [28, "im", "miolab"]
```

前回の記事みたいに、1件だけ`insert`実行するには、以下の通りです。

```terminal:terminal
iex(3)> iiii = %Friendsmysql.Person{first_name: "iiii", last_name: "mimimi", age: 18}
%Friendsmysql.Person{
  __meta__: #Ecto.Schema.Metadata<:built, "people">,
  age: 18,
  first_name: "iiii",
  id: nil,
  last_name: "mimimi"
}

iex(4)> Friendsmysql.Repo.insert(iiii)

13:46:54.648 [debug] QUERY OK db=2.5ms queue=3.0ms idle=1575.2ms
INSERT INTO `people` (`age`,`first_name`,`last_name`) VALUES (?,?,?) [18, "iiii", "mimimi"]
{:ok,
 %Friendsmysql.Person{
   __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
   age: 18,
   first_name: "iiii",
   id: 5,
   last_name: "mimimi"
 }}
```

- 結果確認（MySQL）

  ```terminal:terminal(MySQL)
  mysql> select * from people;
  +----+------------+-----------+------+
  | id | first_name | last_name | age  |
  +----+------------+-----------+------+
  |  1 | Ryan       | Bigg      |   28 |
  |  2 | John       | Smith     |   27 |
  |  3 | Jane       | Smith     |   26 |
  |  4 | im         | miolab    |   28 |
  |  5 | iiii       | mimimi    |   18 |
  +----+------------+-----------+------+
  5 rows in set (0.02 sec)
  ```

`Create`操作ができました。

## Read（データ読み出し）

つづいて、登録データの読み出し・抽出を行っていきます。

### 全レコード 取得

- `Repo.all()`

  ```terminal:terminal
  iex(5)> Friendsmysql.Person |> Friendsmysql.Repo.all

  13:51:56.586 [debug] QUERY OK source="people" db=0.3ms queue=5.9ms idle=1513.0ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 []
  [
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 28,
      first_name: "Ryan",
      id: 1,
      last_name: "Bigg"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 27,
      first_name: "John",
      id: 2,
      last_name: "Smith"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 26,
      first_name: "Jane",
      id: 3,
      last_name: "Smith"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 28,
      first_name: "im",
      id: 4,
      last_name: "miolab"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 18,
      first_name: "iiii",
      id: 5,
      last_name: "mimimi"
    }
  ]
  ```

  文字どおりレコード全件読み出しです。
  （`SELECT * FROM table`相当）

### `id`を指定してレコード取得

- `Repo.get_by()`

  ```terminal:terminal
  iex(6)> Friendsmysql.Person |> Friendsmysql.Repo.get(3)

  13:53:31.176 [debug] QUERY OK source="people" db=6.2ms queue=0.3ms idle=1102.8ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`id` = ?) [3]
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 26,
    first_name: "Jane",
    id: 3,
    last_name: "Smith"
  }
  ```

  `id: 3`のレコードを抽出しました。

### カラム名とフィールドに基づいてレコードを取得

- `Repo.where()`

  ```terminal:terminal
  iex(7)> Friendsmysql.Person |> Friendsmysql.Repo.get_by(first_name: "im")

  13:54:58.257 [debug] QUERY OK source="people" db=1.8ms queue=2.0ms idle=1185.3ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`first_name` = ?) ["im"]
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 28,
    first_name: "im",
    id: 4,
    last_name: "miolab"
  }

  iex(8)> Friendsmysql.Person |> Friendsmysql.Repo.get_by(age: 18)

  13:56:15.218 [debug] QUERY OK source="people" db=1.9ms queue=6.1ms idle=1269.7ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`age` = ?) [18]
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 18,
    first_name: "iiii",
    id: 5,
    last_name: "mimimi"
  }
  ```

  `first_name`や`age`などのカラム名に該当するデータを指定して抽出です。

## Ecto.Queryでフィルタリング抽出

もう少しつっこんだ抽出条件のクエリを書いてみます。

まず、`require Ecto.Query`準備が必要となります。

  ```terminal:terminal
  iex(9)> require Ecto.Query
  Ecto.Query
  ```

### カラム名とフィールドに基づいて重複レコードを取得

それでは、`Ecto.Query`で重複するレコードを抽出します。
具体的に、`last_name`が`Smith`さんが2人いるので、お二方を抽出してみます。

なお、先ほどの`get_by()`ではレコード1件の抽出しかできないため、こちらのように`Ecto.Query`によるオペレーションが必要となります。

  ```terminal:terminal
  iex(10)> Friendsmysql.Person |> Ecto.Query.where(last_name: "Smith") |> Friendsmysql.Repo.all

  14:00:10.899 [debug] QUERY OK source="people" db=0.2ms queue=5.0ms idle=1827.0ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`last_name` = 'Smith') []
  [
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 27,
      first_name: "John",
      id: 2,
      last_name: "Smith"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 26,
      first_name: "Jane",
      id: 3,
      last_name: "Smith"
    }
  ]
  ```

もしくは、

  ```terminal:terminal
  iex(11)> Ecto.Query.from(p in Friendsmysql.Person, where: p.last_name == "Smith") |> Friendsmysql.Repo.all

  14:00:57.013 [debug] QUERY OK source="people" db=5.5ms idle=1940.3ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`last_name` = 'Smith') []
  [
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 27,
      first_name: "John",
      id: 2,
      last_name: "Smith"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 26,
      first_name: "Jane",
      id: 3,
      last_name: "Smith"
    }
  ]
  ```

  2人の_Smithさん_を抽出しました。

### 絞り込み抽出

複数の抽出条件を組み合わせることもできます。
といっても、パイプライン演算子で繋ぐだけでOKです。

`last_name`条件抽出に、`first_name`条件抽出をつないで、`AND`検索っぽくクエリをアレンジします。

```terminal:terminal
iex(12)> Friendsmysql.Person |> Ecto.Query.where(last_name: "Smith") |> Ecto.Query.where(age: 27) |> Friendsmysql.Repo.all

14:02:44.259 [debug] QUERY OK source="people" db=0.6ms queue=3.9ms idle=1184.8ms
SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`last_name` = 'Smith') AND (p0.`age` = 27) []
[
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 27,
    first_name: "John",
    id: 2,
    last_name: "Smith"
  }
]
```

`last_name`が_Smith_で、かつ`age`が_27_の人を抽出しました。

### その他、抽出いろいろ

適当にいくつか例を実行します。
（イメージしやすいよう、それぞれSQLも添えています）

- 事前準備

  ```terminal:terminal
  iex(13)> import Ecto.Query, only: [from: 2]
  Ecto.Query
  ```

- 全レコードの`age`平均値を抽出（`SELECT AVG(age) FROM people`）

  ```terminal:terminal
  iex(14)> query_avg = from p in "people",
  ...(14)> select: avg(p.age)
  #Ecto.Query<from p0 in "people", select: avg(p0.age)>

  iex(15)> Friendsmysql.Repo.all(query_avg)

  14:14:19.725 [debug] QUERY OK source="people" db=18.2ms queue=1.8ms idle=1914.1ms
  SELECT avg(p0.`age`) FROM `people` AS p0 []
  [#Decimal<25.4000>]
  ```

- `age > 20`の人の`first_name`を抽出（`SELECT first_name FROM people WHERE age > 20`）

  ```terminal:terminal
  iex(16)> query_over_twenty = from p in "people",
  ...(16)> where: p.age > 20,
  ...(16)> select: p.first_name
  #Ecto.Query<from p0 in "people", where: p0.age > 20, select: p0.first_name>

  iex(17)> Friendsmysql.Repo.all(query_over_twenty)

  14:17:21.281 [debug] QUERY OK source="people" db=1.1ms queue=3.6ms idle=1491.4ms
  SELECT p0.`first_name` FROM `people` AS p0 WHERE (p0.`age` > 20) []
  ["Ryan", "John", "Jane", "im"]
  ```

- `age > 26`の人を`age降順`で並びかえて抽出（`SELECT id, first_name, age FROM people WHERE age > 26 ORDER BY age DESC`）

  ```terminal:terminal
  iex(18)> query_over_twentysix = from p in "people",
  ...(18)> where: p.age > 26,
  ...(18)> order_by: [desc: :age],
  ...(18)> select: [:id, :first_name, :age]
  #Ecto.Query<from p0 in "people", where: p0.age > 26, order_by: [desc: p0.age],
  select: [:id, :first_name, :age]>

  iex(19)> Friendsmysql.Repo.all(query_over_twentysix)

  14:19:08.225 [debug] QUERY OK source="people" db=4.1ms queue=3.9ms idle=1431.1ms
  SELECT p0.`id`, p0.`first_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`age` > 26) ORDER BY p0.`age` DESC []
  [
    %{age: 28, first_name: "Ryan", id: 1},
    %{age: 28, first_name: "im", id: 4},
    %{age: 27, first_name: "John", id: 2}
  ]
  ```

  この他にも、抽出方法は__公式リファレンス__に記載がありますので、見て試してみられると良いかとおもいます。

  - Ecto.Query 参考

    - [Ecto.Query](https://hexdocs.pm/ecto/Ecto.Query.html)
    - [Ecto.Query.API](https://hexdocs.pm/ecto/Ecto.Query.API.html)

### （補足）`Ecto.Query`内で変数使用の際は`^`が必要

変数をクエリ内で展開する際には、`^`（ピン演算子）が必要になります。

  ```terminal:terminal
  iex(20)> first_name_im = "im"
  "im"

  iex(21)> Friendsmysql.Person |> Ecto.Query.where(first_name: ^first_name_im) |> Friendsmysql.Repo.all

  14:24:47.240 [debug] QUERY OK source="people" db=2.0ms idle=1170.0ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`first_name` = ?) ["im"]
  [
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 28,
      first_name: "im",
      id: 4,
      last_name: "miolab"
    }
  ]
  ```

  `first_name_im`で束縛した文字列`im`を`Ecto.Query`で展開する際、適用変数を`^first_name_im`の形にします。

## Update（データ更新）

`CRUD`のつづきで、データの更新手順です。

- `Repo.update()`

  ```terminal:terminal
  iex(1)> require Ecto.Query
  Ecto.Query

  iex(2)> ryan = Friendsmysql.Person |> Ecto.Query.where(first_name: "Ryan") |> Friendsmysql.Repo.one

  14:28:40.395 [debug] QUERY OK source="people" db=0.3ms decode=1.0ms queue=2.7ms idle=1582.4ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`first_name` = 'Ryan') []
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 28,
    first_name: "Ryan",
    id: 1,
    last_name: "Bigg"
  }
  ```

  上記で準備した_Ryanさん_の`age: 28`を、`29`に更新してみます。

  ```
  iex(3)> change_age_twentynine = Friendsmysql.Person.changeset(ryan, %{age: 29})
  #Ecto.Changeset<
    action: nil,
    changes: %{age: 29},
    errors: [],
    data: #Friendsmysql.Person<>,
    valid?: true
  >

  iex(4)> Friendsmysql.Repo.update(change_age_twentynine)

  14:31:55.745 [debug] QUERY OK db=7.2ms queue=4.1ms idle=1929.9ms
  UPDATE `people` SET `age` = ? WHERE `id` = ? [29, 1]
  {:ok,
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 29,
    first_name: "Ryan",
    id: 1,
    last_name: "Bigg"
  }}
  ```

  結果を確認します。

  ```
  iex(5)> Friendsmysql.Person |> Friendsmysql.Repo.get_by(first_name: "Ryan")

  14:32:16.250 [debug] QUERY OK source="people" db=0.5ms queue=0.8ms idle=1442.8ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 WHERE (p0.`first_name` = ?) ["Ryan"]
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 29,
    first_name: "Ryan",
    id: 1,
    last_name: "Bigg"
  }
  ```

  `age: 29`に更新がされています。

## Delete（データ削除）

`CRUD`の最後に、テーブルのレコードを削除します。

- `Repo.delete()`

  先ほどの`Update`のつづきで、_Ryanさん_ レコードをゴメンナサイですが削除します。

  ```
  iex(6)> Friendsmysql.Repo.delete(ryan)

  14:35:11.201 [debug] QUERY OK db=4.8ms queue=4.8ms idle=1386.5ms
  DELETE FROM `people` WHERE `id` = ? [1]
  {:ok,
  %Friendsmysql.Person{
    __meta__: #Ecto.Schema.Metadata<:deleted, "people">,
    age: 28,
    first_name: "Ryan",
    id: 1,
    last_name: "Bigg"
  }}
  ```

  削除できているか全件抽出して確認します。

  ```
  iex(7)> Friendsmysql.Person |> Friendsmysql.Repo.all

  14:35:52.982 [debug] QUERY OK source="people" db=0.4ms queue=2.0ms idle=173.7ms
  SELECT p0.`id`, p0.`first_name`, p0.`last_name`, p0.`age` FROM `people` AS p0 []
  [
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 27,
      first_name: "John",
      id: 2,
      last_name: "Smith"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 26,
      first_name: "Jane",
      id: 3,
      last_name: "Smith"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 28,
      first_name: "im",
      id: 4,
      last_name: "miolab"
    },
    %Friendsmysql.Person{
      __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
      age: 18,
      first_name: "iiii",
      id: 5,
      last_name: "mimimi"
    }
  ]
  ```

  _Ryanさん_のレコードが削除されました。
