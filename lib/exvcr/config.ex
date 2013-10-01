defmodule ExVCR.Config do
  @moduledoc """
  Store configurations for libraries
  """
  alias ExVCR.Setting

  @doc """
  Initializes library dir
  - vcr_dir: directory for storing recorded json file.
  - custom dir: directory for placing custom json file.
  """
  def cassette_library_dir(vcr_dir, custom_dir // nil) do
    Setting.set(:cassette_library_dir, vcr_dir)
    File.mkdir_p!(vcr_dir)

    Setting.set(:custom_library_dir, custom_dir)
  end
end