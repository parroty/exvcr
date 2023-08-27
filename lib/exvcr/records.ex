defmodule ExVCR.Record do
  defstruct options: nil, responses: nil
end

defmodule ExVCR.Request do
  defstruct url: nil, headers: [], method: nil, body: nil, options: [], request_body: ""

  defimpl Jason.Encoder do
    def encode(request, opts) do
      request
      |> Map.update!(:headers, &Map.new/1)
      |> Map.update!(:options, fn options -> options |> clean_invalid() |> Map.new() end)
      |> Map.take([:url, :headers, :method, :body, :options, :request_body])
      |> Jason.Encode.map(opts)
    end

    defp clean_invalid([{_, _} | _] = kw) do
      kw |> Enum.map(fn {k, v} -> {k, clean_invalid(v)} end) |> Map.new()
    end

    defp clean_invalid([value | rest]) do
      [clean_invalid(value) | clean_invalid(rest)]
    end

    defp clean_invalid([] = empty), do: empty

    defp clean_invalid(map) when is_map(map) do
      map |> Map.to_list() |> clean_invalid() |> Map.new()
    end

    defp clean_invalid(tuple) when is_tuple(tuple) do
      tuple |> Tuple.to_list() |> clean_invalid() |> List.to_tuple()
    end

    defp clean_invalid(bin) when is_binary(bin) do
      clean_bin(bin)
    end

    defp clean_invalid(other), do: other

    defp clean_bin(<<b::utf8, rest::bytes>>), do: <<b::utf8>> <> clean_bin(rest)
    defp clean_bin(<<_invalid, rest::bytes>>), do: "�" <> clean_bin(rest)
    defp clean_bin(<<>> = empty), do: empty
  end
end

defmodule ExVCR.Response do
  defstruct type: "ok", status_code: nil, headers: [], body: nil, binary: false

  defimpl Jason.Encoder do
    def encode(response, opts) do
      response
      |> Map.update!(:headers, &Map.new/1)
      |> Map.take([:type, :status_code, :headers, :body, :binary])
      |> Jason.Encode.map(opts)
    end
  end
end

defmodule ExVCR.Checker.Results do
  defstruct dirs: nil, files: []
end
defmodule ExVCR.Checker.Counts do
  defstruct server: 0, cache: 0
end
