defmodule ExVCR.TaskUtil do
  def parse_basic_options(options) do
    [ options[:dir] || ExVCR.Setting.get_default_vcr_path,
      options[:custom] || ExVCR.Setting.get_default_custom_path ]
  end

  def base_aliases do
    [d: :dir, c: :custom]
  end
end
