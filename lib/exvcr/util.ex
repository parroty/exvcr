defmodule ExVCR.Util do
  @moduledoc """
  Provides utility functions.
  """

  @doc """
  Returns uniq_id string based on current timestamp (ex. 1407237617115869)
  """
  def uniq_id do
    :os.timestamp() |> Tuple.to_list() |> Enum.join("")
  end

  @doc """
  Takes a keyword lists and returns them as strings.
  """

  def stringify_keys(list) do
    list |> Enum.map(fn {key, value} -> {to_string(key), to_string(value)} end)
  end

  def build_url(scheme, host, path, port \\ nil, query \\ nil) do
    scheme =
      case scheme do
        s when s in [:http, "http", "HTTP"] -> "http://"
        s when s in [:https, "https", "HTTPS"] -> "https://"
        _ -> scheme
      end

    port =
      cond do
        scheme == "http://" && port == 80 -> nil
        scheme == "https://" && port == 443 -> nil
        true -> port
      end

    url =
      if port do
        "#{scheme}#{host}:#{port}#{path}"
      else
        "#{scheme}#{host}#{path}"
      end

    url =
      if query != nil && query != "" do
        "#{url}?#{query}"
      else
        url
      end

    url
  end
end
