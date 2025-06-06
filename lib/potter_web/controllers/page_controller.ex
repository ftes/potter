defmodule PotterWeb.PageController do
  use PotterWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
