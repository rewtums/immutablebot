# Immutablebot

**A simple IRC bot written in Elixir**

This bot is built around the concept of Regex matching certain command phrases
and then generating a response. This simple implementation requires no complex (OOP-like) machinations or metaprogramming, because IRC just isn't that hard.

Heavily borrowed from [spoonbot](https://github.com/nicholasf/spoonbot).

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

  1. Make your own config file in the config directory. The options are self explanatory.

  2. Run it using `MIX_ENV` to call the file at compile time. If we added `example.exs`, then:

      ```
      MIX_ENV=example iex -S mix
      ```
  Note: if you use `prod` then be aware you will trigger protocol consolidation [described here](http://blog.plataformatec.com.br/2015/04/build-embedded-and-start-permanent-in-elixir-1-0-4/).

  3. You will get an interactive Elixir prompt and a scrolling view of the incoming lines. You have
  control of the `Immutablebot.Server`, which is an Elixir `GenServer`.

## Adding commands

Immutablebot commands are straightforward regex matches with a function attached. The `Command.Agent` holds a `HashDict` which can be added to either from an interactive console or through a file. The default commands are loaded from `lib/immutablebot/Commands/commands.exs`.

The structure of a command is simply a tuple:

      { "Regex to be compiled", fn(speaker, args) -> "Return string" end }

Where `speaker` is the user name of the IRC user who sent the message and `args` represents an `Enum` of the result of a `Regex.Scan` with the supplied `Regex`.

You can load commands interactively through `iex` or by loading a `.exs` file that imports `Command.Agent` and then loads each one. Your choice.

## Using APIs

The only API configured right now is using [HTTPoison](https://github.com/edgurgel/httpoison) to scrape the [HackerNews API](https://github.com/HackerNews/API) and grab a random comment.

## Notes

SSL only connections. Plain TCP is so 2007.

## TODO

LOTS OF THE THINGS.
