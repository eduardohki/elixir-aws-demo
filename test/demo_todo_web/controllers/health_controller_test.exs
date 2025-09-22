defmodule DemoTodoWeb.HealthControllerTest do
  use DemoTodoWeb.ConnCase

  describe "GET /healthz" do
    test "returns ok status when all dependencies are healthy", %{conn: conn} do
      conn = get(conn, ~p"/healthz")

      assert conn.status == 200

      assert %{
               "status" => "ok",
               "timestamp" => _
             } = json_response(conn, 200)
    end

    test "returns proper content type", %{conn: conn} do
      conn = get(conn, ~p"/healthz")

      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    end
  end
end
