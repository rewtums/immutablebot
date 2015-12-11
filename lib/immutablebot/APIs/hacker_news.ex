defmodule API.Hacker_News do
  @user_agent [ {"User-agent", "IRCbot bot@irc.org"} ]

  def fetch do
    get_story
    |> get_comment
    |> hn_url
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> return_text
  end

  def get_story do
    top_stories_url
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> return_story_id
  end

  def get_comment(story) do
    hn_url(story)
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> return_comment_id
  end

  def hn_url(item) do
    "https://hacker-news.firebaseio.com/v0/item/#{item}.json?print=pretty"
  end

  def top_stories_url do
    "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
  end

  def ycombinator_url(item) do
    "news.ycombinator.com/item?id=#{item}"
  end

  def handle_response({ :ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    { :ok, :jsx.decode(body) }
  end

  def handle_response({ :ok, %HTTPoison.Response{status_code: _, body: body}}) do
    { :error, :jsx.decode(body)}
  end

  def return_story_id({ :ok, json }) do
    _ = :random.seed(:os.timestamp)
    story_id = Enum.random json
    if check_story_for_comments(story_id) > 0 do
      story_id
    else
      return_story_id({ :ok, json })
    end
  end

  def check_story_for_comments(story) do
    {:ok, json} = hn_url(story) |> HTTPoison.get(@user_agent) |> handle_response
    dict = Enum.into(json, HashDict.new)
    comments_count = HashDict.get(dict, "descendants", 0)
    comments_count
  end

  def return_text({ :ok, json }) do
    dict = Enum.into(json, HashDict.new)
    text = HtmlEntities.decode(HtmlSanitizeEx.strip_tags(HashDict.get(dict, "text", "")))
    comment_id = HashDict.get(dict, "id", 0)
    if String.length(text) > 298 do
      String.slice(text, 0, 298)
    else
      text
    end
  end

  def return_text({ :error, json }) do
    dict = Enum.into(json, HashDict.new)
    error = HashDict.get(dict, "error")
    Enum.join ["There was an error: ", error]
  end

  def return_comment_id({ :ok, json }) do
    dict = Enum.into(json, HashDict.new)
    comments = HashDict.get(dict, "kids", [])
    comments_count = HashDict.get(dict, "descendants", 0)
    if comments_count > 0 do
      _ = :random.seed(:os.timestamp)
      Enum.random comments
    end
  end
end
