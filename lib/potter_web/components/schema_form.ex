defmodule PotterWeb.SchemaForm do
  use PotterWeb, :html

  attr :form, Phoenix.HTML.Form, required: true
  attr :schema, PotterWeb.Schema

  def inputs_for_schema(assigns) do
    assigns = assign_new(assigns, :schema, fn -> assigns.form[:schema].value end)

    ~H"""
    <%= for field <- @schema.fields do %>
      <%= if assigns[field] not in [nil, []] do %>
        {render_slot(assigns[field])}
      <% else %>
        <.input
          field={@form[field]}
          required={field in @schema.required}
          disabled={field in @schema.disabled}
          {attrs(@form, @schema, field)}
        />
      <% end %>
    <% end %>
    """
  end

  def attrs(form, schema, field) do
    struct = form.source.data.__struct__

    default_attrs =
      case struct.__schema__(:type, field) do
        {:parameterized, {Ecto.Enum, _}} ->
          %{type: "select", options: Ecto.Enum.values(struct, field)}

        :boolean ->
          %{type: "checkbox"}

        _ ->
          %{}
      end

    schema_attrs = Map.get(schema.attrs, field, %{})
    dbg(Map.merge(default_attrs, schema_attrs))
  end
end
