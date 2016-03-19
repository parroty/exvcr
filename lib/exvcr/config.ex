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
    File.mkdir_p!(vcr_dir)

    Setting.set(:custom_library_dir, custom_dir)
    :ok
  end

  @doc """
  Replace the specified pattern with placeholder.
  It can be used to remove sensitive data from the casette file.
  """
  def filter_sensitive_data(pattern, placeholder) do
    Setting.append(:filter_sensitive_data, {pattern, placeholder})
  end

  @doc """
  Clear the previously specified filter_sensitive_data lists.
  """
  def filter_sensitive_data(nil) do
    Setting.set(:filter_sensitive_data, [])
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
    blacklist = Enum.map(headers_blacklist, fn(x) -> String.downcase(x) end)
    Setting.set(:response_headers_blacklist, blacklist)
  end

  @doc """
  Sets default match_requests_on option
  """
  def match_requests_on(match_requests_on) do
    Setting.set(:match_requests_on, match_requests_on)
  end
end
