defmodule API.Hacker_News do
  require Logger

  def fetch do
    with { :ok, story_id } <- get_story do
      story_id
        |> get_comment
        |> hn_url
        |> HTTPoison.get([], [ssl: [{:verify, :verify_none}]])
        |> handle_response
        |> return_text
    else
      { :error, reason } -> "There was an error: " <> to_string(reason)
      _ -> "Repent now, for we are all doomed to failure"
    end
  end

  def get_story do
    top_stories_url
    |> HTTPoison.get([], [ssl: [{:verify, :verify_none}]])
    |> handle_response
    |> return_story_id
  end

  def comments_on_story(story) do
    story
    |> hn_url
    |> HTTPoison.get([], [ssl: [{:verify, :verify_none}]])
    |> handle_response
  end

  def get_comment(story) do
    story
    |> comments_on_story
    |> return_comment_id
  end

  def hn_url(item) do
    Logger.debug "Getting item #{item} from API"

    "https://hacker-news.firebaseio.com/v0/item/#{item}.json?print=pretty"
  end

  def top_stories_url do
    Logger.debug "Getting top stories from API"

    "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
  end

  def ycombinator_url(item) do
    "news.ycombinator.com/item?id=#{item}"
  end

  def handle_response({ :ok, %HTTPoison.Response{status_code: _, body: body}}) do
    { :ok, :jsx.decode(body) }
  end

  def handle_response({ :error, %HTTPoison.Error{id: _, reason: reason} }) do
    { :error, reason }
  end

  def return_story_id({ :ok, json }) do
    :rand.seed(:exsplus, :os.timestamp)

    story_id = Enum.random(json)

    if check_story_for_comments(story_id) > 0 do
      { :ok, story_id }
    else
      return_story_id({ :ok, json })
    end
  end

  def return_story_id({ :error, reason }) do
    { :error, reason }
  end

  def check_story_for_comments(story) do
    with { :ok, json } <- comments_on_story(story) do
      json
      |> Enum.into(%{})
      |> Map.get("descendants", 0)
    else
      _ -> 0
    end
  end

  def return_text({ :ok, json }) do
    text = json
             |> Enum.into(%{})
             |> Map.get("text", "")
             |> HtmlSanitizeEx.strip_tags
             |> HtmlEntities.decode
    
    if String.length(text) > 298 do
      String.slice(text, 0, 298)
    else
      text
    end
  end

  def return_text({ :error, reason }) do
    "There was an error" <> to_string(reason)
  end

  def return_comment_id({ :ok, json }) do
    :rand.seed(:exsplus, :os.timestamp)

    json
      |> Enum.into(%{})
      |> Map.get("kids", [])
      |> Enum.random
  end
end
