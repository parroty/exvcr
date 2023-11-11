ExUnit.start()
Application.ensure_all_started(:http_server)
Application.ensure_all_started(:telemetry)
Finch.start_link(name: ExVCRFinch)
