defmodule Potter.FormSchema do
  import Ecto.Changeset

  def changeset(data, schema, attrs) do
    changeset = cast(data, attrs, []) |> put_change(:schema, [])
    Enum.reduce(schema, changeset, &field_changeset/2)
  end

  defp field_changeset({key, opts}, changeset) do
    data = apply_changes(changeset)
    opts = eval_opts(key, opts, data)

    changeset
    |> update_change(:schema, &(&1 ++ [{key, opts}]))
    |> then_if(
      !opts[:hidden] and !opts[:disabled],
      &cast(&1, changeset.params, [key], force_changes: true)
    )
    |> then_if(opts[:hidden], &put_change(&1, key, nil))
    |> then_if(Keyword.has_key?(opts, :value), &put_change(&1, key, opts[:value]))
    |> then_if(!opts[:hidden] and opts[:required], &validate_required(&1, key))
    |> then_if(opts[:options], &validate_inclusion(&1, key, opts[:options]))
  end

  defp eval_opts(_key, nil, _), do: []
  defp eval_opts(_key, false, _), do: []

  defp eval_opts(key, opts, data) when is_list(opts) do
    Enum.flat_map(opts, fn
      key when is_atom(key) -> [{key, true}]
      fun when is_function(fun, 1) -> eval_opts(key, fun.(data), data)
      {key, fun} when is_atom(key) and is_function(fun, 1) -> [{key, fun.(data)}]
      {key, value} when is_atom(key) -> [{key, value}]
    end)
    |> Keyword.new()
  end

  defp then_if(input, condition, then) when is_function(then, 1) do
    condition =
      case condition do
        fun when is_function(fun, 1) -> input |> apply_changes() |> fun.()
        other -> other
      end

    if condition, do: then.(input), else: input
  end
end
