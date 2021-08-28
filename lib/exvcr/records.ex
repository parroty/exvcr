defmodule ExVCR.Record do
  defstruct options: nil, responses: nil
end

defmodule ExVCR.Utils do
  @moduledoc false

  def keyword_to_map(kw) do
    kw
    |> Enum.sort(fn {k1, _}, {k2, _} -> k1 <= k2 end)
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end
end

defmodule ExVCR.Request do
  defstruct url: nil, headers: [], method: nil, body: nil, options: [], request_body: ""

  defimpl Jason.Encoder, for: ExVCR.Request do
    def encode(value, opts) do
      %{headers: headers, options: options} = Map.take(value, [:headers, :options])

      map = value
            |> Map.take([:url, :method, :body, :request_body])
            |> Map.put(:headers, ExVCR.Utils.keyword_to_map(headers))
            |> Map.put(:options, ExVCR.Utils.keyword_to_map(options))

      Jason.Encode.map(map, opts)
    end
  end
end

defmodule ExVCR.Response do
  defstruct type: "ok", status_code: nil, headers: [], body: nil, binary: false

  defimpl Jason.Encoder, for: ExVCR.Response do
    def encode(value, opts) do
      headers = Map.get(value, :headers)

      map = value
            |> Map.take([:type, :status_code, :body, :binary])
            |> Map.put(:headers, ExVCR.Utils.keyword_to_map(headers))

      Jason.Encode.map(map, opts)
    end
  end
end

defmodule ExVCR.Checker.Results do
  defstruct dirs: nil, files: []
end

defmodule ExVCR.Checker.Counts do
  defstruct server: 0, cache: 0
end
