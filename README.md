# Immutablebot

**An IRC bot written in Elixir**

Heavily borrowed from [spoonbot](https://github.com/nicholasf/spoonbot).

## Notes

Right now, only SSL connections are made. Plain TCP is not planned to be supported.

## Prerequisites

* Elixir [installation guide](http://elixir-lang.org/install.html)
* Erlang [installation binaries](https://www.erlang-solutions.com/resources/download.html)

## Installation

  1. Clone this repo

  2. Install dependencies with hex

      ```
      mix deps.get
      ```

## Running immutablebot

  1. Make your own config file in the config directory. The option are self explanatory.

  2. Run it using `MIX_ENV` to call the file at compile time. If we added `example.exs`, then:

      ```
      MIX_ENV=example iex -S mix
      ```
  Note: if you use `prod` then be aware you will trigger protocol consolidation [described here](http://blog.plataformatec.com.br/2015/04/build-embedded-and-start-permanent-in-elixir-1-0-4/).

  3. You will get an interactive Elixir prompt and a scrolling view of the incoming lines. You have
  control of the `Immutablebot.Server`, which is an Elixir `GenServer`.

## Adding commands

Immutablebot commands are straightforward regex matches with a function attached. The `Command.Agent` holds a HashDict which can be added to either from an interactive console or through a file. The default commands are loaded from `lib/immutablebot/Commands/commands.exs`.

## Using APIs

The only API configured right now is using [HTTPoison](https://github.com/edgurgel/httpoison) to scrape the [HackerNews API](https://github.com/HackerNews/API) and grab a random comment.
