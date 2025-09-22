defmodule DemoTodo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DemoTodoWeb.Telemetry,
      DemoTodo.Repo,
      {DNSCluster, query: Application.get_env(:demo_todo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DemoTodo.PubSub},
      # Start a worker by calling: DemoTodo.Worker.start_link(arg)
      # {DemoTodo.Worker, arg},
      # Start to serve requests, typically the last entry
      DemoTodoWeb.Endpoint,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:demo_todo, :ecto_repos),
       skip: System.get_env("SKIP_MIGRATIONS") == "true",
       log_migrator_sql: true}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemoTodo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DemoTodoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
