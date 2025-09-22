defmodule DemoTodoWeb.PageController do
  use DemoTodoWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/items")
  end
end
