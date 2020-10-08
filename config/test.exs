use Mix.Config

config :exvcr, [
  global_mock: System.get_env("GLOBAL_MOCK") == "true"
]
