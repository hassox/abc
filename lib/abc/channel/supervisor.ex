defmodule ABC.Channel.Supervisor do
  @moduledoc false
  use Supervisor

  @doc false
  def register(name) do
    Supervisor.start_child(__MODULE__, {ABC.Channel, name})
  end

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__, max_restarts: 50)
  end

  @impl true
  def init(opts) do
    opts = opts ++ [strategy: :one_for_one]

    children = []

    Supervisor.init(children, opts)
  end
end