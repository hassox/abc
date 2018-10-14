defmodule ABC.Broadcaster do
  @moduledoc false
  use GenStage

  defmodule State do
    @moduledoc false
    defstruct [:name]
  end

  def child_spec(name) do
    %{
      id: Module.concat(__MODULE__, name),
      start: {__MODULE__, :start_link, [name]}
    }
  end

  def start_link(args) do
    GenStage.start_link(__MODULE__, args)
  end

  @impl true
  def init(name) do
    {:producer, %State{name: name}, dispatcher: GenStage.BroadcastDispatcher}
  end

  @impl true
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  @impl true
  def handle_call({:broadcast, event}, _from, state) do
    {:reply, :ok, [event], state}
  end

  # called when a handoff has been initiated due to changes
  # in cluster topology, valid response values are:
  #
  #   - `:restart`, to simply restart the process on the new node
  #   - `{:resume, state}`, to hand off some state to the new process
  #   - `:ignore`, to leave the process running on its current node
  #
  @impl true
  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:reply, :restart, [], state}
  end

  # called after the process has been restarted on its new node,
  # and the old process' state is being handed off. This is only
  # sent if the return to `begin_handoff` was `{:resume, state}`.
  # **NOTE**: This is called *after* the process is successfully started,
  # so make sure to design your processes around this caveat if you
  # wish to hand off state like this.
  @impl true
  def handle_cast({:swarm, :end_handoff, _remote_state}, local_state) do
    {:noreply, [], local_state}
  end
  # called when a network split is healed and the local process
  # should continue running, but a duplicate process on the other
  # side of the split is handing off its state to us. You can choose
  # to ignore the handoff state, or apply your own conflict resolution
  # strategy
  @impl true
  def handle_cast({:swarm, :resolve_conflict, _remote_state}, state) do
    {:noreply, [], state}
  end

  # this message is sent when this process should die
  # because it is being moved, use this as an opportunity
  # to clean up
  @impl true
  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end
end