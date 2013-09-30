defmodule ExVCR.Config do
  alias ExVCR.Setting

  def cassette_library_dir(vcr_dir, custom_dir // nil) do
    Setting.set(:cassette_library_dir, vcr_dir)
    Setting.set(:custom_library_dir, custom_dir)
  end
end