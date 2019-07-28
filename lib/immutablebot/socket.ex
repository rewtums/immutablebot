defmodule Immutablebot.Socket do
  use GenServer

  @name __MODULE__

  defp nick(), do: Application.get_env(:immutablebot, :nick)
  defp server(), do: Application.get_env(:immutablebot, :server)
  defp port(), do: Application.get_env(:immutablebot, :port )

  def start_link() do
    GenServer.start_link(@name, :ok, name: @name)
  end

  def init(:ok) do
    { :ok, socket } = :ssl.connect(:erlang.binary_to_list(server()), port(), [:binary, {:active, true}])

    :ssl.send(socket, "NICK #{nick()} \r\n")
    :ssl.send(socket, "USER #{nick()} #{server()} #{nick()} :#{nick()} \r\n")

    { :ok, socket }
  end

  def handle_cast({:send, data}, socket) do
    :ssl.send(socket, "#{data} \r\n")

    { :noreply, socket }
  end

  def handle_info( { _, _, data }, socket ) do
    GenServer.cast(Immutablebot.Server, { :new_line, data })

    { :noreply, socket }
  end
end
