defmodule PotterWeb.OrderLive.Form do
  alias PotterWeb.SchemaForm
  use PotterWeb, :live_view

  alias Potter.Orders
  alias Potter.Orders.Order

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage order records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="order-form" phx-change="validate" phx-submit="save">
        <SchemaForm.inputs_for_schema form={@form} />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Order</.button>
          <.button navigate={return_path(@return_to, @order)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    order = Orders.get_order!(id)

    socket
    |> assign(:page_title, "Edit Order")
    |> assign(:order, order)
    |> assign(:form, to_form(Orders.change_order(order)))
  end

  defp apply_action(socket, :new, _params) do
    order = %Order{}

    socket
    |> assign(:page_title, "New Order")
    |> assign(:order, order)
    |> assign(:form, to_form(Orders.change_order(order)))
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset = Orders.change_order(socket.assigns.order, order_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"order" => order_params}, socket) do
    save_order(socket, socket.assigns.live_action, order_params)
  end

  defp save_order(socket, :edit, order_params) do
    case Orders.update_order(socket.assigns.order, order_params) do
      {:ok, order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, order))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_order(socket, :new, order_params) do
    case Orders.create_order(order_params) do
      {:ok, order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, order))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _order), do: ~p"/orders"
  defp return_path("show", order), do: ~p"/orders/#{order}"
end
