defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter
  use GenServer

  # Client Interface

  def start, do: GenServer.start(__MODULE__, %{}, name: @name)

  def init(state), do: state

  def bump_count(path), do: GenServer.call(@name, {:bump_count, path})

  def get_counts, do: GenServer.call(@name, :get_counts)

  def get_count(path), do: GenServer.call(@name, {:get_count, path})

  def reset, do: GenServer.cast(@name, :reset)

  # Server Callbacks

  def handle_call({:bump_count, path}, _from, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, :ok, new_state}
  end

  def handle_call(:get_counts, state) do
    {:reply, state, state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end
end
