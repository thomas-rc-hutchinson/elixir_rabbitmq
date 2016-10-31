defmodule RabbitMQ do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(RabbitMQ.Client, []),
    ]

    opts = [strategy: :one_for_one, name: RabbitMQ.Supervisor,
            max_restarts: 3, max_seconds: 1]
    Supervisor.start_link(children, opts)
  end
end
