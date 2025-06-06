defmodule PotterWeb.OrderLive.Show do
  use PotterWeb, :live_view

  alias Potter.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Order {@order.id}
        <:subtitle>This is a order record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/orders"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/orders/#{@order}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit order
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Description">{@order.description}</:item>
        <:item title="Extra cheese?">{@order.extra_cheese?}</:item>
        <:item title="Deliver at">{@order.deliver_at}</:item>
        <:item title="Status">{@order.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Order")
     |> assign(:order, Orders.get_order!(id))}
  end
end
