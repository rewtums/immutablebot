defmodule Command.Agent do
    @name { :global, __MODULE__ }

    def start_link do
      Agent.start_link( fn-> MapSet.new end, name: @name )
    end

    def add(command) do
      Agent.update(@name, fn(set) -> MapSet.put(set, command) end)
    end

    def find(phrase) do
      Agent.get(@name, fn(set) -> set end)
        |> Enum.find(fn ({ pattern, _ }) -> Regex.match?(pattern, phrase) end)
    end

    def load(phrase, func) do
      with { :ok, pattern } <-  Regex.compile(phrase) do
        Agent.update(@name, fn(set) -> MapSet.put(set, { pattern, func }) end)
      end
    end

    def show do
      Agent.get(@name, fn(set) -> set end)
    end
end
