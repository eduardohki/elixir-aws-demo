defmodule DemoTodoWeb.ErrorJSONTest do
  use DemoTodoWeb.ConnCase, async: true

  test "renders 404" do
    assert DemoTodoWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert DemoTodoWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
