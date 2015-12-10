defmodule Command.Agent do
    @name { :global, __MODULE__ }

    def start_link do
        Agent.start_link( fn-> HashSet.new end, name: @name )
    end 

    def add(command) do
        Agent.update(@name, fn(set) -> Set.put(set, command) end)
    end

    def find(phrase) do
        set = Agent.get(@name, fn(set) -> set end)
        Enum.find(set, fn ({ pattern, _ }) -> Regex.match?(pattern, phrase) end) 
    end

    def load(phrase, func) do
      { :ok, pattern } = Regex.compile(phrase)
      Agent.update(@name, fn(set) -> Set.put(set, { pattern, func }) end)
    end

    def show do
      set = Agent.get(@name, fn(set) -> set end)
      set
    end
end
