defmodule DemoTodoWeb.PageControllerTest do
  use DemoTodoWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/items"
  end
end
