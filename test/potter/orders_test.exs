defmodule Potter.OrdersTest do
  use Potter.DataCase

  alias Potter.Orders

  describe "orders" do
    alias Potter.Orders.Order

    import Potter.OrdersFixtures

    @invalid_attrs %{status: nil, description: nil, extra_cheese?: nil, deliver_at: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{
        status: :requested,
        description: "some description",
        extra_cheese?: true,
        cheese_type: :gouda,
        deliver_at: ~T[14:00:00]
      }

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)
      assert order.status == :requested
      assert order.description == "some description"
      assert order.extra_cheese? == true
      assert order.deliver_at == ~T[14:00:00]
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()

      update_attrs = %{
        description: "some updated description",
        extra_cheese?: false,
        deliver_at: ~T[15:01:01]
      }

      assert {:ok, %Order{} = order} = Orders.update_order(order, update_attrs)
      assert order.status == :requested
      assert order.description == "some updated description"
      assert order.extra_cheese? == false
      assert order.deliver_at == ~T[15:01:01]
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
