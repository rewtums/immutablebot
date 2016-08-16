import Command.Agent

load "^no u$", fn (_speaker, _args) ->
  "no u"
end

load "^yes u$", fn (_speaker, _args) ->
  "yes no"
end

load "(^\\.bots$)", fn (_speaker, _args) ->
  "Reporting in! [Elixir] https://github.com/rewtums/immutablebot"
end

load "(^\\.bigshrug$)", fn (_speaker, _args) ->
  "¯\\_____________(ツ)_____________/¯"
end

load "(^\\.hn$)", fn (_speaker, _args) ->
  API.Hacker_News.fetch
end

load "(^\\.rip) (.*)", fn (_speaker, args) ->
  "RIP in pieces #{Enum.at args, 2}"
end
