# ExVCR [![Build Status](https://secure.travis-ci.org/parroty/exvcr.png?branch=master "Build Status")](http://travis-ci.org/parroty/exvcr) [![Coverage Status](https://coveralls.io/repos/parroty/exvcr/badge.png?branch=master)](https://coveralls.io/r/parroty/exvcr?branch=master)


Record and replay HTTP interactions library for elixir.
It's inspired by Ruby's VCR (https://github.com/vcr/vcr), and trying to provide similar functionalities.

### Basics

- The following HTTP libraries can be applied.
    - <a href="https://github.com/cmullaparthi/ibrowse" target="_blank">ibrowse</a>-based libraries.
        - <a href="https://github.com/myfreeweb/httpotion" target="_blank">HTTPotion</a>
    - <a href="https://github.com/benoitc/hackney" target="_blank">hackney</a>-based libraries.
        - <a href="https://github.com/edgurgel/httpoison" target="_blank">HTTPoison</a>
        - support is very limited, and tested only with sync request of HTTPoison yet.
    - <a href="http://erlang.org/doc/man/httpc.html" target="_blank">httpc</a>-based libraries.
        - <a href="https://github.com/tim/erlang-oauth/" target="_blank">erlang-oauth</a>
        - support is very limited, and tested only with :httpc.request/1 and :httpc.request/4

- HTTP interactions are recorded as JSON file.
    - The JSON file can be recorded automatically (vcr_cassettes) or manually updated (custom_cassettes)

### Notes for v0.1.0 or later
Please specify `use ExVCR.Mock` instead of `import ExVCR.Mock`. Otherwise, `(CompileError) ***: function adapter/0 undefined` might be displayed.

### Usage
- Add `use ExVCR.Mock` to the test module. This mocks ibrowse by default. For using hackney, specify `adapter: ExVCR.Adapter.Hackney` options as follows.

##### Example with ibrowse
```Elixir
defmodule ExVCR.Adapter.IBrowseTest do
  use ExUnit.Case
  use ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "example single request" do
    use_cassette "example_ibrowse" do
      :ibrowse.start
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert to_string(body) =~ %r/Example Domain/
    end
  end

  test "httpotion" do
    use_cassette "example_httpotion" do
      HTTPotion.start
      assert HTTPotion.get("http://example.com", []).body =~ %r/Example Domain/
    end
  end
end
```

##### Example with hackney
```Elixir
defmodule ExVCR.Adapter.HackneyTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "get request" do
    use_cassette "httpoison_get" do
      assert HTTPoison.get("http://example.com").body =~ %r/Example Domain/
    end
  end
end
```

##### Example with httpc
```Elixir
defmodule ExVCR.Adapter.HttpcTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup_all do
    :inets.start
  end

  test "get request" do
    use_cassette "example_httpc_request" do
      {:ok, {{_http_version, status_code = 200, _reason_phrase}, headers, body}} = :httpc.request('http://example.com')
      assert to_string(body) =~ %r/Example Domain/
    end
  end
```

#### Custom Cassettes
You can manually define custom cassette json file for more flexible response control rather than just recoding the actual server response.
- Optional 2nd parameter of `ExVCR.Config.cassette_library_dir` method specifies the custom cassette directory. The directory is separated from vcr cassette one for avoiding mistakenly overwriting.
- Adding `custom: true` option to `use_cassette` macro indicates to use the custom cassette, and it just returns the pre-defined json response, instead of requesting to server.


```Elixir
defmodule ExVCR.MockTest do
  use ExUnit.Case
  import ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "custom with valid response" do
    use_cassette "response_mocking", custom: true do
      assert HTTPotion.get("http://example.com", []).body =~ %r/Custom Response/
    end
  end
```

The custom json file format is the same as vcr cassettes.

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
ExVCR uses url parameter to match request and cassettes. The "url" parameter in the json file is taken as regexp string.

#### Removing Sensitive Data
`ExVCR.Config.filter_sensitive_data(pattern, placeholder)` method can be used to remove sensitive data. It searches for string matches with `pattern` and replaces with `placeholder`.

```elixir
test "replace sensitive data" do
  ExVCR.Config.filter_sensitive_data("<PASSWORD>.+</PASSWORD>", "PLACEHOLDER")
  use_cassette "sensitive_data" do
    assert HTTPotion.get("http://something.example.com", []).body =~ %r/PLACEHOLDER/
  end
end
```

#### Ignoring query params in url
If `ExVCR.Config.filter_url_params(true)` is specified, query params in url will be ignored when recording cassettes.

```elixir
test "filter url param flag removes url params when recording cassettes" do
  ExVCR.Config.filter_url_params(true)
  use_cassette "example_ignore_url_params" do
    assert HTTPotion.get("http://localhost:34000/server?should_not_be_contained", []).body =~ %r/test_response/
  end
  json = File.read!("#{__DIR__}/../#{@dummy_cassette_dir}/example_ignore_url_params.json")
  refute String.contains?(json, "should_not_be_contained")
```

### Mix Tasks
The following tasks are added by including exvcr package.
- [mix vcr](#mix-vcr-show-cassettes)
- [mix vcr.delete](#mix-vcrdelete-delete-cassettes)
- [mix vcr.check](#mix-vcrcheck-check-cassettes)
- [mix vcr.show](#mix-vcrshow-show-cassettes)
- [mix vcr --help](#mix-vcr-help-help)

#### [mix vcr] Show cassettes
```Shell
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
The `mix vcr.delete` task deletes the cassettes that contains the specified pattern in the file name.
```Shell
$ mix vcr.delete ibrowse
Deleted example_ibrowse.json.
Deleted example_ibrowse_multiple.json.
```

If -i (--interactive) option is specified, it asks for confirmation before deleting each file.
```Shell
$ mix vcr.delete ibrowse -i
delete example_ibrowse.json? y
Deleted example_ibrowse.json.
delete example_ibrowse_multiple.json? y
Deleted example_ibrowse_multiple.json.
```

If -a (--all) option is specified, all the cassetes in the specified folder becomes the target for delete.

#### [mix vcr.check] Check cassettes
The `mix vcr.check` shows how many times each cassette is applied while executing `mix test` tasks. It is intended for verifying  the cassettes are properly used. `[Cassette Counts]` indicates the count that the pre-recorded json cassettes are applied. `[Server Counts]` indicates the count that server access is performed.

```Shell
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

The target test file can be limited by specifying test files, as similar as `mix test` tasks.

```Shell
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
The `mix vcr.show` task displays the contents of cassettes json file in the prettified format.

```Shell
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

```Shell
$ mix vcr --help
Usage: mix vcr [options]
  Used to display the list of cassettes

  -h (--help)         Show helps for vcr mix tasks
  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory

Usage: mix vcr.delete [options] [cassete-file-names]
  Used to delete cassettes

  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory
  -i (--interactive)  Request confirmation before attempting to delete
  -a (--all)          Delete all the files by ignoring specified [filenames]

Usage: mix vcr.check [options] [test-files]
  Used to check cassette use on test execution

  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory

Usage: mix vcr.show [cassete-file-names]
  Used to show cassette contents

```


##### Notes
If the cassette save directory is changed from the default, [-d, --dir] option (for vcr cassettes) and [-c, --custom] option (for custom cassettes) can be used to specify the directory.

### TODO
- Improve performance, as it's very slow.
