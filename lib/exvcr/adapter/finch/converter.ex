defmodule ExVCR.Adapter.Finch.Converter do
  @moduledoc """
  Provides helpers to mock Finch methods.
  """

  use ExVCR.Converter

  alias ExVCR.Util

  defp string_to_response(string) do
    response = Enum.map(string, fn({x, y}) -> {String.to_atom(x), y} end)
    response = struct(ExVCR.Response, response)

    response =
      if response.type == "error" do
        body = string_to_error_reason(response.body)
        %{response | body: body}
      else
        response
      end

    response =
      if is_map(response.headers) do
        headers = response.headers
                  |> Map.to_list
                  |> Enum.map(fn({k,v}) -> {k, v} end)
        %{response | headers: headers}
      else
        response
      end

    response
  end

  defp string_to_error_reason(reason) do
    {reason_struct, _} = Code.eval_string(reason)
    reason_struct
  end

  defp request_to_string([request, finch_module]) do
    request_to_string([request, finch_module, []])
  end

  defp request_to_string([request, _finch_module, opts]) do
    url = Util.build_url(request.scheme, request.host, request.path, request.port, request.query)

    %ExVCR.Request{
      url: parse_url(url),
      headers: parse_headers(request.headers),
      method: String.downcase(request.method),
      body: parse_request_body(request.body),
      options: parse_options(sanitize_options(opts))
    }
  end

  # If option value is tuple, make it as list, for encoding as json.
  defp sanitize_options(options) do
    Enum.map(options, fn({key, value}) ->
      if is_tuple(value) do
        {key, Tuple.to_list(value)}
      else
        {key, value}
      end
    end)
  end

  defp response_to_string({:ok, %Finch.Response{} = response}), do: response_to_string(response)

  defp response_to_string(%Finch.Response{} = response) do
    %ExVCR.Response{
      type: "ok",
      status_code: response.status,
      headers: parse_headers(response.headers),
      body: to_string(response.body)
    }
  end

  defp response_to_string({:error, reason}) do
    %ExVCR.Response{
      type: "error",
      body: error_reason_to_string(reason)
    }
  end

  defp error_reason_to_string(reason), do: Macro.to_string(reason)
end
