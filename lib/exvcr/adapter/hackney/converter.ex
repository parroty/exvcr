defmodule ExVCR.Adapter.Hackney.Converter do
  @moduledoc """
  Provides helpers to mock :hackney methods.
  """

  use ExVCR.Converter

  defp string_to_response(string) do
    response = Enum.map(string, fn({x, y}) -> {String.to_atom(x), y} end)
    response = struct(ExVCR.Response, response)

    response =
      if is_map(response.headers) do
        headers = response.headers |> Map.to_list
        %{response | headers: headers}
      else
        response
      end

    response
  end

  defp request_to_string(request) do
    method  = Enum.fetch!(request, 0) |> to_string()
    url     = Enum.fetch!(request, 1) |> parse_url()
    headers = Enum.at(request, 2, []) |> parse_headers()
    body    = Enum.at(request, 3, "") |> parse_request_body()
    options = Enum.at(request, 4, []) |> sanitize_options() |> parse_options()

    %ExVCR.Request{
      url: url,
      headers: headers,
      method: method,
      body: body,
      options: options
    }
  end

  # If option value is tuple, make it as list, for encoding as json.
  defp sanitize_options(options) do
    Enum.map(options, fn
      {key, value} ->
        if is_tuple(value) do
          {key, Tuple.to_list(value)}
        else
          {key, value}
        end
      key when is_atom(key) ->
        {key, true}
    end)
  end

  defp response_to_string({:ok, status_code, headers, body_or_client}) do
    body = case body_or_client do
      string when is_binary(string) -> string
      # Client is already replaced by body through ExVCR.Adapter.Hackney adapter.
      ref when is_reference(ref) -> inspect(ref)
    end

    %ExVCR.Response{
      type: "ok",
      status_code: status_code,
      headers: parse_headers(headers),
      body: body
    }
  end

  defp response_to_string({:ok, status_code, headers}) do
    %ExVCR.Response{
      type: "ok",
      status_code: status_code,
      headers: parse_headers(headers)
    }
  end

  defp response_to_string({:error, reason}) do
    %ExVCR.Response{
      type: "error",
      body: Atom.to_string(reason)
    }
  end

  def parse_request_body({:form, body}) do
    :hackney_request.encode_form(body)
    |> elem(2)
    |> to_string
    |> ExVCR.Filter.filter_sensitive_data
  end

  def parse_request_body(body), do: super(body)
end
