defmodule HttpServer do
  @moduledoc false
  use Application

  @default_port 8080
  @registry HttpServer.Registry

  # usage:
  # HttpServer.start(path: "/server", port: @port, response: "test_response_before")
  # HttpServer.stop(@port)

  def start, do: start([], [])
  def start(args), do: start([], args)

  def start(_type, args) do
    path = args[:path] || "/"
    port = args[:port] || @default_port

    # First ensure any existing server on this port is stopped
    ensure_stopped(port)

    HttpServer.Handler.define_response(args[:response], args[:wait_time])

    # Start the registry if it doesn't exist
    ensure_registry()

    # Start the server
    {:ok, pid} =
      Bandit.start_link(
        plug: HttpServer.Handler,
        port: port
      )

    # Register the server
    {:ok, _} = Registry.register(@registry, port, pid)

    {:ok, pid}
  end

  def stop, do: stop(@default_port)

  def stop(port) do
    ensure_stopped(port)
  end

  defp ensure_registry do
    case Registry.start_link(keys: :unique, name: @registry) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
    end
  end

  defp ensure_stopped(port) do
    with {:ok, entries} <- safe_registry_lookup(port),
         [{owner_pid, server_pid}] <- entries do
      # Try graceful shutdown first
      safe_stop_server(server_pid)
      safe_unregister(port)
    end

    cleanup_port(port)
    :ok
  end

  defp safe_registry_lookup(port) do
    {:ok, Registry.lookup(@registry, port)}
  rescue
    _ -> {:ok, []}
  end

  defp safe_stop_server(pid) when is_pid(pid) do
    if Process.alive?(pid) do
      try do
        GenServer.stop(pid, :normal, 1000)
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end
  end

  defp safe_stop_server(_), do: :ok

  defp safe_unregister(port) do
    Registry.unregister(@registry, port)
  rescue
    _ -> :ok
  end

  defp cleanup_port(port) do
    case :gen_tcp.listen(port, []) do
      {:ok, socket} ->
        :gen_tcp.close(socket)

      {:error, :eaddrinuse} ->
        # Just wait a brief moment for the port to be released
        Process.sleep(100)
        :ok
    end
  end
end
