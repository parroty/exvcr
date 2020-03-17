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

    Config.filter_request_options(nil) # reset to empty list
    if env[:filter_request_options] != nil do
      Enum.each(env[:filter_request_options], fn(option) ->
        Config.filter_request_options(option)
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

    if env[:ignore_localhost] != nil do
      Config.ignore_localhost(env[:ignore_localhost])
    end

    if env[:strict_mode] != nil do
      Config.strict_mode(env[:strict_mode])
    end
    
    config_json_toolkit = env[:json_toolkit] 
    
    if config_json_toolkit != nil && Code.ensure_loaded?(config_json_toolkit) do
      Config.json_toolkit(config_json_toolkit)
    else
      cond do
        Code.ensure_loaded?(JSX) -> Config.json_toolkit(ExVCR.JsonAdapter.JSXAdapter)
        Code.ensure_loaded?(Jason) -> Config.json_toolkit(ExVCR.JsonAdapter.JasonAdapter)
        true -> raise "no json toolkit"
      end
    end
  end
end
