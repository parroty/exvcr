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
end