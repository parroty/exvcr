import Config

config :exvcr,
  global_mock: false,
  vcr_cassette_library_dir: "fixture/vcr_cassettes",
  custom_cassette_library_dir: "fixture/custom_cassettes",
  filter_sensitive_data: [
    [pattern: "<PASSWORD>.+</PASSWORD>", placeholder: "PASSWORD_PLACEHOLDER"]
  ],
  filter_url_params: false,
  filter_request_headers: [],
  response_headers_blacklist: [],
  ignore_localhost: false,
  enable_global_settings: false,
  strict_mode: false

if Mix.env() == :test, do: import_config("test.exs")
