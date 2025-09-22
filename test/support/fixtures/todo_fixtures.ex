defmodule DemoTodo.TodoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DemoTodo.Todo` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        status: true,
        text: "some text"
      })
      |> DemoTodo.Todo.create_item()

    item
  end
end
