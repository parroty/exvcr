defmodule ExVCR.Handler do
  @moduledoc """
  Provide operations for recorded responses.
  """
  alias ExVCR.Actor.Responses
  alias ExVCR.Actor.Options

  @doc """
  Find a response from the recorded lists which matches the request parameter.
  """
  def find_response(request, recorder) do
    target_url = Enum.first(request)
    do_find_response(get(recorder), target_url) |> verify_response(recorder, target_url)
  end

  defp verify_response(response, recorder, target_url) do
    options = Options.get(recorder.options)
    if response == nil and options[:custom] == true do
      raise ExVCRError.new(message: "response for \"#{target_url}\" was not found in the custom cassette")
    else
      response
    end
  end

  defp do_find_response([], _target_url), do: nil
  defp do_find_response([head|tail], target_url) do
    case head[:request].url == iolist_to_binary(target_url) do
      true  -> head[:response]
      false -> do_find_response(tail, target_url)
    end
  end

  def get(recorder),            do: Responses.get(recorder.responses)
  def set(responses, recorder), do: Responses.set(recorder.responses, responses)
  def append(recorder, x),      do: Responses.append(recorder.responses, x)
  def pop(recorder),            do: Responses.pop(recorder.responses)
end
