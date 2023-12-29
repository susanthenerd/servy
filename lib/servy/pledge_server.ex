defmodule Servy.PledgeServer do
  require Logger
  alias Servy.GenericServer

  @name :pledge_server

  def start do
    GenericServer.start(__MODULE__, [], @name)
  end

  # Client

  def create_pledge(name, amount), do: GenericServer.call(@name, {:create_pledge, name, amount})
  def recent_pledges, do: GenericServer.call(@name, :recent_pledges)
  def total_pledged, do: GenericServer.call(@name, :total_pledged)

  def clear, do: GenericServer.cast(@name, :clear)

  # Server Callback

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, ammount}, state) do
    {:ok, id} = send_pledge_to_service(name, ammount)

    most_recent_pleges = Enum.take(state, 2)
    new_state = [{name, ammount} | most_recent_pleges]

    {id, new_state}
  end

  def handle_cast(:clear, _state) do
    []
  end

  defp send_pledge_to_service(_name, _amount) do
    # fake send to service module
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
