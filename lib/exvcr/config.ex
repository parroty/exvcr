defmodule ExVCR.Config do
  @moduledoc """
  Assign configuration parameters.
  """

  alias ExVCR.Setting

  @doc """
  Initializes library dir to store cassette json files.
    - vcr_dir: directory for storing recorded json file.
    - custom_dir: directory for placing custom json file.
  """
  def cassette_library_dir(vcr_dir, custom_dir \\ nil) do
    Setting.set(:cassette_library_dir, vcr_dir)
    Setting.set(:custom_library_dir, custom_dir)
    :ok
  end

  @doc """
  Replace the specified pattern with placeholder.
  It can be used to remove sensitive data from the cassette file.

  ## Examples

      test "replace sensitive data" do
        ExVCR.Config.filter_sensitive_data("<PASSWORD>.+</PASSWORD>", "PLACEHOLDER")

        use_cassette "sensitive_data" do
          assert HTTPoison.get!("http://something.example.com", []).body =~ ~r/PLACEHOLDER/
        end

        # Now clear the previous filter
        ExVCR.Config.filter_sensitive_data(nil)
      end
  """
  def filter_sensitive_data(pattern, placeholder) do
    Setting.append(:filter_sensitive_data, {pattern, placeholder})
  end

  def filter_sensitive_data(nil) do
    Setting.set(:filter_sensitive_data, [])
  end

  @doc """
  This function can be used to filter headers from saved requests.

  ## Examples

      test "replace sensitive data in request header" do
        ExVCR.Config.filter_request_headers("X-My-Secret-Token")

        use_cassette "sensitive_data_in_request_header" do
          body = HTTPoison.get!("http://localhost:34000/server?", ["X-My-Secret-Token": "my-secret-token"]).body
          assert body == "test_response"
        end

        # The recorded cassette should contain replaced data.
        cassette = File.read!("sensitive_data_in_request_header.json")
        assert cassette =~ "\"X-My-Secret-Token\": \"***\""
        refute cassette =~  "\"X-My-Secret-Token\": \"my-secret-token\""

        # Now reset the filter
        ExVCR.Config.filter_request_headers(nil)
      end
  """
  def filter_request_headers(nil) do
    Setting.set(:filter_request_headers, [])
  end

  def filter_request_headers(header) do
    Setting.append(:filter_request_headers, header)
  end

  @doc """
  This function can be used to filter options.

  ## Examples

      test "replace sensitive data in request options" do
        ExVCR.Config.filter_request_options("basic_auth")
        use_cassette "sensitive_data_in_request_options" do
          body = HTTPoison.get!(@url, [], [hackney: [basic_auth: {"username", "password"}]]).body
          assert body == "test_response"
        end

        # The recorded cassette should contain replaced data.
        cassette = File.read!("sensitive_data_in_request_options.json")
        assert cassette =~ "\"basic_auth\": \"***\""
        refute cassette =~  "\"basic_auth\": {\"username\", \"password\"}"

        # Now reset the filter
        ExVCR.Config.filter_request_options(nil)
      end
  """
  def filter_request_options(nil) do
    Setting.set(:filter_request_options, [])
  end

  def filter_request_options(header) do
    Setting.append(:filter_request_options, header)
  end

  @doc """
  Set the flag whether to filter-out url params when recording to cassettes.
  (ex. if flag is true, "param=val" is removed from "http://example.com?param=val").
  """
  def filter_url_params(flag) do
    Setting.set(:filter_url_params, flag)
  end

  @doc """
  Sets a list of headers to remove from the response
  """
  def response_headers_blacklist(headers_blacklist) do
    blacklist = Enum.map(headers_blacklist, fn x -> String.downcase(x) end)
    Setting.set(:response_headers_blacklist, blacklist)
  end

  @doc """
  Skip recording cassettes for localhost requests when set
  """
  def ignore_localhost(value) do
    Setting.set(:ignore_localhost, value)
  end

  @doc """
  Skip recording cassettes for urls requests when set
  """
  def ignore_urls(value) do
    Setting.set(:ignore_urls, value)
  end

  @doc """
  Throw error if there is no matching cassette for an HTTP request
  """
  def strict_mode(value) do
    Setting.set(:strict_mode, value)
  end
end
