defmodule Potter.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :description, :string
      add :extra_cheese?, :boolean, default: false, null: false
      add :cheese_type, :string
      add :deliver_asap?, :boolean
      add :deliver_at, :time
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
