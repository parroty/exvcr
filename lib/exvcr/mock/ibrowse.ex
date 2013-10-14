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

  def string_to_request(string) do
    Enum.map(string, fn({x,y}) -> {binary_to_atom(x),y} end) |> ExVCR.Request.new
  end

  def string_to_response(string) do
    response = Enum.map(string, fn({x, y}) -> {binary_to_atom(x), y} end) |> ExVCR.Response.new
    response.update(status_code: integer_to_list(response.status_code))
  end

  def request_to_string([url, headers, method]), do: request_to_string([url, headers, method, [], []])
  def request_to_string([url, headers, method, body]), do: request_to_string([url, headers, method, body, []])
  def request_to_string([url, headers, method, body, options]), do: request_to_string([url, headers, method, body, options, 5000])
  def request_to_string([url, headers, method, body, options, _timeout]) do
    ExVCR.Request.new(
      url: iolist_to_binary(url),
      headers: parse_headers(headers),
      method: atom_to_binary(method),
      body: iolist_to_binary(body),
      options: options
    )
  end

  def response_to_string({:ok, status_code, headers, body}) do
    ExVCR.Response.new(
      status_code: list_to_integer(status_code),
      headers: parse_headers(headers),
      body: iolist_to_binary(body)
    )
  end

  def parse_headers(headers) do
    do_parse_headers(headers, [])
  end

  defp do_parse_headers([], acc), do: Enum.reverse(acc)
  defp do_parse_headers([{key,value}|tail], acc) do
    do_parse_headers(tail, [{iolist_to_binary(key), iolist_to_binary(value)}|acc])
  end
end