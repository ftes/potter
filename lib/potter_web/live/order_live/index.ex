defmodule PotterWeb.OrderLive.Index do
  use PotterWeb, :live_view

  alias Potter.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Orders
        <:actions>
          <.button variant="primary" navigate={~p"/orders/new"}>
            <.icon name="hero-plus" /> New Order
          </.button>
        </:actions>
      </.header>

      <.table
        id="orders"
        rows={@streams.orders}
        row_click={fn {_id, order} -> JS.navigate(~p"/orders/#{order}") end}
      >
        <:col :let={{_id, order}} label="Description">{order.description}</:col>
        <:col :let={{_id, order}} label="Extra cheese?">{order.extra_cheese?}</:col>
        <:col :let={{_id, order}} label="Deliver at">{order.deliver_at}</:col>
        <:col :let={{_id, order}} label="Status">{order.status}</:col>
        <:action :let={{_id, order}}>
          <div class="sr-only">
            <.link navigate={~p"/orders/#{order}"}>Show</.link>
          </div>
          <.link navigate={~p"/orders/#{order}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, order}}>
          <.link
            phx-click={JS.push("delete", value: %{id: order.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Orders")
     |> stream(:orders, Orders.list_orders())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    order = Orders.get_order!(id)
    {:ok, _} = Orders.delete_order(order)

    {:noreply, stream_delete(socket, :orders, order)}
  end
end
