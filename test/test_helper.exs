ExUnit.start
Application.ensure_all_started(:http_server)
Finch.start_link(name: ExVCRFinch)
