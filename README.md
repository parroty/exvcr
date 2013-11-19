# ExVCR [![Build Status](https://secure.travis-ci.org/parroty/exvcr.png?branch=master "Build Status")](http://travis-ci.org/parroty/exvcr) [![Coverage Status](https://coveralls.io/repos/parroty/exvcr/badge.png?branch=master)](https://coveralls.io/r/parroty/exvcr?branch=master)


Record and replay HTTP interactions library for elixir.
It's inspired by Ruby's VCR (https://github.com/vcr/vcr), and trying to provide similar functionalities.

### Notes

- It only supports :ibrowse based HTTP interaction at the moment.
- HTTP interactions are recorded as JSON file.
    - The JSON file can be recorded automatically (vcr_cassettes) or manually updated (custom_cassettes)


### Usage
#### Code

```Elixir
defmodule ExVCR.MockTest do
  use ExUnit.Case
  import ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "example single request" do
    use_cassette "example_ibrowse" do
      :ibrowse.start
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert iolist_to_binary(body) =~ %r/Example Domain/
    end
  end

  test "httpotion" do
    use_cassette "example_httpotion" do
      assert HTTPotion.get("http://example.com", []).body =~ %r/Example Domain/
    end
  end
end
```

#### Custom Cassettes
Custom cassette can be defined in json format, by adding 2nd parameter of ExVCR.Config.cassette_library_dir method.

```Elixir
defmodule ExVCR.MockTest do
  use ExUnit.Case
  import ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end
```

ExVCR uses url parameter to match request and cassettes. The "url" parameter in the json file is taken as regexp string.

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

#### Removing Sensitive Data
ExVCR.Config.filter_sensitive_data method can be used to remove sensitive data

```elixir
test "replace sensitive data" do
  ExVCR.Config.filter_sensitive_data("<PASSWORD>.+</PASSWORD>", "PLACEHOLDER")
  use_cassette "sensitive_data" do
    assert HTTPotion.get("http://something.example.com", []).body =~ %r/PLACEHOLDER/
  end
end
```

### Mix Tasks
- [mix vcr](#mix-vcr-show-cassettes)
- <del>[mix vcr.custom](#mix-vcr-show-cassettes)</del>
- [mix vcr.delete](#mix-vcrdelete-delete-cassettes)
- [mix vcr.check](#mix-vcrcheck-check-cassettes)

#### [mix vcr] Show cassettes
```Shell
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

#### <del>[mix vcr.custom] Show custom cassettes</del>
DEPRECATED: To be removed.

The [mix vcr.custom] task shows the list of the manually created custom cassettes.
```Shell
$ mix vcr.custom
Showing list of cassettes in [fixture/custom_cassettes]
  [File Name]                              [Last Update]
  method_mocking.json                      2013/10/06 22:05:38
  response_mocking.json                    2013/09/29 17:23:38
  response_mocking_regex.json              2013/10/06 18:13:45
```

#### [mix vcr.delete] Delete cassettes
The [mix vcr.delete] task deletes the cassettes that contains the specified pattern in the file name.
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
The [mix vcr.check] shows how many times each cassette is applied while executing [mix test] tasks. It is intended for verifying the cassettes are properly used.

```Shell
$ mix vcr.check
...............................
31 tests, 0 failures
Showing hit counts of cassettes in [fixture/vcr_cassettes]
  [File Name]                              [Hit Counts]
  example_httpotion.json                   1
  example_ibrowse.json                     1
  example_ibrowse_multiple.json            2
  httpotion_delete.json                    1
  httpotion_patch.json                     1
  httpotion_post.json                      1
  httpotion_put.json                       1

Showing hit counts of cassettes in [fixture/custom_cassettes]
  [File Name]                              [Hit Counts]
  method_mocking.json                      1
  response_mocking.json                    1
  response_mocking_regex.json              1
```

The target test file can be limited by specifying test files, as similar as [mix test] tasks.

```Shell
$ mix vcr.check test/exvcr_test.exs
.............
13 tests, 0 failures
Showing hit counts of cassettes in [fixture/vcr_cassettes]
  [File Name]                              [Hit Counts]
  example_httpotion.json                   1
...
```

##### Notes
If the cassette save directory is changed from the default, [-d, --dir] option (for vcr cassettes) and [-c, --custom] option (for custom cassettes) can be used to specify the directory.
