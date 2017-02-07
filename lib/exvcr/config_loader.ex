defmodule ExVCR.ConfigLoader do
  @moduledoc """
  Load configuration parameters from config.exs.
  """

  @default_vcr_path    "fixture/vcr_cassettes"
  @default_custom_path "fixture/custom_cassettes"

  alias ExVCR.Config

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
        @default_vcr_path, @default_custom_path)
    end

    Config.filter_sensitive_data(nil) # reset to empty list
    if env[:filter_sensitive_data] != nil do
      Enum.each(env[:filter_sensitive_data], fn(data) ->
        Config.filter_sensitive_data(data[:pattern], data[:placeholder])
      end)
    end

    Config.filter_request_headers(nil) # reset to empty list
    if env[:filter_request_headers] != nil do
      Enum.each(env[:filter_request_headers], fn(header) ->
        Config.filter_request_headers(header)
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
  end
end
