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
    url    = Enum.fetch!(request, 0)
    method = Enum.fetch!(request, 2)
    params = [url: url, method: method]
    do_find_response(get(recorder), params, custom_mode) |> verify_response(params, custom_mode)
  end

  defp verify_response(response, params, custom_mode) do
    if response == nil and custom_mode == true do
      raise ExVCR.InvalidRequestError.new(message: "response for [URL:#{params[:url]}, METHOD:#{params[:method]}] was not found in the custom cassette")
    else
      response
    end
  end

  defp do_find_response([], _params, _custom_mode), do: nil
  defp do_find_response([head|tail], params, custom_mode) do
    case match(head, params, custom_mode) do
      true  -> head[:response]
      false -> do_find_response(tail, params, custom_mode)
    end
  end

  defp match(head, params, custom_mode) do
    match_url(head, params, custom_mode) and match_method(head, params)
  end

  defp match_url(head, params, custom_mode) do
    if custom_mode do
      pattern = Regex.compile!("^#{head[:request].url}$")
      Regex.match?(pattern, params[:url])
    else
      head[:request].url == iolist_to_binary(params[:url])
    end
  end

  defp match_method(head, params) do
    if params[:method] == nil || head[:request].method == nil do
      true
    else
      atom_to_binary(params[:method]) == head[:request].method
    end
  end

  def get(recorder),            do: Responses.get(recorder.responses)
  def set(responses, recorder), do: Responses.set(recorder.responses, responses)
  def append(recorder, x),      do: Responses.append(recorder.responses, x)
  def pop(recorder),            do: Responses.pop(recorder.responses)
end
