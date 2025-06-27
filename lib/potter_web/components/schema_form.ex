defmodule PotterWeb.SchemaForm do
  use PotterWeb, :html

  attr :form, Phoenix.HTML.Form, required: true
  attr :ui_schema, :any

  def form_for_schema(assigns) do
    assigns = assign_new(assigns, :ui_schema, &default_ui_schema(&1.form[:schema].value))

    # TODO Form buttons
    ~H"""
    <.render_ui_schema form={@form} ui_schema={@ui_schema} />
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :schema, :list
  attr :rest, :global

  def input_for_schema(%{field: %{field: field}} = assigns) do
    assigns = assign_new(assigns, :schema, fn -> assigns.field.form[:schema].value[field] end)

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

  defp default_ui_schema(data_schema) do
    {:col, Enum.map(data_schema, fn {field, _} -> {:field, field, %{}} end), %{}}
  end

  # TODO Switch to grid
  defp render_ui_schema(%{ui_schema: {:col, elements, attrs}} = assigns) do
    attrs = Map.put_new(attrs, :class, "flex flex-col gap-y-2")
    assigns = assign(assigns, elements: elements, attrs: attrs)

    ~H"""
    <div {@attrs}>
      <.render_ui_schema :for={element <- @elements} form={@form} ui_schema={element} />
    </div>
    """
  end

  defp render_ui_schema(%{ui_schema: {:row, elements, attrs}} = assigns) do
    attrs = Map.put_new(attrs, :class, "flex flex-row gap-y-2")
    assigns = assign(assigns, elements: elements, attrs: attrs)

    ~H"""
    <div {@attrs}>
      <.render_ui_schema :for={element <- @elements} form={@form} ui_schema={element} />
    </div>
    """
  end

  defp render_ui_schema(%{ui_schema: field} = assigns) when is_atom(field) do
    assigns |> assign(:ui_schema, {:field, field, %{}}) |> render_ui_schema()
  end

  defp render_ui_schema(%{ui_schema: {:field, field, attrs}} = assigns) do
    assigns = assign(assigns, field: field, attrs: attrs)

    ~H"""
    <.input_for_schema field={@form[@field]} {@attrs} />
    """
  end
end
