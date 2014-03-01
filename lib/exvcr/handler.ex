defmodule ExVCR.Handler do
  @moduledoc """
  Provide operations for request/response.
  """
  alias ExVCR.Recorder
  alias ExVCR.Actor.Options

  @doc """
  get response from either server or cache.
  """
  def get_response(recorder, request) do
    get_response_from_cache(request, recorder) || get_response_from_server(request, recorder)
  end

  def get_response_from_cache(request, recorder) do
    custom_mode = Options.get(recorder.options)[:custom] || false
    adapter     = ExVCR.Recorder.options(recorder)[:adapter]

    params = adapter.generate_keys_for_request(request)
    response = find_response(Recorder.get(recorder), params, custom_mode)
    response = adapter.hook_response_from_cache(response)

    case { response, custom_mode } do
      { nil, true } ->
        raise ExVCR.InvalidRequestError.new(message:
                "response for [URL:#{params[:url]}, METHOD:#{params[:method]}] was not found in the custom cassette")
      { nil, false } ->
        nil
      { response, _ } ->
        ExVCR.Checker.add_cache_count(recorder)
        adapter.get_response_value_from_cache(response)
    end
  end

  defp find_response([], _keys, _custom_mode), do: nil
  defp find_response([response|tail], keys, custom_mode) do
    case match_response(response, keys, custom_mode) do
      true  -> response[:response]
      false -> find_response(tail, keys, custom_mode)
    end
  end

  defp match_response(response, keys, custom_mode) do
    match_by_url(response, keys, custom_mode) and match_by_method(response, keys)
  end

  defp match_by_url(response, keys, custom_mode) do
    if custom_mode do
      pattern = Regex.compile!("^#{response[:request].url}$")
      Regex.match?(pattern, to_string(keys[:url]))
    else
      response[:request].url == iolist_to_binary(keys[:url])
    end
  end

  defp match_by_method(head, params) do
    if params[:method] == nil || head[:request].method == nil do
      true
    else
      atom_to_binary(params[:method]) == head[:request].method
    end
  end

  defp get_response_from_server(request, recorder) do
    adapter = ExVCR.Recorder.options(recorder)[:adapter]
    response = :meck.passthrough(request)
                 |> adapter.hook_response_from_server
    Recorder.append(recorder, adapter.convert_to_string(request, response))
    ExVCR.Checker.add_server_count(recorder)
    response
  end
end
