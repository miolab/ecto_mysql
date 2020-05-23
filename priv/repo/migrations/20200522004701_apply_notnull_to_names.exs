defmodule Friendsmysql.Repo.Migrations.ApplyNotnullToNames do
  use Ecto.Migration

  def change do
    alter table(:people) do
      modify :first_name, :string, null: false
      modify :last_name, :string, null: false
    end
  end
end
