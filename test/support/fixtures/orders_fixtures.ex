defmodule Potter.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Potter.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        deliver_at: ~T[14:00:00],
        description: "some description",
        extra_cheese?: true,
        cheese_type: :gouda,
        status: :requested
      })
      |> Potter.Orders.create_order()

    %{order | schema: nil}
  end
end
