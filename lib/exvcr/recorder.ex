defrecord ExVCR.Record, fixture: nil, options: nil, responses: nil
defrecord ExVCR.Request, url: nil, headers: [], method: nil, body: nil, options: []
defrecord ExVCR.Response, status_code: nil, headers: [], body: nil

defmodule ExVCR.Recorder do
  @moduledoc """
  Provides feature to record and replay HTTP interactions.
  """
  alias ExVCR.Handler
  alias ExVCR.Actor.Responses
  alias ExVCR.Actor.Fixture
  alias ExVCR.Actor.Options

  @doc "perform initialization"
  def start(fixture, options) do
   {:ok, act_responses} = Responses.start([])
   {:ok, act_fixture}   = Fixture.start(fixture)
   {:ok, act_options}   = Options.start(options)

   recorder = ExVCR.Record.new(fixture: act_fixture, options: act_options, responses: act_responses)
   ExVCR.JSON.load(fixture, options) |> Handler.set(recorder)

   recorder
  end

  @doc "Save recorded results into json file"
  def save(recorder) do
    file_name = get_file_path(recorder)
    if File.exists?(file_name) == false do
      ExVCR.JSON.save(file_name, ExVCR.Handler.get(recorder))
    end
  end

  @doc """
  Provides entry point to be called from :meck library.
  http request arguments are specified as args parameter.
  """
  def respond(recorder, request) do
    get_response_from_cache(request, recorder) ||
      get_response_from_server(request, recorder)
  end

  @doc "get response from recorded json"
  def get_response_from_cache(request, recorder) do
    case Handler.find_response(Enum.first(request), recorder) do
      nil -> nil
      {status_code, headers, body} -> {:ok, status_code, headers, body}
    end
  end

  @doc "get response from server, then record them"
  def get_response_from_server(request, recorder) do
    response = :meck.passthrough(request)
    Handler.append(recorder, ExVCR.JSON.to_string(request, response))
    response
  end

  def get_file_path(recorder) do
    ExVCR.JSON.get_file_path(
      Fixture.get(recorder.fixture),
      Options.get(recorder.options)
    )
  end
end

defmodule ExVCR.Handler do
  alias ExVCR.Actor.Responses

  def find_response(url, recorder) do
    do_find_response(get(recorder), url)
  end

  defp do_find_response([], _target_url), do: nil
  defp do_find_response([head|tail], target_url) do
    if head[:request].url == iolist_to_binary(target_url) do
      { head[:response].status_code, head[:response].headers, head[:response].body }
    else
      do_find_response(tail, target_url)
    end
  end

  def get(recorder),            do: Responses.get(recorder.responses)
  def set(responses, recorder), do: Responses.set(recorder.responses, responses)
  def append(recorder, x),      do: Responses.append(recorder.responses, x)
  def pop(recorder),            do: Responses.pop(recorder.responses)
end
