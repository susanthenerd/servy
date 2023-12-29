defmodule Servy.PledgeServer do
  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  require Logger
  use GenServer

  @name :pledge_server

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def init(%State{} = args) do
    pledges = fetch_recent_pledges_from_service()

    state = %{args | pledges: pledges}

    {:ok, state}
  end

  # Client

  def create_pledge(name, amount), do: GenServer.call(@name, {:create_pledge, name, amount})
  def recent_pledges, do: GenServer.call(@name, :recent_pledges)
  def total_pledged, do: GenServer.call(@name, :total_pledged)

  def set_cache_size(size), do: GenServer.cast(@name, {:set_cache_size, size})
  def clear, do: GenServer.cast(@name, :clear)

  # Server Callback

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, ammount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, ammount)

    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, ammount} | most_recent_pledges]

    new_state = %{state | pledges: cached_pledges}

    {:reply, id, new_state}
  end

  def handle_cast({:set_cache_size, size}, state) do
    {:noreply, %{state | cache_size: size}}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  defp send_pledge_to_service(_name, _amount) do
    # fake send to service module
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # Example return value:
    [{"wilma", 15}, {"fred", 25}]
  end
end
