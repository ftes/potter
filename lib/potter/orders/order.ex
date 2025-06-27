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

    changeset = cast(order, attrs, []) |> put_change(:schema, [])

    Enum.reduce(schema, changeset, &handle_field/2)
  end

  defp resolve_opts(nil, _), do: []
  defp resolve_opts(false, _), do: []

  defp resolve_opts(opts, applied) when is_list(opts) do
    Enum.flat_map(opts, fn
      key when is_atom(key) -> [{key, true}]
      fun when is_function(fun, 1) -> applied |> fun.() |> resolve_opts(applied)
      {key, fun} when is_atom(key) and is_function(fun, 1) -> [{key, fun.(applied)}]
      {key, value} when is_atom(key) -> [{key, value}]
    end)
    |> Keyword.new()
  end

  defp handle_field({field, opts}, changeset) do
    applied = apply_changes(changeset)
    opts = resolve_opts(opts, applied)

    changeset
    |> update_change(:schema, &(&1 ++ [{field, opts}]))
    |> then_if(
      !opts[:hidden] and !opts[:disabled],
      &cast(&1, changeset.params, [field], force_changes: true)
    )
    |> then_if(opts[:hidden], &put_change(&1, field, nil))
    |> then_if(Keyword.has_key?(opts, :value), &put_change(&1, field, opts[:value]))
    |> then_if(!opts[:hidden] and opts[:required], &validate_required(&1, field))
    |> then_if(opts[:options], &validate_inclusion(&1, field, opts[:options]))
  end

  defp then_if(input, condition, then) when is_function(then, 1) do
    condition =
      case condition do
        fun when is_function(fun, 1) -> input |> apply_changes() |> fun.()
        other -> other
      end

    if condition, do: then.(input), else: input
  end

  defp deliver_at(%Changeset{} = changeset), do: changeset |> apply_changes |> deliver_at()

  defp deliver_at(%Order{extra_cheese?: true}), do: shift_now(minute: 45)
  defp deliver_at(%Order{}), do: shift_now(minute: 30)

  defp shift_now(duration),
    do: Time.utc_now() |> Time.shift(duration) |> Time.truncate(:second) |> Map.put(:second, 0)
end
