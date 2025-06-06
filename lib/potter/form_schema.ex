defmodule Potter.FormSchema do
  defstruct fields: [], required: [], disabled: [], attrs: %{}

  def new(opts \\ []) do
    struct!(__MODULE__, opts)
  end

  def remove(%__MODULE__{} = schema, fields) do
    schema |> Map.update!(:fields, &(&1 -- List.wrap(fields)))
  end

  def disable(%__MODULE__{} = schema, fields) do
    schema |> Map.update!(:disabled, &(&1 ++ List.wrap(fields)))
  end

  def require(%__MODULE__{} = schema, fields) do
    schema |> Map.update!(:required, &(&1 ++ List.wrap(fields)))
  end

  def set_attrs(%__MODULE__{} = schema, field, attrs) do
    schema |> Map.update!(:attrs, &Map.put(&1, field, attrs))
  end
end
