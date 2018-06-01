defmodule ExVCR.Handler do
  @moduledoc """
  Provide operations for request/response.
  """

  alias ExVCR.Recorder
  alias ExVCR.Actor.Options
  alias ExVCR.Util

  @doc """
  Get response from either server or cache.
  """
  def get_response(recorder, request) do
    if ignore_request?(request, recorder) do
      get_response_from_server(request, recorder, false)
    else
      get_response_from_cache(request, recorder) || get_response_from_server(request, recorder, true)
    end
  end

  @doc """
  Get response from the cache (pre-recorded cassettes).
  """
  def get_response_from_cache(request, recorder) do
    recorder_options = Options.get(recorder.options)
    adapter = ExVCR.Recorder.options(recorder)[:adapter]
    params = adapter.generate_keys_for_request(request)
    {response, responses} = find_response(Recorder.get(recorder), params, recorder_options)
    response = adapter.hook_response_from_cache(request, response)

    case { response, stub_mode?(recorder_options) } do
      { nil, true } ->
        raise ExVCR.InvalidRequestError,
          message: "response for [URL:#{params[:url]}, METHOD:#{params[:method]}] was not found"
      { nil, false } ->
        nil
      { response, _ } ->
        ExVCR.Checker.add_cache_count(recorder)
        Recorder.set(responses, recorder)
        adapter.get_response_value_from_cache(response)
    end
  end

  defp stub_mode?(options) do
    options[:custom] == true || options[:stub] != nil
  end

  defp stub_with_non_empty_request_body?(options) do
    options[:stub] != nil && List.first(options[:stub]).request.request_body != ""
  end

  defp has_match_requests_on(type, options) do
    flags = options[:match_requests_on] || []

    if is_list(flags) == false do
      raise "Invalid match_requests_on option is specified - #{inspect flags}"
    end

    Enum.member?(flags, type)
  end

  defp find_response(responses, keys, recorder_options), do: find_response(responses, keys, recorder_options, [])
  defp find_response([], _keys, _recorder_options, _acc), do: {nil, nil}
  defp find_response([response|tail], keys, recorder_options, acc) do
    case match_response(response, keys, recorder_options) do
      true  -> {response[:response], Enum.reverse(acc) ++ tail ++ [response]}
      false -> find_response(tail, keys, recorder_options, [response|acc])
    end
  end

  defp match_response(response, keys, recorder_options) do
    match_by_url(response, keys, recorder_options)
      and match_by_method(response, keys)
      and match_by_request_body(response, keys, recorder_options)
      and match_by_headers(response, keys, recorder_options)
  end

  defp match_by_url(response, keys, recorder_options) do
    request_url = response[:request].url
    key_url     = to_string(keys[:url]) |> ExVCR.Filter.filter_sensitive_data

    if stub_mode?(recorder_options) do
      if match = Regex.run(~r/~r\/(.+)\//, request_url) do
        pattern = Regex.compile!(Enum.at(match, 1))
        Regex.match?(pattern, key_url)
      else
        request_url == key_url
      end
    else
      request_url = parse_url(request_url, recorder_options)
      key_url     = parse_url(key_url, recorder_options)

      request_url == key_url
    end
  end

  defp match_by_headers(response, keys, options) do
    if has_match_requests_on(:headers, options) do
      response[:request].headers
      |> Enum.to_list
      |> Util.stringify_keys
      |> Keyword.equal?(keys[:headers])
    else
      true
    end
  end

  defp parse_url(url, options) do
    if has_match_requests_on(:query, options) do
      to_string(url)
    else
      to_string(url) |> ExVCR.Filter.strip_query_params
    end
  end

  defp match_by_method(head, params) do
    if params[:method] == nil || head[:request].method == nil do
      true
    else
      to_string(params[:method]) == head[:request].method
    end
  end

  defp match_by_request_body(response, keys, recorder_options) do
    if stub_with_non_empty_request_body?(recorder_options) || has_match_requests_on(:request_body, recorder_options) do
      request_body = response[:request].body || response[:request].request_body
      key_body     = keys[:request_body] |> to_string |> ExVCR.Filter.filter_sensitive_data

      if match = Regex.run(~r/~r\/(.+)\//, request_body) do
        pattern = Regex.compile!(Enum.at(match, 1))
        Regex.match?(pattern, key_body)
      else
        request_body == key_body
      end
    else
      true
    end
  end

  defp get_response_from_server(request, recorder, record?) do
    adapter = ExVCR.Recorder.options(recorder)[:adapter]
    response = :meck.passthrough(request)
               |> convert_body
               |> adapter.hook_response_from_server
    if record? do
      raise_error_if_cassette_already_exists(recorder, inspect(request))
      Recorder.append(recorder, adapter.convert_to_string(request, response))
      ExVCR.Checker.add_server_count(recorder)
    end
    response
  end

  defp convert_body(response) do
    {status, code, headers, body} = response
    {status, code, headers, IO.iodata_to_binary(body)}
  end

  defp ignore_request?(request, recorder) do
    ignore_localhost = ExVCR.Recorder.options(recorder)[:ignore_localhost] || ExVCR.Setting.get(:ignore_localhost)
    if ignore_localhost do
      Enum.any?(request, &(String.starts_with?("#{&1}", "http://localhost:")))
    else
      false
    end
  end

  defp raise_error_if_cassette_already_exists(recorder, request_description) do
    file_path = ExVCR.Recorder.get_file_path(recorder)
    if File.exists?(file_path) do
      message = """
      Request did not match with any one in the current cassette: #{file_path}.
      Delete the current cassette with [mix vcr.delete] and re-record.

      Request: #{request_description}
      """
      raise ExVCR.RequestNotMatchError, message: message
    end
  end
end
