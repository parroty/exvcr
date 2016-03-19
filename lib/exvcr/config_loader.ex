defmodule ExVCR.ConfigLoader do
  @moduledoc """
  Load configuration parameters from config.exs.
  """

  alias ExVCR.Config
  alias ExVCR.Setting

  @doc """
  Load default config values.
  """
  def load_defaults do
    env = Application.get_all_env(:exvcr)

    if env[:vcr_cassette_library_dir] != nil do
      Config.cassette_library_dir(
        env[:vcr_cassette_library_dir], env[:custom_cassette_library_dir])
    else
      Config.cassette_library_dir(
        Setting.get_default_vcr_path, Setting.get_default_custom_path)
    end

    Config.filter_sensitive_data(nil) # reset to empty list
    if env[:filter_sensitive_data] != nil do
      Enum.each(env[:filter_sensitive_data], fn(data) ->
        Config.filter_sensitive_data(data[:pattern], data[:placeholder])
      end)
    end

    if env[:filter_url_params] != nil do
      Config.filter_url_params(env[:filter_url_params])
    end

    if env[:response_headers_blacklist] != nil do
      Config.response_headers_blacklist(env[:response_headers_blacklist])
    else
      Config.response_headers_blacklist([])
    end

    if env[:match_requests_on] != nil do
      Config.match_requests_on(env[:match_requests_on])
    else
      Config.match_requests_on(Setting.get_default_match_requests_on)
    end
  end
end
