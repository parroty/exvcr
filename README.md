# ExVCR

[![Build Status](https://github.com/parroty/exvcr/workflows/tests/badge.svg)](https://github.com/parroty/exvcr/actions)
[![Coverage Status](https://img.shields.io/coveralls/github/parroty/exvcr)](https://coveralls.io/r/parroty/exvcr?branch=master)
[![hex.pm version](https://img.shields.io/hexpm/v/exvcr.svg)](https://hex.pm/packages/exvcr)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/exvcr.svg)](https://hex.pm/packages/exvcr)
[![License](https://img.shields.io/hexpm/l/exvcr.svg)](http://opensource.org/licenses/MIT)

Record and replay HTTP interactions library for Elixir.  It's inspired by
[Ruby's VCR](https://github.com/vcr/vcr), and trying to provide similar
functionalities.

### Basics

The following HTTP libraries can be applied.

  - [ibrowse](https://github.com/cmullaparthi/ibrowse){:target="_blank" rel="noopener"}-based libraries.
    - [HTTPotion](https://github.com/myfreeweb/httpotion){:target="_blank" rel="noopener"}
  - [hackney](https://github.com/benoitc/hackney){:target="_blank" rel="noopener"}-based libraries.
    - [HTTPoison](https://github.com/edgurgel/httpoison){:target="_blank" rel="noopener"}
    - support is very limited, and tested only with sync request of HTTPoison yet.
  - [httpc](http://erlang.org/doc/man/httpc.html){:target="_blank" rel="noopener"}-based libraries.
    - [erlang-oauth](https://github.com/tim/erlang-oauth/){:target="_blank" rel="noopener"}
    - [tirexs](https://github.com/Zatvobor/tirexs){:target="_blank" rel="noopener"}
    - support is very limited, and tested only with `:httpc.request/1` and `:httpc.request/4`.
  - [Finch](https://github.com/keathley/finch){:target="_blank" rel="noopener"}
    - the deprecated `Finch.request/6` functions is not supported

HTTP interactions are recorded as JSON file. The JSON file can be recorded
automatically (`vcr_cassettes`) or manually updated (`custom_cassettes`).

### Notes

- `ExVCR.Config` functions must be called from `setup` or `test`. Calls outside
  of test process, such as in `setup_all` will not work.

### Install

Add `:exvcr` to `deps` section of `mix.exs`.

```elixir
def deps do
  [ {:exvcr, "~> 0.11", only: :test} ]
end
```

Optionally, `preferred_cli_env: [vcr: :test]` can be specified for running `mix
vcr` in `:test` env by default.

```elixir
def project do
  [ ...
    preferred_cli_env: [
      vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
    ],
    ...
end
```

### Usage

Add `use ExVCR.Mock` to the test module. This mocks `ibrowse` by default. For
using `hackney`, specify `adapter: ExVCR.Adapter.Hackney` options as follows.

##### Example with ibrowse

```elixir
defmodule ExVCR.Adapter.IBrowseTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "example single request" do
    use_cassette "example_ibrowse" do
      :ibrowse.start
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "httpotion" do
    use_cassette "example_httpotion" do
      HTTPotion.start
      assert HTTPotion.get("http://example.com", []).body =~ ~r/Example Domain/
    end
  end
end
```

##### Example with hackney

```elixir
defmodule ExVCR.Adapter.HackneyTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
    :ok
  end

  test "get request" do
    use_cassette "httpoison_get" do
      assert HTTPoison.get!("http://example.com").body =~ ~r/Example Domain/
    end
  end
end
```

##### Example with httpc

```elixir
defmodule ExVCR.Adapter.HttpcTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup_all do
    :inets.start
    :ok
  end

  test "get request" do
    use_cassette "example_httpc_request" do
      {:ok, result} = :httpc.request('http://example.com')
      {{_http_version, _status_code = 200, _reason_phrase}, _headers, body} = result
      assert to_string(body) =~ ~r/Example Domain/
    end
  end
end
```

##### Example with Finch

```elixir
defmodule ExVCR.Adapter.FinchTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  setup_all do
    Finch.start_link(name: MyFinch)
    :ok
  end

  test "get request" do
    use_cassette "example_finch_request" do
      {:ok, response} = Finch.build(:get, "http://example.com/") |> Finch.request(MyFinch)
      assert response.status == 200
      assert Map.new(response.headers)["content-type"] == "text/html; charset=UTF-8"
      assert response.body =~ ~r/Example Domain/
    end
  end
end
```

#### Example with Start / Stop

Instead of single `use_cassette`, `start_cassette` and `stop_cassette` can serve as an alternative syntax.

```elixir
use_cassette("x") do
  do_something
end
```

```elixir
start_cassette("x")
do_something
stop_cassette
```

#### Custom Cassettes

You can manually define custom cassette JSON file for more flexible response
control rather than just recoding the actual server response.

- Optional 2nd parameter of `ExVCR.Config.cassette_library_dir` method
  specifies the custom cassette directory. The directory is separated from vcr
  cassette one for avoiding mistakenly overwriting.

- Adding `custom: true` option to `use_cassette` macro indicates to use the
  custom cassette, and it just returns the pre-defined JSON response, instead
  of requesting to server.


```elixir
defmodule ExVCR.MockTest do
  use ExUnit.Case, async: true
  import ExVCR.Mock

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "custom with valid response" do
    use_cassette "response_mocking", custom: true do
      assert HTTPotion.get("http://example.com", []).body =~ ~r/Custom Response/
    end
  end
```

The custom JSON file format is the same as vcr cassettes.

**fixture/custom_cassettes/response_mocking.json**
```javascript
[
  {
    "request": {
      "url": "http://example.com"
    },
    "response": {
      "status_code": 200,
      "headers": {
        "Content-Type": "text/html"
      },
      "body": "<h1>Custom Response</h1>"
    }
  }
]
```

### Recording VCR Cassettes

#### Matching

ExVCR uses URL parameter to match request and cassettes. The `url` parameter in
the JSON file is taken as regexp string.

#### Removing Sensitive Data

`ExVCR.Config.filter_sensitive_data(pattern, placeholder)` method can be used
to remove sensitive data. It searches for string matches with `pattern`, which
is a string representing a regular expression, and replaces with `placeholder`.
Replacements happen both in URLs and request and response bodies.

```elixir
test "replace sensitive data" do
  ExVCR.Config.filter_sensitive_data("<PASSWORD>.+</PASSWORD>", "PLACEHOLDER")
  use_cassette "sensitive_data" do
    assert HTTPotion.get("http://something.example.com", []).body =~ ~r/PLACEHOLDER/
  end
end
```

`ExVCR.Config.filter_request_headers(header)` and
`ExVCR.Config.filter_request_options(option)` can be used to remove sensitive
data in the request headers. It checks if the `header` is found in the request
headers and blanks out it's value with `***`.

```elixir
test "replace sensitive data in request header" do
  ExVCR.Config.filter_request_headers("X-My-Secret-Token")
  use_cassette "sensitive_data_in_request_header" do
    body = HTTPoison.get!("http://localhost:34000/server?", ["X-My-Secret-Token": "my-secret-token"]).body
    assert body == "test_response"
  end

  # The recorded cassette should contain replaced data.
  cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_header.json")
  assert cassette =~ "\"X-My-Secret-Token\": \"***\""
  refute cassette =~  "\"X-My-Secret-Token\": \"my-secret-token\""

  ExVCR.Config.filter_request_headers(nil)
end
```

```elixir
test "replace sensitive data in request options" do
  ExVCR.Config.filter_request_options("basic_auth")
  use_cassette "sensitive_data_in_request_options" do
    body = HTTPoison.get!(@url, [], [hackney: [basic_auth: {"username", "password"}]]).body
    assert body == "test_response"
  end

  # The recorded cassette should contain replaced data.
  cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_options.json")
  assert cassette =~ "\"basic_auth\": \"***\""
  refute cassette =~  "\"basic_auth\": {\"username\", \"password\"}"

  ExVCR.Config.filter_request_options(nil)
end
```

#### Allowed hosts

The `:ignore_urls` can be used to allow requests to be made to certain hosts.

```elixir
setup do
  ExVCR.Setting.set(:ignore_urls, [~/example.com/])
  ExVCR.Setting.append(:ignore_urls, ~/anotherurl.com/)
end

test "an actual request is made to example.com" do
  HTTPoison.get!("https://example.com/path?query=true")
  HTTPoison.get!("https://anotherurl.com/path?query=true")
end
```

#### Ignoring query params in URL

If `ExVCR.Config.filter_url_params(true)` is specified, query params in URL
will be ignored when recording cassettes.

```elixir
test "filter url param flag removes url params when recording cassettes" do
  ExVCR.Config.filter_url_params(true)
  use_cassette "example_ignore_url_params" do
    assert HTTPotion.get(
      "http://localhost:34000/server?should_not_be_contained", []).body =~ ~r/test_response/
  end
  json = File.read!("#{__DIR__}/../#{@dummy_cassette_dir}/example_ignore_url_params.json")
  refute String.contains?(json, "should_not_be_contained")
```

#### Removing headers from response

If `ExVCR.Config.response_headers_blacklist(headers_blacklist)` is specified,
the headers in the list will be removed from the response.

```elixir
test "remove blacklisted headers" do
  use_cassette "original_headers" do
    assert Map.has_key?(HTTPoison.get!(@url, []).headers, "connection") == true
  end

  ExVCR.Config.response_headers_blacklist(["Connection"])
  use_cassette "remove_blacklisted_headers" do
    assert Map.has_key?(HTTPoison.get!(@url, []).headers, "connection") == false
  end

  ExVCR.Config.response_headers_blacklist([])
end
```

#### Matching Options

##### Matching against query params

By default, query params are not used for matching. In order to include query
params, specify `match_requests_on: [:query]` for `use_cassette` call.

```elixir
test "matching query params with match_requests_on params" do
  use_cassette "different_query_params", match_requests_on: [:query] do
    assert HTTPotion.get("http://localhost/server?p=3", []).body =~ ~r/test_response3/
    assert HTTPotion.get("http://localhost/server?p=4", []).body =~ ~r/test_response4/
  end
end
```

##### Matching against request body

By default, request body is not used for matching. In order to include request
body, specify `match_requests_on: [:request_body]` for `use_cassette` call.

```elixir
test "matching request body with match_requests_on params" do
  use_cassette "different_request_body_params", match_requests_on: [:request_body] do
    assert HTTPotion.post("http://localhost/server", [body: "p=3"]).body =~ ~r/test_response3/
    assert HTTPotion.post("http://localhost/server", [body: "p=4"]).body =~ ~r/test_response4/
  end
end
```

##### Matching against custom parameters

You can define and use your own matchers for cases not covered by the build-in
matchers. To do this you can specify `custom_matchers: [func_one, func_two, ...]`
for `use_cassette` call.

```elixir
test "matching special header with custom_matchers" do
  matches_special_header = fn response, keys, _recorder_options ->
    recorded_headers = always_map(response.request.headers)
    expected_value = recorded_headers["X-Special-Header"]
    keys[:headers]
    |> Enum.any?(&(match?({"X-Special-Header", ^expected_value}, &1)))
  end

  use_cassette "special_header_match", custom_matchers: [matches_special_header] do
    # These two requests will match with each other since our custom matcher matches (even if without matching all headers)
    assert HTTPotion.post("http://localhost/server",
        [headers: ["User-Agent": "My App", "X-Special-Header": "Value One"]]).body =~ ~r/test_response_one/
    assert HTTPotion.post("http://localhost/server",
        [headers: ["User-Agent": "Other App", "X-Special-Header": "Value One"]]).body =~ ~r/test_response_one/

    # This will not match since the header has a different value:
    assert HTTPotion.post("http://localhost/server",
        [headers: ["User-Agent": "My App", "X-Special-Header": "Value Two"]]).body =~ ~r/test_response_two/
  end
end
```

### Default Config

Default parameters for `ExVCR.Config` module can be specified in
`config\config.exs` as follows.

```elixir
use Mix.Config

config :exvcr, [
  vcr_cassette_library_dir: "fixture/vcr_cassettes",
  custom_cassette_library_dir: "fixture/custom_cassettes",
  filter_sensitive_data: [
    [pattern: "<PASSWORD>.+</PASSWORD>", placeholder: "PASSWORD_PLACEHOLDER"]
  ],
  filter_url_params: false,
  filter_request_headers: [],
  response_headers_blacklist: []
]
```

If `exvcr` is defined as test-only dependency, describe the above statement in
test-only config file (ex. `config\test.exs`) or make it conditional (ex. wrap
with `if Mix.env == :test`).

### Global mock experimental feature

The global mock is an attempt to address a general issue with **exvcr being slow**, see [#107](https://github.com/parroty/exvcr/issues/107)

In general, every use_cassette takes around 500 ms so if you extensively use cassettes it could spend minutes doing `:meck.expect/2` and `:meck.unload/1`. Even `exvcr` tests  need 40 seconds versus 1 second when global mock is used.

Since feature is **experimental** be careful when using it. Please note the following:

- ExVCR implements global mock, which means that all HTTP client calls outside of `use_cassette` go through `meck.passthough/1`.
- There are some report that the feature doesn't work in some case, see [the issue](https://github.com/parroty/exvcr/issues/159).
- By default, the global mocking disabled, to enabled it set the following in config:

```elixir
use Mix.Config

config :exvcr, [
  global_mock: true
]
```

All tests that are written for `exvcr` could also be running in global mocking mode:

```
$ GLOBAL_MOCK=true mix test

.........................................................

Finished in 1.3 seconds
141 tests, 0 failures

Randomized with seed 905427
```

### Mix Tasks

The following tasks are added by including `exvcr` package.

- [mix vcr](#mix-vcr-show-cassettes)
- [mix vcr.delete](#mix-vcrdelete-delete-cassettes)
- [mix vcr.check](#mix-vcrcheck-check-cassettes)
- [mix vcr.show](#mix-vcrshow-show-cassettes)
- [mix vcr --help](#mix-vcr-help-help)

#### [mix vcr] Show cassettes

```shell
$ mix vcr
Showing list of cassettes in [fixture/vcr_cassettes]
  [File Name]                              [Last Update]
  example_httpotion.json                   2013/11/07 23:24:49
  example_ibrowse.json                     2013/11/07 23:24:49
  example_ibrowse_multiple.json            2013/11/07 23:24:48
  httpotion_delete.json                    2013/11/07 23:24:47
  httpotion_patch.json                     2013/11/07 23:24:50
  httpotion_post.json                      2013/11/07 23:24:51
  httpotion_put.json                       2013/11/07 23:24:52

Showing list of cassettes in [fixture/custom_cassettes]
  [File Name]                              [Last Update]
  method_mocking.json                      2013/10/06 22:05:38
  response_mocking.json                    2013/09/29 17:23:38
  response_mocking_regex.json              2013/10/06 18:13:45
```

#### [mix vcr.delete] Delete cassettes

The `mix vcr.delete` task deletes the cassettes that contains the specified
pattern in the file name.

```shell
$ mix vcr.delete ibrowse
Deleted example_ibrowse.json.
Deleted example_ibrowse_multiple.json.
```

If `-i` (`--interactive`) option is specified, it asks for confirmation before
deleting each file.

```shell
$ mix vcr.delete ibrowse -i
delete example_ibrowse.json? y
Deleted example_ibrowse.json.
delete example_ibrowse_multiple.json? y
Deleted example_ibrowse_multiple.json.
```

If `-a` (`--all`) option is specified, all the cassettes in the specified folder
becomes the target for delete.

#### [mix vcr.check] Check cassettes

The `mix vcr.check` shows how many times each cassette is applied while
executing `mix test` tasks. It is intended for verifying  the cassettes are
properly used. `[Cassette Counts]` indicates the count that the pre-recorded
JSON cassettes are applied. `[Server Counts]` indicates the count that server
access is performed.

```shell
$ mix vcr.check
...............................
31 tests, 0 failures
Showing hit counts of cassettes in [fixture/vcr_cassettes]
  [File Name]                              [Cassette Counts]    [Server Counts]
  example_httpotion.json                   1                    0
  example_ibrowse.json                     1                    0
  example_ibrowse_multiple.json            2                    0
  httpotion_delete.json                    1                    0
  httpotion_patch.json                     1                    0
  httpotion_post.json                      1                    0
  httpotion_put.json                       1                    0
  sensitive_data.json                      0                    2
  server1.json                             0                    2
  server2.json                             2                    2

Showing hit counts of cassettes in [fixture/custom_cassettes]
  [File Name]                              [Cassette Counts]    [Server Counts]
  method_mocking.json                      1                    0
  response_mocking.json                    1                    0
  response_mocking_regex.json              1                    0
```

The target test file can be limited by specifying test files, as similar as
`mix test` tasks.

```shell
$ mix vcr.check test/exvcr_test.exs
.............
13 tests, 0 failures
Showing hit counts of cassettes in [fixture/vcr_cassettes]
  [File Name]                              [Cassette Counts]    [Server Counts]
  example_httpotion.json                   1                    0
...
...
```

#### [mix vcr.show] Show cassettes

The `mix vcr.show` task displays the contents of cassettes JSON file in the
prettified format.

```shell
$ mix vcr.show fixture/vcr_cassettes/httpoison_get.json
[
  {
    "request": {
      "url": "http://example.com",
      "headers": [],
      "method": "get",
      "body": "",
      "options": []
    },
...
```

#### [mix vcr --help] Help

Displays helps for mix sub-tasks.

```shell
$ mix vcr --help
Usage: mix vcr [options]
  Used to display the list of cassettes

  -h (--help)         Show helps for vcr mix tasks
  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory

Usage: mix vcr.delete [options] [cassette-file-names]
  Used to delete cassettes

  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory
  -i (--interactive)  Request confirmation before attempting to delete
  -a (--all)          Delete all the files by ignoring specified [filenames]

Usage: mix vcr.check [options] [test-files]
  Used to check cassette use on test execution

  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory

Usage: mix vcr.show [cassette-file-names]
  Used to show cassette contents

```

##### Notes

If the cassette save directory is changed from the default, [`-d`, `--dir`] option
(for vcr cassettes) and [`-c`, `--custom`] option (for custom cassettes) can be
used to specify the directory.

### IEx Helper

`ExVCR.IEx` module provides simple helper functions to display the HTTP
request/response in JSON format, instead of recording in the cassette files.

```elixir
% iex -S mix
Erlang R16B03 (erts-5.10.4) ...
Interactive Elixir (0.12.5) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> require ExVCR.IEx
nil
iex(2)> ExVCR.IEx.print do
...(2)>   :ibrowse.send_req('http://example.com', [], :get)
...(2)> end
[
  {
    "request": {
      "url": "http://example.com",
      "headers": [],
      "method": "get",
      "body": "",
      "options": []
    },
    "response": {
      "type": "ok",
      "status_code": 200,
...
```

The adapter option can be specified as `adapter` argument of print function, as
follows.

```elixir
% iex -S mix
Erlang R16B03 (erts-5.10.4) ...

Interactive Elixir (0.12.5) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> require ExVCR.IEx
nil
iex(2)> ExVCR.IEx.print(adapter: ExVCR.Adapter.Hackney) do
...(2)>   HTTPoison.get!("http://example.com").body
...(2)> end
[
  {
    "request": {
      "url": "http://example.com",
...
```

### Stubbing Response

Specifying `:stub` as fixture name allows directly stubbing the response
header/body information based on parameter.

```elixir
test "stub request works for HTTPotion" do
  use_cassette :stub, [url: "http://example.com", body: "Stub Response", status_code: 200] do
    response = HTTPotion.get("http://example.com", [])
    assert response.body =~ ~r/Stub Response/
    assert response.headers[:"Content-Type"] == "text/html"
    assert response.status_code == 200
  end
end

test "stub request works for HTTPoison" do
  use_cassette :stub, [url: "http://www.example.com", body: "Stub Response"] do
    response = HTTPoison.get!("http://www.example.com")
    assert response.body =~ ~r/Stub Response/
    assert response.headers["Content-Type"] == "text/html"
    assert response.status_code == 200
  end
end

test "stub request works for httpc" do
  use_cassette :stub, [url: "http://www.example.com",
                       method: "get",
                       status_code: ["HTTP/1.1", 200, "OK"],
                       body: "success!"] do

  {:ok, result} = :httpc.request('http://example.com')
  {{_http_version, _status_code = 200, _reason_phrase}, _headers, body} = result
  assert to_string(body) == "success!"
end

test "stub request works for Finch" do
  use_cassette :stub, [url: "http://www.example.com",
                       method: "get",
                       status_code: 200,
                       body: "Stub Response"] do

  {:ok, response} = Finch.build(:get, "http://example.com/") |> Finch.request(MyFinch)
  assert response.body =~ ~r/Stub Response/
  assert Map.new(response.headers)["content-type"] == "text/html"
  assert response.status_code == 200
end

test "stub multiple requests works on Finch" do
  stubs = [
    [url: "http://example.com/1", body: "Stub Response 1", status_code: 200],
    [url: "http://example.com/2", body: "Stub Response 2", status_code: 404]
  ]

  use_cassette :stub, stubs do
    {:ok, response} = Finch.build(:get, "http://example.com/1") |> Finch.request(ExVCRFinch)
    assert response.status == 200
    assert response.body =~ ~r/Stub Response 1/

    {:ok, response} = Finch.build(:get, "http://example.com/2") |> Finch.request(ExVCRFinch)
    assert response.status == 404
    assert response.body =~ ~r/Stub Response 2/
  end
end
```

If the specified `:url` parameter doesn't match requests called inside the
`use_cassette` block, it raises `ExVCR.InvalidRequestError`.

The `:url` can be regular expression string. Please note that you should use
the `~r` sigil with `/` as delimiters.

```elixir
test "match URL with regular expression" do
  use_cassette :stub, [url: "~r/(foo|bar)/", body: "Stub Response", status_code: 200] do
    # ...
  end
end

test "make sure to properly escape the /" do
  # escape /path/to/file
  use_cassette :stub, [url: "~r/\/path\/to\/file", body: "Stub Response", status_code: 200] do
    # ...
  end
end

test "the sigil delimiter cannot be anything else" do
  use_cassette :stub, [url: "~r{this-delimiter-doesn-not-work}", body: "Stub Response", status_code: 200] do
    # ...
  end
end
```

### TODO

- Improve performance, as it's very slow.
