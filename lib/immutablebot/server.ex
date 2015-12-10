defmodule Immutablebot.Server do
  use GenServer

  #####
  # External API

  def start_link do
    { :ok, pid } = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def connect do
    GenServer.call __MODULE__, :connect
  end

  def say(phrase, target) do
    data = "PRIVMSG #{target} :#{phrase}"
    GenServer.cast __MODULE__, { :send, data }
  end

  def join(channel) do
    data = "JOIN #{ channel }"
    GenServer.cast __MODULE__, { :send, data }
  end

  def set_nick(nickname) do
    data = "NICK #{nickname}"
    GenServer.cast __MODULE__, { :send, data }
  end

  #####
  # GenServer implementation

  def handle_call(:connect, _from, _) do
    server = Application.get_env(:immutablebot, :server)
    port = Application.get_env(:immutablebot, :port )
    nick = Application.get_env(:immutablebot, :nick)
    { :ok, socket } = :ssl.connect(:erlang.binary_to_list(server), port, [:binary, {:active, true}])
    GenServer.cast __MODULE__, { :send, "NICK #{nick}"}
    GenServer.cast __MODULE__, { :send, "USER #{nick} #{server} #{nick} :#{nick}" }
    { :reply, socket, socket }
  end

  def handle_cast({:new_line, data}, socket) do
    nick = Application.get_env(:immutablebot, :nick)
    channel = Application.get_env(:immutablebot, :channel)
    server = Enum.at(Regex.split(~r/\s/, data), 1)
    ping      = ~r/\APING/
    motd_end  = ~r/\/MOTD/
    privmsg   = ~r/PRIVMSG/
    { :ok, private_message } = Regex.compile("PRIVMSG #{nick} ")
    { :ok, channel_message }  = Regex.compile("PRIVMSG #{channel} ")
    IO.puts data

    if Regex.match?(motd_end, data), do: GenServer.cast __MODULE__, { :send, "JOIN #{channel}" }
    if Regex.match?(ping, data), do: GenServer.cast __MODULE__, { :send, "PONG #{server}" }
    if Regex.match?(privmsg, data) do
      message = String.split(data, ":")
      phrase = String.strip(Enum.at message, Enum.count(message)-1)
      command = Command.Agent.find(phrase)

      if command do
        { pattern, func } = command
        args = Regex.scan(pattern, phrase, capture: :all_but_first)
        speaker_name = Enum.at(String.split(Enum.at(message, 1), "!"), 0)
        args = Enum.filter(args, &((Enum.count &1) > 0))
        result = func.(speaker_name, Enum.at(args, 0))

        if Regex.match?(private_message, data) do
          target = speaker_name
        end
        if Regex.match?(channel_message, data) do
          target = channel
        end

        GenServer.cast __MODULE__, { :send, "PRIVMSG #{target} :#{result}" }
      end
    end
    { :noreply, socket }
  end

  def handle_cast({:send, data}, socket) do
    IO.puts "sending #{data}"
    :ssl.send(socket, "#{data} \r\n")
    { :noreply, socket }
  end

  def handle_info({_, _, data}, socket) do
    GenServer.cast __MODULE__, { :new_line, data }
    { :noreply, socket }
  end
end
