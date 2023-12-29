defmodule Servy.Kickstarter do
  use GenServer
  require Logger

  def start do
    Logger.info("Starting the kickstarter...")
    GenServer.start(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_args) do
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    Logger.error("HTTP Server exited (#{inspect(reason)})")
    server_pid = start_server()

    {:noreply, server_pid}
  end

  defp start_server do
    Logger.info("Starting HTTP Server")

    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)

    server_pid
  end
end
