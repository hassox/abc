defmodule ABC.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {ABC.Broadcaster.Supervisor, [max_restarts: 50]},
      {ABC.Channel.Supervisor, [max_restarts: 50]},

      # Starts a worker by calling: Abc.Worker.start_link(arg)
      # {Abc.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ABC.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
