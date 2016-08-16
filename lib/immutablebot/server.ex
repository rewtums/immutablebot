defmodule Immutablebot.Server do
  use GenServer
  require Logger

  @name __MODULE__

  #####
  # External API

  def start_link do
    { :ok, _pid } = GenServer.start_link(@name, :ok, name: @name)
  end

  def say(phrase, target) do
    data = "PRIVMSG #{target} :#{phrase}"
    GenServer.cast @name, { :send, data }
  end

  def say(data) do
    GenServer.cast @name, {:send, data}
  end

  def join(channel) do
    data = "JOIN #{ channel }"
    GenServer.cast @name, { :send, data }
  end

  def set_nick(nickname) do
    data = "NICK #{nickname}"
    GenServer.cast @name, { :send, data }
  end

  #####
  # Environment information

  defp nick, do: Application.get_env(:immutablebot, :nick)
  defp channel, do: Application.get_env(:immutablebot, :channel)
  defp server, do: Application.get_env(:immutablebot, :server)
  defp port, do: Application.get_env(:immutablebot, :port )

  #####
  # GenServer implementation

  def init(:ok) do
    { :ok, socket } = :ssl.connect(:erlang.binary_to_list(server), port, [:binary, {:active, true}])
    say "NICK #{nick}"
    say "USER #{nick} #{server} #{nick} :#{nick}"
    { :ok, socket }
  end

  def handle_cast({:new_line, data}, socket) do
    connected_server = Enum.at(Regex.split(~r/\s/, data), 1)
    ping      = ~r/\APING/
    motd_end  = ~r/\/MOTD/
    privmsg   = ~r/ PRIVMSG /

    Logger.debug data

    if Regex.match?(motd_end, data), do: say "JOIN #{channel}"
    if Regex.match?(ping, data), do: say "PONG #{connected_server}"
    if Regex.match?(privmsg, data) do
      [ info, phrase ] = Enum.map(Regex.split(~r/:/, data, [trim: true, parts: 2]), &(String.strip(&1)))
      [ user, target ] = Enum.map(String.split(info, "PRIVMSG"), &(String.strip(&1)))
      [ speaker_name, username ] = Enum.map(String.split(user, "!"), &(String.strip(&1)))

      command = Command.Agent.find(phrase)

      if command do
        { pattern, func } = command
        [ args ] = Regex.scan(pattern, phrase)
        result = func.(speaker_name, args)

        if target == "#{nick}" do
          say "PRIVMSG #{speaker_name} :#{result}"
        else
          say "PRIVMSG #{target} :#{result}"
        end
      end
    end
    { :noreply, socket }
  end

  def handle_cast({:send, data}, socket) do
    Logger.debug "sending #{data}"
    :ssl.send(socket, "#{data} \r\n")
    { :noreply, socket }
  end

  def handle_info({_, _, data}, socket) do
    GenServer.cast @name, { :new_line, data }
    { :noreply, socket }
  end
end
