defmodule Potter.Orders.Order do
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
    order
    |> schema_cast(
      attrs,
      ~w(description vegetarian? extra_cheese? cheese_type deliver_asap? deliver_at)a
    )
    |> schema_validate_inclusion_if(& &1.vegetarian?, :cheese_type, ~w(fake_cheese)a)
    |> schema_hide_if(&(not &1.extra_cheese?), :cheese_type)
    |> schema_override_if(& &1.deliver_asap?, :deliver_at, deliver_at())
    |> put_change(:status, :requested)
    |> schema_validate_required(~w(cheese_type deliver_at)a)
  end

  defp schema_cast(order, attrs, fields) do
    order
    |> cast(attrs, fields)
    |> put_change(:schema, FormSchema.new(fields: fields))
  end

  defp schema_validate_inclusion(changeset, field, values) do
    changeset
    |> validate_inclusion(field, values)
    |> update_change(:schema, &FormSchema.set_attrs(&1, field, %{options: values}))
  end

  defp schema_validate_inclusion_if(changeset, condition, field, values) do
    then_if(changeset, condition, &schema_validate_inclusion(&1, field, values))
  end

  defp schema_hide(changeset, field) do
    changeset
    |> delete_change(field)
    |> update_change(:schema, &FormSchema.remove(&1, field))
  end

  defp schema_hide_if(changeset, condition, field) do
    then_if(changeset, condition, &schema_hide(&1, field))
  end

  defp schema_override(changeset, field, value) do
    changeset
    |> put_change(field, value)
    |> update_change(:schema, &FormSchema.disable(&1, field))
  end

  defp schema_override_if(changeset, condition, field, value) do
    then_if(changeset, condition, &schema_override(&1, field, value))
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

  defp deliver_at(), do: DateTime.utc_now() |> DateTime.shift(minute: 30)
end
