defrecord ExVCR.Record, fixture: nil, options: nil, responses: nil

defmodule ExVCR.Recorder do
  alias ExVCR.Actor.Responses
  alias ExVCR.Actor.Fixture
  alias ExVCR.Actor.Options

  def start(fixture, options) do
   {:ok, act_responses} = Responses.start([])
   {:ok, act_fixture}   = Fixture.start(fixture)
   {:ok, act_options}   = Options.start(options)

   ExVCR.Record.new(fixture: act_fixture, options: act_options, responses: act_responses)
  end

  def save(recorder) do
    file_name = get_file_name(recorder)
    if File.exists?(file_name) == false do
      ExVCR.JSON.save(file_name, recorder)
    end
  end

  def respond(recorder, args) do
    file_name = get_file_name(recorder)
    case File.exists?(file_name) do
      true  -> load_response_from_file(file_name, recorder)
      _     -> get_response_from_server(args, recorder)
    end
  end

  defp load_response_from_file(file_name, recorder) do
    if ExVCR.Recorder.get_responses(recorder) == [] do
      set_responses(recorder, ExVCR.JSON.load(file_name))
    end

    {status_code, headers, body} = pop_response(recorder)
    {:ok, status_code, headers, body}
  end

  defp get_response_from_server(request, recorder) do
    response = :meck.passthrough(request)
    append_response(recorder, ExVCR.JSON.parse(request, response))
    response
  end

  def get_file_name(recorder) do
    ExVCR.JSON.get_file_name(get_fixture(recorder), get_options(recorder))
  end

  def get_fixture(recorder), do: Fixture.get(recorder.fixture)
  def get_options(recorder), do: Options.get(recorder.options)

  def get_responses(recorder),            do: Responses.get(recorder.responses)
  def set_responses(recorder, responses), do: Responses.set(recorder.responses, responses)

  def append_response(recorder, x), do: Responses.append(recorder.responses, x)
  def pop_response(recorder),       do: Responses.pop(recorder.responses)
end