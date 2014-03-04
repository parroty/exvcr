defmodule ExVCR.Filter do
  @moduledoc """
  Provide filters for request/responses.
  """

  @doc """
  Filter out senstive data from the response.
  """
  def filter_sensitive_data(body) do
    replace(body, ExVCR.Setting.get(:filter_sensitive_data))
  end

  defp replace(body, []), do: body
  defp replace(body, [{pattern, placeholder}|tail]) do
    replace(String.replace(body, %r/#{pattern}/, placeholder), tail)
  end

  @doc """
  Filter out query params from the url.
  """
  def filter_url_params(url) do
    if ExVCR.Setting.get(:filter_url_params) do
      strip_query_params(url)
    else
      url
    end
  end

  @doc """
  Remove query params from the specified url.
  """
  def strip_query_params(url) do
    url |> String.replace(%r/\?.+$/, "")
  end
end