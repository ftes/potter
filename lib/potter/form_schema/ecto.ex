defmodule Potter.FormSchema.Ecto do
  def changeset(data, attrs) do
    schema = default_schema(data)
    changeset(data, schema, attrs)
  end

  def changeset(data, schema, attrs) do
    schema = default_schema(data, schema)
    Potter.FormSchema.changeset(data, schema, attrs)
  end

  defp default_schema(%struct{}) do
    Enum.map(struct.__schema__(:fields), &{&1, []})
  end

  defp default_schema(data, schema) do
    Enum.map(schema, fn {key, opts} -> {key, default_field(data, key) ++ opts} end)
  end

  defp default_field(%struct{}, key) do
    case struct.__schema__(:type, key) do
      {:parameterized, {Ecto.Enum, _}} ->
        [type: "select", options: Ecto.Enum.values(struct, key)]

      :boolean ->
        [type: "checkbox"]

      :time ->
        [type: "time"]

      _ ->
        []
    end
  end
end
