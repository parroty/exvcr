if Code.ensure_loaded?(Req) do
  defmodule ExVCR.Adapter.Req.Converter do
    @moduledoc """
    Provides helpers to mock Req methods.
    """

    use ExVCR.Converter

    defp string_to_response(string) do
      response = Enum.map(string, fn {x, y} -> {String.to_atom(x), y} end)
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
          headers = normalize_headers(response.headers)
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

    defp request_to_string([request]) do
      %ExVCR.Request{
        url: parse_url(request.url),
        headers: parse_headers(request.headers),
        method: String.downcase("#{request.method}"),
        body: parse_request_body(request.body),
        options: parse_options([])
      }
    end

    defp response_to_string({:ok, %Req.Response{} = response}), do: response_to_string(response)

    defp response_to_string(%Req.Response{} = response) do
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

    defp parse_headers(headers) when is_list(headers) do
      Enum.map(headers, fn
        {k, v} -> {String.downcase(to_string(k)), to_string(v)}
        [k, v] -> {String.downcase(to_string(k)), to_string(v)}
        header when is_tuple(header) ->
          {k, v} = header
          {String.downcase(to_string(k)), to_string(v)}
      end)
    end

    defp parse_headers(headers) when is_map(headers) do
      headers
      |> Map.to_list()
      |> parse_headers()
    end

    defp normalize_headers(headers) when is_map(headers) do
      headers
      |> Map.to_list()
      |> Enum.map(fn {k, v} -> {String.downcase(to_string(k)), to_string(v)} end)
    end
  end
end
