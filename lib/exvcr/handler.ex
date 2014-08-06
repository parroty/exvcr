defmodule ExVCR.Handler do
  @moduledoc """
  Provide operations for request/response.
  """

  alias ExVCR.Recorder
  alias ExVCR.Actor.Options

  @doc """
  Get response from either server or cache.
  """
  def get_response(recorder, request) do
    get_response_from_cache(request, recorder) || get_response_from_server(request, recorder)
  end

  @doc """
  Get response from the cache (pre-recorded cassettes).
  """
  def get_response_from_cache(request, recorder) do
    stub_mode = Options.get(recorder.options)[:custom] == true ||
                Options.get(recorder.options)[:stub] != nil
    adapter = ExVCR.Recorder.options(recorder)[:adapter]
    params = adapter.generate_keys_for_request(request)
    response = find_response(Recorder.get(recorder), params, stub_mode)
    response = adapter.hook_response_from_cache(response)

    case { response, stub_mode } do
      { nil, true } ->
        raise %ExVCR.InvalidRequestError{
          message: "response for [URL:#{params[:url]}, METHOD:#{params[:method]}] was not found" }
      { nil, false } ->
        nil
      { response, _ } ->
        ExVCR.Checker.add_cache_count(recorder)
        adapter.get_response_value_from_cache(response)
    end
  end

  defp find_response([], _keys, _stub_mode), do: nil
  defp find_response([response|tail], keys, stub_mode) do
    case match_response(response, keys, stub_mode) do
      true  -> response[:response]
      false -> find_response(tail, keys, stub_mode)
    end
  end

  defp match_response(response, keys, stub_mode) do
    match_by_url(response, keys, stub_mode) and match_by_method(response, keys)
  end

  defp match_by_url(response, keys, stub_mode) do
    if stub_mode do
      pattern = Regex.compile!("^#{response[:request].url}.*$")
      Regex.match?(pattern, to_string(keys[:url]))
    else
      request_url = response[:request].url |> to_string |> ExVCR.Filter.strip_query_params
      key_url = keys[:url] |> to_string |> ExVCR.Filter.strip_query_params

      request_url == key_url
    end
  end

  defp match_by_method(head, params) do
    if params[:method] == nil || head[:request].method == nil do
      true
    else
      to_string(params[:method]) == head[:request].method
    end
  end

  defp get_response_from_server(request, recorder) do
    raise_error_if_cassette_already_exists(recorder)
    adapter = ExVCR.Recorder.options(recorder)[:adapter]
    response = :meck.passthrough(request)
                 |> adapter.hook_response_from_server
    Recorder.append(recorder, adapter.convert_to_string(request, response))
    ExVCR.Checker.add_server_count(recorder)
    response
  end

  defp raise_error_if_cassette_already_exists(recorder) do
    file_path = ExVCR.Recorder.get_file_path(recorder)
    if File.exists?(file_path) do
      message = """
      Request did not match with any one in the current cassette: #{file_path}.
      Delete the current cassette with [mix vcr.delete] and re-record.
      """
      raise %ExVCR.RequestNotMatchError{message: message}
    end
  end
end
