defmodule DataObjectEnqueuer do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    unless Application.get_env(:data_object_enqueuer, :disable_monitoring, :false) do
      setup_monitoring()
    end

    children = [
      worker(DataObjectEnqueuer.Rabbit.Client, []),
      worker(DataObjectEnqueuer.Listener, []),
      worker(DataObjectEnqueuer.Transferer, []),
      worker(DataObjectEnqueuer.Manager, [DataObjectEnqueuer.Transferer])
    ]

    opts = [strategy: :one_for_one, name: DataObjectEnqueuer.Supervisor,
            max_restarts: 4200, max_seconds: 60]
    Supervisor.start_link(children, opts)
  end

  defp setup_monitoring do
   interval = Application.get_env(:data_object_enqueuer, :metrics_poll_interval)
   gamecenter = Application.get_env(:data_object_enqueuer, :gamecenter)
   {:ok, hostname} = :inet.gethostname()
   DataObjectEnqueuer.Metrics.Exometer.setup_exometer_subscriptions(gamecenter, hostname, interval)
  end
end
