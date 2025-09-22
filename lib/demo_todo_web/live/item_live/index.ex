defmodule DemoTodoWeb.ItemLive.Index do
  use DemoTodoWeb, :live_view

  alias DemoTodo.Todo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-2xl mx-auto py-8">
        <.header>
          <.icon name="hero-check-circle" class="w-8 h-8 inline mr-2 text-primary" /> My Todo List
          <:actions>
            <.button variant="primary" navigate={~p"/items/new"}>
              <.icon name="hero-plus" class="w-4 h-4" /> Add Todo
            </.button>
          </:actions>
        </.header>

        <div class="bg-base-100 shadow-sm rounded-lg border border-base-300 mt-6">
          <%= if @items_empty? do %>
            <div class="text-center py-12">
              <.icon name="hero-clipboard-document-list" class="w-12 h-12 mx-auto text-base-300" />
              <p class="mt-2 text-base-content/70">No todos yet. Add your first todo!</p>
            </div>
          <% else %>
            <div id="todos" phx-update="stream" class="divide-y divide-base-300">
              <div
                :for={{id, item} <- @streams.items}
                id={id}
                class="flex items-center p-4 hover:bg-base-200 group transition-colors duration-150"
              >
                <button
                  phx-click="toggle_status"
                  phx-value-id={item.id}
                  class={[
                    "flex-shrink-0 w-5 h-5 rounded border-2 mr-3 transition-all duration-150 flex items-center justify-center",
                    item.status && "bg-success border-success",
                    !item.status && "border-base-300 hover:border-success/50"
                  ]}
                >
                  <%= if item.status do %>
                    <.icon name="hero-check" class="w-3 h-3 text-success-content" />
                  <% end %>
                </button>

                <div class="flex-1 min-w-0">
                  <p class={[
                    "text-sm font-medium transition-all duration-150",
                    item.status && "line-through text-base-content/50",
                    !item.status && "text-base-content"
                  ]}>
                    {item.text}
                  </p>
                </div>

                <div class="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity duration-150">
                  <.link
                    navigate={~p"/items/#{item}/edit"}
                    class="text-base-content/40 hover:text-primary transition-colors duration-150"
                  >
                    <.icon name="hero-pencil" class="w-4 h-4" />
                  </.link>
                  <.link
                    phx-click={JS.push("delete", value: %{id: item.id}) |> hide("##{id}")}
                    data-confirm="Are you sure?"
                    class="text-base-content/40 hover:text-error transition-colors duration-150"
                  >
                    <.icon name="hero-trash" class="w-4 h-4" />
                  </.link>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    items = list_items()

    {:ok,
     socket
     |> assign(:page_title, "Todo Items")
     |> assign(:items_empty?, items == [])
     |> stream(:items, items)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Todo.get_item!(id)
    {:ok, _} = Todo.delete_item(item)

    remaining_items = list_items()

    {:noreply,
     socket
     |> assign(:items_empty?, remaining_items == [])
     |> stream_delete(:items, item)}
  end

  @impl true
  def handle_event("toggle_status", %{"id" => id}, socket) do
    item = Todo.get_item!(id)
    {:ok, updated_item} = Todo.update_item(item, %{status: !item.status})

    {:noreply, stream_insert(socket, :items, updated_item)}
  end

  defp list_items() do
    Todo.list_items()
  end
end
