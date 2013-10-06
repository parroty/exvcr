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
    custom_mode = Options.get(recorder.options)[:custom]
    target_url = Enum.first(request)
    do_find_response(get(recorder), target_url, custom_mode) |> verify_response(target_url, custom_mode)
  end

  defp verify_response(response, target_url, custom_mode) do
    if response == nil and custom_mode == true do
      raise ExVCR.InvalidRequestError.new(message: "response for \"#{target_url}\" was not found in the custom cassette")
    else
      response
    end
  end

  defp do_find_response([], _target_url, _custom_mode), do: nil
  defp do_find_response([head|tail], target_url, custom_mode) do
    case match(head, target_url, custom_mode) do
      true  -> head[:response]
      false -> do_find_response(tail, target_url, custom_mode)
    end
  end

  defp match(head, target_url, custom_mode) do
    if custom_mode do
      pattern = Regex.compile!("^#{head[:request].url}$")
      Regex.match?(pattern, target_url)
    else
      head[:request].url == iolist_to_binary(target_url)
    end
  end

  def get(recorder),            do: Responses.get(recorder.responses)
  def set(responses, recorder), do: Responses.set(recorder.responses, responses)
  def append(recorder, x),      do: Responses.append(recorder.responses, x)
  def pop(recorder),            do: Responses.pop(recorder.responses)
end
