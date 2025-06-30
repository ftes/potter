defmodule Potter.Orders.Order do
  alias Potter.Orders.Order
  alias Ecto.Changeset
  use Ecto.Schema
  import Ecto.Changeset

  ## TODO Polymorphic embed with JSON schema forms

  schema "orders" do
    field :description, :string
    field :vegetarian?, :boolean, default: false
    field :extra_cheese?, :boolean, default: false
    field :cheese_type, Ecto.Enum, values: ~w(gouda mozzarella fake_cheese)a
    field :deliver_asap?, :boolean, default: false
    field :deliver_at, :time
    field :status, Ecto.Enum, values: ~w(requested confirmed delivered)a

    field :schema, :any, virtual: true
    timestamps(type: :utc_datetime)
  end

  def changeset(order, attrs) do
    # This could (nearly)  be stored in a database
    # TODO declarative conditions
    schema = [
      description: [:required],
      deliver_asap?: [],
      # user defined form:
      # - conditions as data, e.g. {:if, {:eq, :deliver_asap?, true}, [:disabled]}
      # - conditions as LUA/restricted elixir
      deliver_at: [:required, &(&1.deliver_asap? && [:disabled, value: deliver_at(&1)])],
      vegetarian?: [],
      extra_cheese?: [],
      cheese_type:
        [:required, hidden: &(not &1.extra_cheese?)] ++
          [&(&1.vegetarian? && [options: ~w(fake_cheese)a])]
    ]

    Potter.FormSchema.Ecto.changeset(order, schema, attrs)
  end

  defp deliver_at(%Changeset{} = changeset), do: changeset |> apply_changes |> deliver_at()

  defp deliver_at(%Order{extra_cheese?: true}), do: shift_now(minute: 45)
  defp deliver_at(%Order{}), do: shift_now(minute: 30)

  defp shift_now(duration),
    do: Time.utc_now() |> Time.shift(duration) |> Time.truncate(:second) |> Map.put(:second, 0)
end
