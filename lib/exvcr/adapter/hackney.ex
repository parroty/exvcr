defmodule ExVCR.Adapter.Hackney do
  @moduledoc """
  Provides adapter methods to mock :hackney methods.
  """

  use ExVCR.Adapter
  alias ExVCR.Adapter.Hackney.Store

  defmacro __using__(_opts) do
    quote do
      Store.start
    end
  end

  defdelegate convert_from_string(string), to: ExVCR.Adapter.Hackney.Converter
  defdelegate convert_to_string(request, response), to: ExVCR.Adapter.Hackney.Converter

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    :hackney
  end

  @doc """
  Returns list of the mock target methods with function name and callback.
  """
  def target_methods(recorder) do
    [ {:request, &ExVCR.Recorder.request(recorder, [&1,&2,&3,&4,&5])},
      {:body,    &handle_body_request(recorder, [&1])} ]
  end

  @doc """
  Generate key for searching response.
  """
  def generate_keys_for_request(request) do
    url    = Enum.fetch!(request, 1)
    method = Enum.fetch!(request, 0)
    [url: url, method: method]
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the json file cache.
  """
  def hook_response_from_cache(nil), do: nil
  def hook_response_from_cache(%ExVCR.Response{type: "error"} = response), do: response
  def hook_response_from_cache(%ExVCR.Response{body: body} = response) do
    client          = make_ref
    client_key_atom = client |> inspect |> binary_to_atom
    Store.set(client_key_atom, body)
    %{response | body: client}
  end

  defp handle_body_request(recorder, [client]) do
    client_key_atom = client |> inspect |> binary_to_atom
    if body = Store.get(client_key_atom) do
      Store.delete(client_key_atom)
      {:ok, body}
    else
      {ret, body} = :meck.passthrough([client])
      if ret == :ok do
        body = ExVCR.Filter.filter_sensitive_data(body)

        client_key_string = inspect(client)
        ExVCR.Recorder.update(recorder,
          fn(%{request: _request, response: response}) ->
            response.body == client_key_string
          end,
          fn(%{request: request, response: response}) ->
            %{request: request, response: %{response | body: body}}
          end
        )
      end

      {ret, body}
    end
  end
end
