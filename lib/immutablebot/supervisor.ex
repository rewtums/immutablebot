defmodule Immutablebot.Supervisor do
  use Supervisor

  def start_link do
    {:ok, sup } = Supervisor.start_link(__MODULE__, [])
    start_workers(sup)
    Code.require_file("lib/immutablebot/Commands/commands.exs")
    {:ok, sup }
  end

  def start_workers(sup) do
    { :ok, _command_pid } = Supervisor.start_child(sup, worker(Command.Agent, []))
    { :ok, _bot_pid } = Supervisor.start_child(sup, worker(Immutablebot.Server, []))
    { :ok, _socket_pid } = Supervisor.start_child(sup, worker(Immutablebot.Socket, []))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end
