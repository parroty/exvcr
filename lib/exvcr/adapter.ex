defmodule ExVCR.Adapter do
  @moduledoc """
  Provides helpers for adapters.
  """

  defmacro __using__(_) do
    quote do
      @doc """
      Returns the name of the mock target module.
      """
      def module_name, do: raise ExVCR.ImplementationMissingError
      defoverridable [module_name: 0]

      @doc """
      Returns list of the mock target methods with function name and callback.
      """
      def target_methods(recorder), do: raise ExVCR.ImplementationMissingError
      defoverridable [target_methods: 1]

      @doc """
      Generate key for searching response.
      [url: url, method: method] needs to be returned.
      """
      def generate_keys_for_request(request), do: raise ExVCR.ImplementationMissingError
      defoverridable [generate_keys_for_request: 1]

      @doc """
      Callback from ExVCR.Handler when response is retrieved from the HTTP server.
      """
      def hook_response_from_server(response), do: response
      defoverridable [hook_response_from_server: 1]

      @doc """
      Callback from ExVCR.Handler when response is retrieved from the json file cache.
      """
      def hook_response_from_cache(response), do: response
      defoverridable [hook_response_from_cache: 1]

      @doc """
      Returns the response from the ExVCR.Reponse record.
      """
      def get_response_value_from_cache(response) do
        if response.type == "error" do
          {:error, response.body}
        else
          {:ok, response.status_code, response.headers, response.body}
        end
      end
      defoverridable [get_response_value_from_cache: 1]
    end
  end
end
