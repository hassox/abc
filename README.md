# ABC

A gen stage + swarm based channel broadcaster.

```text
[Broadcaster1] -> [ChannelOne] -> (worker1, worker2, worker3)
               -> [ChannelTwo] -> (worker1, worker2, worker3)

[Broadcaster2] -> [ChannelFour] -> (worker1, worker2, worker3)
               -> [ChannelFive] -> (worker1, worker2, worker3)
```

Allows you to setup a (many) broadcaster. When you broadcast a message it will be distributed to all associated channels. 
Each channel will provides each message to one subscriber.

As an example. A communication distribution center.

```text
[MessageBroadcaster] -> [StackChannel] -> (slack workers...)
                     -> [SmsChannel]   -> (sms workers...)
                     -> [LogChannel]   -> (log workers...)
                     -> [PhxChannelBridge] -> (Phx channel workers...)
```

In this case, each worker type will receive each message broadcast.
Because we use swarm, each broadcaster and channel is singular within your cluster so you'll only have one per cluster.

We use this for broadcasting state

## Usage

When you start your application:

```elixir
defmodule MyApplication do
  # ... snip ...
  use Application

  def start(_type, _args) do
    ABC.start_broadcaster(StateBroadcaster)
    ABC.start_channel({StateEmailChannel, StateBroadcaster})

    children = [
      # ...
    ]
 
    opts = [strategy: :one_for_one, name: MyApplication.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Here, we're starting a `StateBroadcaster`. We then attach a channel to it `StateEmailChannel`.

You'll then need to setup gen stage `consumer` to consume from the `StateEmailChannel`.

## Setting up workers

Each worker is a consumer for a gen stage.

```elixir
defmodule MyApplication.EmailSender do
  use GenStage

  def start_link(args) do
    GenStage.start_link(__MODULE__, args)
  end

  def init(args) do
    {:consumer, args, subscribe_to: [{{:via, :swarm, StateEmailChannel}, max_demand: 1}]}
  end

  def child_spec(id) do
    %{
      id: :"#{__MODULE__}#{id}",
      start: {__MODULE__, :start_link, [id]},
    }
  end

  def handle_events(events, _from, state) do
    # send the emails
    {:noreply, [], state}
  end
end
```

Put these workers in your supervisor.

### Broadcasting a message

```elixir
ABC.broadcast(StateBroadcaster, my_message)
```

### Streaming from a broadcaster

Since we're using `GenStage`, you can setup a stream to consume events from your broadcaster

```elixir
ABC.stream([{StateBroadcaster, max_demand: 10, cancel: :transient}])
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `abc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:abc, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/abc](https://hexdocs.pm/abc).

