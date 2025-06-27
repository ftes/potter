defmodule PotterWeb.SchemaForm do
  use PotterWeb, :html

  attr :form, Phoenix.HTML.Form, required: true
  attr :fields, :list
  attr :rest, :global

  def inputs_for_schema(%{form: form} = assigns) do
    dbg(:inputs_for)
    schema = form[:schema].value
    schema = if fields = assigns[:fields], do: Keyword.take(schema, fields), else: schema
    assigns = assign(assigns, :schema, schema)

    ~H"""
    <%= for {field, field_schema} <- @schema do %>
      <.input_for_schema field={@form[field]} schema={field_schema} {@rest} />
    <% end %>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :schema, :list
  attr :rest, :global

  def input_for_schema(%{field: %{field: field}} = assigns) do
    dbg(:input_for)
    assigns = assign_new(assigns, :schema, fn -> assigns.form[:schema].value[field] end)

    ~H"""
    <.input :if={!@schema[:hidden]} field={@field} {attrs(@field)} {Map.new(@schema)} {@rest} />
    """
  end

  def attrs(%Phoenix.HTML.FormField{} = field) do
    struct = field.form.source.data.__struct__

    case struct.__schema__(:type, field.field) do
      {:parameterized, {Ecto.Enum, _}} ->
        %{type: "select", options: Ecto.Enum.values(struct, field.field)}

      :boolean ->
        %{type: "checkbox"}

      :time ->
        %{type: "time"}

      _ ->
        %{}
    end
  end
end
