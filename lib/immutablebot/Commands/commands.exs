import Command.Agent

load "^no u$", fn (speaker, args) ->
  "no u"
end

load "(^\\.bots$)", fn (speaker, args) ->
  "Reporting in! [Elixir] https://github.com/rewtums/immutablebot"
end

load "(^\\.hn$)", fn (speaker, args) ->
  API.Hacker_News.fetch
end

load "(^\\.rip) (.*)", fn (speaker, args) ->
  "RIP in pieces #{Enum.at args, 2}"
end
