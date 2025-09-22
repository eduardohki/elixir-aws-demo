defmodule DemoTodoWeb.ItemLiveTest do
  use DemoTodoWeb.ConnCase

  import Phoenix.LiveViewTest
  import DemoTodo.TodoFixtures

  @create_attrs %{text: "some text"}
  @update_attrs %{status: false, text: "some updated text"}
  @invalid_attrs %{text: nil}
  defp create_item(_) do
    item = item_fixture()

    %{item: item}
  end

  describe "Index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, item: item} do
      {:ok, _index_live, html} = live(conn, ~p"/items")

      assert html =~ "Todo Items"
      assert html =~ item.text
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "Add Todo")
               |> render_click()
               |> follow_redirect(conn, ~p"/items/new")

      assert render(form_live) =~ "New Todo Item"

      assert form_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#item-form", item: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items")

      html = render(index_live)
      assert html =~ "Item created successfully"
      assert html =~ "some text"
    end

    test "updates item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#items-#{item.id} a[href$='/edit']")
               |> render_click()
               |> follow_redirect(conn, ~p"/items/#{item}/edit")

      assert render(form_live) =~ "Edit Todo Item"

      assert form_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#item-form", item: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items")

      html = render(index_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated text"
    end

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert index_live |> element("#items-#{item.id} a[data-confirm]") |> render_click()
      refute has_element?(index_live, "#items-#{item.id}")
    end
  end

  describe "Show" do
    setup [:create_item]

    test "displays item", %{conn: conn, item: item} do
      {:ok, _show_live, html} = live(conn, ~p"/items/#{item}")

      assert html =~ "Show Todo Item"
      assert html =~ item.text
    end

    test "updates item and returns to show", %{conn: conn, item: item} do
      {:ok, show_live, _html} = live(conn, ~p"/items/#{item}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/items/#{item}/edit?return_to=show")

      assert render(form_live) =~ "Edit Todo Item"

      assert form_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#item-form", item: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items/#{item}")

      html = render(show_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated text"
    end
  end
end
