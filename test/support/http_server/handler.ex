defmodule HttpServer.Handler do
  @moduledoc """
  Provides HTTP request handling using Plug
  """

  use Plug.Builder

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    pass: ["*/*"]
  )

  @ets_table :httpserver_handler
  @ets_key :response
  @default_response "Hello World"

  def define_response(response, wait_time) do
    response = response || @default_response
    wait_time = wait_time || 0

    if :ets.info(@ets_table) == :undefined do
      :ets.new(@ets_table, [:set, :public, :named_table])
    end

    :ets.insert(@ets_table, {@ets_key, {response, wait_time}})
  end

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    conn = super(conn, opts)
    {response, wait_time} = :ets.lookup(@ets_table, @ets_key)[@ets_key]
    wait_for(wait_time)

    case response do
      {status, headers, body} ->
        conn
        |> put_resp_headers(headers)
        |> send_resp(status, body)

      response when is_function(response) ->
        conn_values = %{
          path: conn.request_path,
          method: conn.method,
          headers: conn.req_headers,
          qs: conn.query_string,
          body: conn.body_params,
          peer: conn.remote_ip
        }

        case response.(conn_values) do
          {status, headers, body} ->
            conn
            |> put_resp_headers(headers)
            |> send_resp(status, body)

          {:error, reason} ->
            # For error responses like timeouts
            Process.sleep(wait_time)
            {:error, reason}
        end

      {:error, reason} ->
        # For direct error responses
        Process.sleep(wait_time)
        {:error, reason}

      response when is_binary(response) ->
        conn
        |> put_resp_header("content-type", "text/plain")
        |> send_resp(200, response)

      response ->
        conn
        |> put_resp_header("content-type", "text/plain")
        |> send_resp(200, inspect(response))
    end
  end

  defp put_resp_headers(conn, headers) do
    Enum.reduce(headers, conn, fn {header, value}, conn ->
      put_resp_header(conn, to_string(header), to_string(value))
    end)
  end

  defp wait_for(wait_time) when is_integer(wait_time) and wait_time > 0 do
    Process.sleep(wait_time)
  end

  defp wait_for(_), do: :ok
end
