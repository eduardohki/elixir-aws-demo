defmodule DemoTodoWeb.HealthController do
  use DemoTodoWeb, :controller

  def check(conn, _params) do
    checks = perform_health_checks()
    overall_status = if all_healthy?(checks), do: "ok", else: "error"

    status_code = if overall_status == "ok", do: 200, else: 503

    conn
    |> put_status(status_code)
    |> json(%{
      status: overall_status,
      timestamp: DateTime.utc_now()
    })
  end

  defp perform_health_checks do
    %{
      database: check_database(),
      pubsub: check_pubsub()
    }
  end

  defp check_database do
    try do
      DemoTodo.Repo.query!("SELECT 1", [])
      %{status: "ok", message: "Database connection successful"}
    rescue
      error ->
        %{status: "error", message: "Database connection failed: #{inspect(error)}"}
    end
  end

  defp check_pubsub do
    try do
      # Check if PubSub is running
      case Process.whereis(DemoTodo.PubSub) do
        nil ->
          %{status: "error", message: "PubSub process not found"}

        pid when is_pid(pid) ->
          # Test basic pub/sub functionality
          test_topic = "health_check_#{:rand.uniform(1000)}"
          Phoenix.PubSub.subscribe(DemoTodo.PubSub, test_topic)
          Phoenix.PubSub.broadcast(DemoTodo.PubSub, test_topic, :test_message)

          receive do
            :test_message ->
              Phoenix.PubSub.unsubscribe(DemoTodo.PubSub, test_topic)
              %{status: "ok", message: "PubSub working correctly"}
          after
            1000 ->
              Phoenix.PubSub.unsubscribe(DemoTodo.PubSub, test_topic)
              %{status: "error", message: "PubSub message delivery timeout"}
          end
      end
    rescue
      error ->
        %{status: "error", message: "PubSub check failed: #{inspect(error)}"}
    end
  end

  defp all_healthy?(checks) do
    Enum.all?(checks, fn {_key, check} -> check.status == "ok" end)
  end
end
