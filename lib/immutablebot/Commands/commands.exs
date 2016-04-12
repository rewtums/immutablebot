import Command.Agent

load "^no u$", fn (speaker, args) ->
  "no u"
end

load "^yes u$", fn (speaker, args) ->
  "yes no"
end

load "(^\\.bots$)", fn (speaker, args) ->
  "Reporting in! [Elixir] https://github.com/rewtums/immutablebot"
end

load "(^\\.bigshrug$)", fn (speaker, args) ->
  "¯\\_____________(ツ)_____________/¯"
end

load "(^\\.hn$)", fn (speaker, args) ->
  API.Hacker_News.fetch
end

load "(^\\.rip) (.*)", fn (speaker, args) ->
  "RIP in pieces #{Enum.at args, 2}"
end
