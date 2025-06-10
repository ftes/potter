defmodule Potter.Orders.Order do
  alias Potter.Orders.Order
  alias Ecto.Changeset
  alias Potter.FormSchema
  use Ecto.Schema
  import Ecto.Changeset

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

  @doc false
  def changeset(order, attrs) do
    fields = ~w(description deliver_asap? deliver_at vegetarian? extra_cheese?)a

    order
    |> schema_cast(attrs, fields: fields)
    |> put_change(:status, :requested)
    |> then_if(& &1.extra_cheese?, &schema_add_field(&1, :cheese_type, after: :extra_cheese?))
    |> then_if(& &1.vegetarian?, &schema_validate_inclusion(&1, :cheese_type, ~w(fake_cheese)a))
    |> then_if(& &1.deliver_asap?, &schema_override(&1, :deliver_at, deliver_at(&1)))
    |> schema_validate_required(~w(cheese_type deliver_at)a)
  end

  defp schema_cast(order, attrs, opts) do
    fields = Access.fetch!(opts, :fields)

    order
    |> cast(attrs, fields)
    |> put_change(:schema, FormSchema.new(opts))
  end

  defp schema_validate_inclusion(changeset, field, values) do
    changeset
    |> validate_inclusion(field, values)
    |> update_change(:schema, &FormSchema.set_attrs(&1, field, %{options: values}))
  end

  defp schema_add_field(changeset, field, opts) do
    changeset
    |> cast(changeset.params, [field])
    |> update_change(:schema, &FormSchema.add_field(&1, field, opts))
  end

  defp schema_override(changeset, field, value) do
    changeset
    |> put_change(field, value)
    |> update_change(:schema, &FormSchema.disable(&1, field))
  end

  defp schema_validate_required(changeset, required) do
    schema = fetch_change!(changeset, :schema)
    required = Enum.filter(required, &(&1 in schema.fields))

    validate_required(changeset, required)
    |> update_change(:schema, &FormSchema.require(&1, required))
  end

  defp then_if(changeset, condition, then)
       when is_function(condition, 1) and is_function(then, 1) do
    if changeset |> apply_changes() |> condition.() do
      then.(changeset)
    else
      changeset
    end
  end

  defp deliver_at(%Changeset{} = changeset), do: changeset |> apply_changes |> deliver_at()

  defp deliver_at(%Order{extra_cheese?: true}),
    do: Time.utc_now() |> Time.shift(minute: 45) |> Calendar.strftime("%H:%M")

  defp deliver_at(%Order{}),
    do: Time.utc_now() |> Time.shift(minute: 30) |> Calendar.strftime("%H:%M")
end
