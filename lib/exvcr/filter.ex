defmodule ExVCR.Filter do
  @moduledoc """
  Provide filters for request/responses.
  """

  @doc """
  Filter out senstive data from the response.
  """
  def replace_sensitive_data(response) do
    replace_response(response, ExVCR.Setting.get(:filter_sensitive_data))
  end

  defp replace_response({:ok, status_code, headers, body}, filters) do
    {:ok, status_code, headers, body |> iolist_to_binary |> replace(filters)}
  end

  defp replace(body, []), do: body
  defp replace(body, [{pattern, placeholder}|tail]) do
    replace(String.replace(body, %r/#{pattern}/, placeholder), tail)
  end
end