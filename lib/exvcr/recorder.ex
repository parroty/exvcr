defmodule ExVCR.Recorder do
  @moduledoc """
  Provides data saving/loading capability for HTTP interactions.
  """

  alias ExVCR.Handler
  alias ExVCR.Actor.Responses
  alias ExVCR.Actor.Options

  @doc """
  Initialize recorder.
  """
  def start(options) do
    ExVCR.Checker.start([])

    {:ok, act_responses} = Responses.start([])
    {:ok, act_options}   = Options.start(options)

    recorder = %ExVCR.Record{options: act_options, responses: act_responses}

    if stub = options(recorder)[:stub] do
      set(stub, recorder)
    else
      load_from_json(recorder)
    end
    recorder
  end

  @doc """
  Provides entry point to be called from :meck library. HTTP request arguments are specified as args parameter.
  If response is not found in the cache, access to the server.
  """
  def request(args) do
    ExVCR.Actor.CurrentRecorder.get()
    |> Handler.get_response(args)
  end

  @doc """
  Load record-data from json file.
  """
  def load_from_json(recorder) do
    file_path   = get_file_path(recorder)
    custom_mode = options(recorder)[:custom]
    adapter     = options(recorder)[:adapter]
    responses   = ExVCR.JSON.load(file_path, custom_mode, adapter)
    set(responses, recorder)
  end

  @doc """
  Save record-data into json file.
  """
  def save(recorder) do
    file_path = get_file_path(recorder)
    if File.exists?(file_path) == false do
      ExVCR.JSON.save(file_path, ExVCR.Recorder.get(recorder))
    end
  end

  @doc """
  Returns the file path of the save/load target, based on the custom_mode(true or false).
  """
  def get_file_path(recorder) do
    opts = options(recorder)
    directory = case opts[:custom] do
      true  -> ExVCR.Setting.get(:custom_library_dir)
      _     -> ExVCR.Setting.get(:cassette_library_dir)
    end
    "#{directory}/#{opts[:fixture]}.json"
  end

  def options(recorder),                 do: Options.get(recorder.options)
  def get(recorder),                     do: Responses.get(recorder.responses)
  def set(responses, recorder),          do: Responses.set(recorder.responses, responses)
  def append(recorder, x),               do: Responses.append(recorder.responses, x)
  def pop(recorder),                     do: Responses.pop(recorder.responses)
  def update(recorder, finder, updater), do: Responses.update(recorder.responses, finder, updater)
end
