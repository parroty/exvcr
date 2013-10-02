defrecord ExVCR.Record, fixture: nil, options: nil, responses: nil

defmodule ExVCR.Recorder do
  @moduledoc """
  Provides feature to record and replay HTTP interactions.
  """
  alias ExVCR.Actor.Responses
  alias ExVCR.Actor.Fixture
  alias ExVCR.Actor.Options

  @doc "perform initialization"
  def start(fixture, options) do
   {:ok, act_responses} = Responses.start([])
   {:ok, act_fixture}   = Fixture.start(fixture)
   {:ok, act_options}   = Options.start(options)

   recorder = ExVCR.Record.new(fixture: act_fixture, options: act_options, responses: act_responses)
   ExVCR.JSON.load(fixture, options) |> set_responses(recorder)

   recorder
  end

  @doc "Save recorded results into json file"
  def save(recorder) do
    file_name = get_file_path(recorder)
    if File.exists?(file_name) == false do
      ExVCR.JSON.save(file_name, recorder)
    end
  end

  @doc """
  Provides entry point to be called from :meck library.
  http request arguments are specified as args parameter.
  """
  def respond(recorder, request) do
    if File.exists?(get_file_path(recorder)) do
      get_response_from_cache(recorder)
    else
      get_response_from_server(request, recorder)
    end
  end

  def get_response_from_cache(recorder) do
    {status_code, headers, body} = pop_response(recorder)
    {:ok, status_code, headers, body}
  end

  def get_response_from_server(request, recorder) do
    response = :meck.passthrough(request)
    append_response(recorder, ExVCR.JSON.parse(request, response))
    response
  end

  def get_file_path(recorder), do: ExVCR.JSON.get_file_path(get_fixture(recorder), get_options(recorder))

  def get_fixture(recorder), do: Fixture.get(recorder.fixture)
  def get_options(recorder), do: Options.get(recorder.options)

  def get_responses(recorder),            do: Responses.get(recorder.responses)
  def set_responses(responses, recorder), do: Responses.set(recorder.responses, responses)

  def append_response(recorder, x), do: Responses.append(recorder.responses, x)
  def pop_response(recorder),       do: Responses.pop(recorder.responses)
end