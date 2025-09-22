defmodule DemoTodoWeb.ItemLive.Form do
  use DemoTodoWeb, :live_view

  alias DemoTodo.Todo
  alias DemoTodo.Todo.Item

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-2xl mx-auto py-8">
        <.header>
          <.icon name="hero-plus-circle" class="w-8 h-8 inline mr-2 text-primary" />
          {@page_title}
          <:subtitle>Add a new todo to your list or edit an existing one.</:subtitle>
        </.header>

        <div class="bg-base-100 shadow-sm rounded-lg border border-base-300 mt-6 p-6">
          <.form for={@form} id="item-form" phx-change="validate" phx-submit="save">
            <div class="space-y-4">
              <.input
                field={@form[:text]}
                type="text"
                label="Description"
                placeholder="What do you need to do?"
                class="text-lg w-full block"
              />
              <%= if @live_action == :edit do %>
                <.input field={@form[:status]} type="checkbox" label="Mark as completed" />
              <% end %>
            </div>
            <div class="flex justify-end space-x-3 mt-6 pt-4 border-t border-base-300">
              <.button
                type="button"
                navigate={return_path(@return_to, @item)}
                class="px-4 py-2 text-sm font-medium text-base-content bg-base-100 border border-base-300 rounded-md hover:bg-base-200 transition-colors duration-150"
              >
                Cancel
              </.button>
              <.button
                phx-disable-with="Saving..."
                variant="primary"
                class="px-4 py-2 text-sm font-medium text-primary-content bg-primary border border-transparent rounded-md hover:bg-primary/90 transition-colors duration-150"
              >
                {if @live_action == :edit, do: "Update Todo", else: "Add Todo"}
              </.button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    item = Todo.get_item!(id)

    socket
    |> assign(:page_title, "Edit Todo Item")
    |> assign(:item, item)
    |> assign(:form, to_form(Todo.change_item(item)))
  end

  defp apply_action(socket, :new, _params) do
    item = %Item{}

    socket
    |> assign(:page_title, "New Todo Item")
    |> assign(:item, item)
    |> assign(:form, to_form(Todo.change_item(item)))
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset = Todo.change_item(socket.assigns.item, item_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.live_action, item_params)
  end

  defp save_item(socket, :edit, item_params) do
    case Todo.update_item(socket.assigns.item, item_params) do
      {:ok, item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo Item updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, item))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_item(socket, :new, item_params) do
    case Todo.create_item(item_params) do
      {:ok, item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo Item created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, item))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _item), do: ~p"/items"
  defp return_path("show", item), do: ~p"/items/#{item}"
end
