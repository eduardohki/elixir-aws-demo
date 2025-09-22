defmodule DemoTodo.Repo do
  use Ecto.Repo,
    otp_app: :demo_todo,
    adapter: Ecto.Adapters.Postgres
end
