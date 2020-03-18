defmodule ExVCR.JsonAdapter do
  def encode!(input), do: ExVCR.Setting.get(:json_toolkit).encode!(input)
  def decode!(input), do: ExVCR.Setting.get(:json_toolkit).decode!(input)

  def prettify(input), do: ExVCR.Setting.get(:json_toolkit).prettify(input)

  def prettify!(input), do: ExVCR.Setting.get(:json_toolkit).prettify!(input)

  if Code.ensure_loaded?(Jason) do
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
        Jason.encode!(input)
      end

      def prettify!(input) do
        Jason.Formatter.pretty_print(input)
      end

      def prettify(input) do
        Jason.Formatter.pretty_print(input)
      end
    end
  end

  if Code.ensure_loaded?(JSX) do
    defmodule JSXAdapter do
      def decode!(input), do: JSX.decode!(input)
      def encode!(input), do: JSX.encode!(input)

      def prettify(input), do: JSX.prettify(input)

      def prettify!(input), do: JSX.prettify!(input)
    end
  end
end
