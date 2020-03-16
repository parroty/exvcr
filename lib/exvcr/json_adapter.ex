defmodule ExVCR.JsonAdapter do
  @json_toolkit (fn ->
                   configured_toolkit = Application.get_env(:exvcr, :json_toolkit)

                   if configured_toolkit do
                     unless Code.ensure_loaded?(configured_toolkit) do
                       raise "no json toolkit"
                     else
                       configured_toolkit
                     end
                   else
                     cond do
                       Code.ensure_loaded?(Jason) -> __MODULE__.JasonAdapter
                       Code.ensure_loaded(ExJSX) -> __MODULE__.ExJSXAdapter
                     end
                   end
                 end).()

  def encode!(input), do: @json_toolkit.encode!(input)
  def decode!(input), do: @json_toolkit.decode!(input)

  defmodule JasonAdapter do
    require Protocol

    defimpl Jason.Encoder, for: ExVCR.Request do
      def encode(value, opts) do
        value
        |> Map.update(:headers, %{}, fn headers -> Enum.into(headers, %{}) end)
        |> Map.update(:options, %{}, fn headers -> Enum.into(headers, %{}) end)
        |> Map.from_struct()
        |> Jason.Encode.map(opts)
      end
    end

    defimpl Jason.Encoder, for: ExVCR.Response do
      def encode(value, opts) do
        value
        |> Map.update(:headers, %{}, fn headers -> Enum.into(headers, %{}) end)
        |> Map.from_struct()
        |> Jason.Encode.map(opts)
      end
    end

    def decode!(input) do
      Jason.decode!(input)
    end

    def encode!(input) do
      Jason.encode!(input, pretty: true)
    end
  end

  defmodule ExJSXAdapter do
    def decode!(input), do: JSX.decode!(input)
    def encode!(input), do: JSX.encode!(input)
  end
end
