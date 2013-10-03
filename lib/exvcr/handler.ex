defmodule ExVCR.Handler do
  @moduledoc """
  Provider operations for recorded responses
  """
  alias ExVCR.Actor.Responses

  def find_response(request, recorder) do
    target_url = Enum.first(request)
    do_find_response(get(recorder), target_url)
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
