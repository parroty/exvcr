defmodule ExVCR.Mock.IBrowse do
  alias ExVCR.Recorder

  def mock_methods(recorder) do
    do_mock_methods(&Recorder.respond(recorder, [&1,&2,&3]))
    do_mock_methods(&Recorder.respond(recorder, [&1,&2,&3,&4]))
    do_mock_methods(&Recorder.respond(recorder, [&1,&2,&3,&4,&5]))
    do_mock_methods(&Recorder.respond(recorder, [&1,&2,&3,&4,&5,&6]))
  end

  def do_mock_methods(callback) do
    :meck.expect(:ibrowse, :send_req, callback)
  end

  def parse_request([url, headers, method]), do: parse_request([url, headers, method, [], []])
  def parse_request([url, headers, method, body]), do: parse_request([url, headers, method, body, []])
  def parse_request([url, headers, method, body, options]), do: parse_request([url, headers, method, body, options, 0])
  def parse_request([url, headers, method, body, options, _timeout]) do
    [
      url: iolist_to_binary(url),
      headers: parse_headers(headers),
      method: atom_to_binary(method),
      body: iolist_to_binary(body),
      options: options
    ]
  end

  def parse_response({:ok, status_code, headers, body}) do
    [
      status_code: list_to_integer(status_code),
      headers: parse_headers(headers),
      body: iolist_to_binary(body)
    ]
  end

  def parse_headers(headers) do
    do_parse_headers(headers, [])
  end

  defp do_parse_headers([], acc), do: Enum.reverse(acc)
  defp do_parse_headers([{key,value}|tail], acc) do
    do_parse_headers(tail, [{iolist_to_binary(key), iolist_to_binary(value)}|acc])
  end
end