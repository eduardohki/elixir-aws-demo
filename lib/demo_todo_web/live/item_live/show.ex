defmodule DemoTodoWeb.ItemLive.Show do
  use DemoTodoWeb, :live_view

  alias DemoTodo.Todo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Item {@item.id}
        <:subtitle>This is a item record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/items"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/items/#{@item}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Todo Item
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Text">{@item.text}</:item>
        <:item title="Done">{@item.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Todo Item")
     |> assign(:item, Todo.get_item!(id))}
  end
end
