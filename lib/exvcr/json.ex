defmodule ExVCR.JSON do
  @moduledoc """
  Provides a feature to store/load cassettes in json format.
  """

  @doc """
  Save responses into the json file.
  """
  def save(file_name, responses) do
    json = responses |> Enum.reverse |> JSEX.encode!
    unless File.exists?(path = Path.dirname(file_name)), do: File.mkdir_p(path)
    File.write!(file_name, JSEX.prettify!(json))
  end

  @doc """
  Loads the JSON files based on the fixture name and options.
  For options, this method just refers to the :custom attribute is set or not.
  """
  def load(file_name, custom_mode, adapter) do
    case { File.exists?(file_name), custom_mode } do
      { true, _ } -> read_json_file(file_name) |> Enum.map(&adapter.convert_from_string/1)
      { false, true } -> raise ExVCR.FileNotFoundError.new(message: "cassette file \"#{file_name}\" not found")
      { false, _ } -> []
    end
  end

  @doc """
  Reads and parse the json file located at the specified file_name.
  """
  def read_json_file(file_name) do
    File.read!(file_name) |> JSEX.decode!
  end
end
