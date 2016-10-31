defmodule RabbitMQ.Client do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, connection} = AMQP.Connection.open("amqp://localhost")
    {:ok, channel} =  AMQP.Channel.open(connection)
    {:ok, channel}
  end

  def publish(payload) do
    GenServer.cast(__MODULE__, {:publish, payload})
  end

  def handle_cast({:publish, payload}, channel) do
    AMQP.Basic.publish(channel, "", "", payload)
    Logger.info("Published #{payload}")
    {:noreply, channel}
  end
end
