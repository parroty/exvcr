defmodule ExVCR.Filter do
  @moduledoc """
  Provide filters for request/responses.
  """

  @doc """
  Filter out sensitive data from the response.
  """
  def filter_sensitive_data(body) when is_binary(body) do
    if String.valid?(body) do
      replace(body, ExVCR.Setting.get(:filter_sensitive_data))
    else
      body
    end
  end

  def filter_sensitive_data(body), do: body

  @doc """
  Filter out sensitive data from the request header.
  """
  def filter_request_header(header, value) do
    if Enum.member?(ExVCR.Setting.get(:filter_request_headers), header), do: "***", else: value
  end

  @doc """
  Filter out sensitive data from the request options.
  """
  def filter_request_option(option, value) do
    if Enum.member?(ExVCR.Setting.get(:filter_request_options), option), do: "***", else: value
  end

  defp replace(body, []), do: body

  defp replace(body, [{pattern, placeholder} | tail]) do
    replace(String.replace(body, ~r/#{pattern}/, placeholder), tail)
  end

  @doc """
  Filter out query params from the url.
  """
  def filter_url_params(url) do
    if_result =
      if ExVCR.Setting.get(:filter_url_params) do
        strip_query_params(url)
      else
        url
      end

    filter_sensitive_data(if_result)
  end

  @doc """
  Remove query params from the specified url.
  """
  def strip_query_params(url) do
    String.replace(url, ~r/\?.+$/, "")
  end

  @doc """
  Removes the headers listed in the response headers blacklist
  from the headers
  """
  def remove_blacklisted_headers([]), do: []

  def remove_blacklisted_headers(headers) do
    Enum.filter(headers, fn {key, _value} ->
      is_header_allowed?(key)
    end)
  end

  defp is_header_allowed?(header_name) do
    Enum.find(ExVCR.Setting.get(:response_headers_blacklist), fn x ->
      String.downcase(to_string(header_name)) == x
    end) == nil
  end
end
