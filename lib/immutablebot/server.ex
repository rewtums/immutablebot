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
    GenServer.cast Immutablebot.Socket, { :send, data }
  end

  def say(data) do
    GenServer.cast Immutablebot.Socket, { :send, data }
  end

  def join(channel) do
    data = "JOIN #{ channel }"
    GenServer.cast Immutablebot.Socket, { :send, data }
  end

  def set_nick(nickname) do
    data = "NICK #{nickname}"
    GenServer.cast Immutablebot.Socket, { :send, data }
  end

  #####
  # Environment information

  defp nick, do: Application.get_env(:immutablebot, :nick)
  defp channel, do: Application.get_env(:immutablebot, :channel)

  #####
  # GenServer implementation

  def handle_cast( { :new_line, data }, state ) do
    connected_server = Enum.at(Regex.split(~r/\s/, data), 1)
    ping      = ~r/\APING/
    motd_end  = ~r/\/MOTD/
    privmsg   = ~r/ PRIVMSG /

    Logger.debug data

    if Regex.match?(motd_end, data), do: say "JOIN #{channel}"
    if Regex.match?(ping, data), do: say "PONG #{connected_server}"
    if Regex.match?(privmsg, data) do
      [ user, _msg, target, phrase ] = data
                                         |> String.split(~r/ /, parts: 4, trim: true)
                                         |> Enum.map(&(String.replace_leading(String.trim(&1), ":", "")))

      [ speaker_name, username ] = String.split(user, "!", parts: 2, trim: true) 

      with { pattern, func } <- Command.Agent.find(phrase) do
        [ args ] = Regex.scan(pattern, phrase)
        result = func.(speaker_name, args)

        if target == "#{nick}" do
          say "PRIVMSG #{speaker_name} :#{result}"
        else
          say "PRIVMSG #{target} :#{result}"
        end
      end
    end

    { :noreply, state }
  end
end
