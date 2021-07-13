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
    error = JSX.decode!(reason)
    struct_name = error["__original_struct__"]

    if struct_name do
      # convert back into the original struct
      module = String.to_existing_atom(struct_name)
      Enum.map(error, fn {k, v} ->
        if is_binary(k), do: {String.to_atom(k), v}, else: {k, v}
      end)
      |> Enum.into(%{})
      |> normalize_reason(module)
      |> Map.put(:__struct__, module)
      |> Map.delete(:__original_struct__)
    else
      normalize_reason(error)
    end
  end

  defp normalize_reason(%{} = reason, module) when module in [Finch.Error, Mint.TransportError, Mint.HTTPError] do
    Enum.map(reason, fn {k, v} ->
      val = cond do
        is_atom(v) -> v
        module == Mint.HTTPError && k == :module ->
          if is_binary(v), do: String.to_existing_atom(v), else: v
        is_binary(v) -> String.to_atom(v)
        is_tuple(v) ->
          first_elem = elem(v, 0)
          first_elem = if is_binary(first_elem), do: String.to_atom(first_elem), else: first_elem
          Tuple.delete_at(v, 0) |> Tuple.insert_at(0, first_elem)
        true -> v
      end

      {k, val}
    end) |> Enum.into(%{})
  end

  defp normalize_reason(%{} = reason) do
    Enum.map(reason, fn {k, v} ->
      # special case according to Finch tests, might not cover all cases properly
      case {k, v} do
        {"reason", "timeout"} -> {:reason, :timeout}
        {"reason", some} -> {:reason, some}
        other -> other
      end
    end) |> Enum.into(%{})
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

  defp response_to_string({:ok, response}) do
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

  defp error_reason_to_string(reason) when is_struct(reason) do
    # JSX strips the __struct__ field so we add our own field
    # to be able to decode back into the same struct
    Map.put(reason, :__original_struct__, reason.__struct__) |> JSX.encode!()
  end

  defp error_reason_to_string(reason), do: JSX.encode!(reason)
end
