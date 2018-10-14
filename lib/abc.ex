defmodule ABC do

  @doc """
  Starts a broadcaster. This broadcaster will broadcast all messages sent to it via `ABC.broadcast`

  Each channel that you setup will receive the messages - provided you have something to consume the items from the Channel
  """
  def start_broadcaster(name) do
    Swarm.register_name(name, __MODULE__.Broadcaster.Supervisor, :register, [name])
  end

  @doc """
  Starts a channel. The channel needs a name, and an already started broadcaster.

  Each channel requires that you setup workers that subscribe to them before they will get any messages.
  """
  def start_channel({name, _broadcaster} = spec) do
    Swarm.register_name(name, __MODULE__.Channel.Supervisor, :register, [spec])
  end

  @doc """
  Stream from a broadcaster. This has the same function signature of `GenStage.stream`.

  You'll need to use `ABC.stream` so that we can reference the broadcaster correctly via swarm.
  """
  def stream(subscriptions, options \\ []) do
    subscriptions =
      Enum.map subscriptions, fn 
        {:via, :swarm, _} = sub -> sub
        {{:via, :swarm, _}, _} = sub -> sub
        {producer, opts} -> {{:via, :swarm, producer}, opts}
        producer -> {:via, :swarm, producer}
      end
    
    GenStage.stream(subscriptions, options)
  end

  @doc """
  Broadcast a message to all connected channels and streams.
  """
  def broadcast(broadcaster_name, event, timeout \\ 5_000) do
    GenStage.call({:via, :swarm, broadcaster_name}, {:broadcast, event}, timeout)
  end
end
