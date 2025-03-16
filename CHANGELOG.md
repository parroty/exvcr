0.17.0
------
#### Changes
* Move preferred_cli_env into def cli (#230).
* Update locked dependencies (#232).
* Format code and ensure formatting in CI (#234).

0.16.0
------
#### Changes
* Remove exactor dependency (#228).

0.15.2
------
#### Changes
* Remove kramdown syntax from links (#222).

0.15.1
------
#### Changes
* Fix upstream warnings under Elixir 1.16 (#215).

0.15.0
------
#### Enhancements
* Support for Multiple Stub Requests (#216).

#### Changes
* Fix match request body json otp26 (#213).
* Fix typos for documentation and missing json-parsed body in `mix vcr.show`.
  - Fix typos (#214).
* Update dependency - excoveralls 0.18.0 (#217).

0.14.4
------
#### Changes
* Normalizes request body and URL by parsing params to a list and sorting (#211)
  - Fix for OTP 26 (map key order is not guaranteed)

0.14.3
------
#### Enhancements
* Allow numeric options for Filter.filter_sensitive_data/1 (#209).

0.14.2
------
#### Changes
* Fix Elixir 1.14 warnings (#207).

0.14.1
------
#### Changes
* Fix compilation in project lacking Finch (#205).

0.14.0
------
#### Enhancements
* Add start_cassette / stop_cassette macro (#199).
* Support Finch request! function (#197).

0.13.5
------
#### Changes
* Adds httpoison ~> 2.0 support (#196).

0.13.4
------
#### Enhancements
* Add additional information to the InvalidRequestError message (#188).

#### Changes
* Allow append to be passed to a previously nil setting.
    - Better document the ignore_urls setting (#187).
* Resolve Duplicate Docs Warnings (#180).

0.13.3
------
#### Changes
* Update dependency.
    - Relax dependency constraint on Finch (#182).

0.13.2
------
#### Changes
* Fix for Finch support.
    - Define Finch adapter conditionally to fix compile error (#178).

0.13.1
------
#### Enhancements
* Add Finch support (#175).

0.13.0
------
#### Changes
* Update meck to fix failing tests (#173).

0.12.3
------
#### Enhancements
* Add support to ignore_urls (#168).

#### Changes
* Fix sanitize options function in hackney adapter converter (#169).

0.12.2
------
#### Changes
* Misc HTML doc generation changes (#161).
* Fix CurrentRecorder initial state (#163).

0.12.1
------
#### Changes
* Make global mock experimental feature and disable it by default (#159, #160).

0.12.0
------
#### Enhancements
* Fix for the following points.
   - Slow (#107).
   - Use global mock in adapters (#158).

0.11.2
------
#### Changes
* Fix for ExVCR.IEx not working with adapter: ExVCR.Adapter.Hackney (#156, #157).

0.11.1
------
#### Enhancements
* Add strict_mode option to ensure HTTP calls DO NOT get made (#152).

#### Changes
* Fix warnings from OptionParser in exvcr mix tasks (#149).

0.11.0
------
#### Enhancements
* Add support for custom matcher functions (#147).

#### Changes
* Filter request headers before attempting to match with cassette (#143).

0.10.4
------
#### Changes
* Enforce match on :hackney.request/1, /2, /3 and /4 (#145).

0.10.3
------
#### Changes
* Add mocking for :hackney.body/2 (#142).
* Fix errors when using request headers with ignore_localhost enabled (#140).
* Add a config key to allow a global ets settings table (#138).

0.10.2
------
#### Enhancements
* Add ignore_localhost config option (#133).

0.10.1
------
#### Changes
* Update dependencies.
    - Bump dependencies (#128).
    - Update HTTPoison dependency (#129).

0.10.0
------
#### Changes
* Fix unstable behavior without `async: false` (#126).

0.9.1
------
#### Enhancements
* Support binary responses (#121).

#### Changes
* Fix race conditions in Hackney response handling (#109, #124).

0.9.0
------
#### Changes
* Update dependencies for elixir v1.5.0.
    - Address deprecations (#120).
    - Update library dependencies.

0.8.12
------
#### Changes
* Upgrade version for exjsx and excoveralls (#115).
* Fix for JSX encode argument error (#112).
    - Skipping function option (ex. `path_encode_fun`) when encoding as json.

0.8.11
------
#### Changes
* Adds filter_request_headers to default parameters (#111).
* Ensure clear_mock runs after each test (#114).

0.8.10
------
#### Changes
* Fix for TLS 1.2 ssl doesn't work for hackney (httpoison) (#105).

0.8.9
------
#### Enhancements
* Adding filter_request_options to filter sensitive data in request options (#102).

0.8.8
------
#### Enhancements
* Fix error when using basic_auth header.
    - Add basic_auth support for ibrowse (#99).

0.8.7
------
#### Enhancements
* Add support for HEAD request in hackney (#91).

0.8.6
------
#### Changes
* Ignore body when when stub does not have request_body (#89).
* Fix load configuration for cassette paths for mix tasks (#82, #88).

0.8.5
------
#### Changes
* Tidy up the applications list (#87).
   - Fix for inappropriate startup for test-library dependency.
* Remove elixir 1.4 deprecations (#86).

0.8.4
------
#### Changes
* Fix hackney adapter to work with `:with_body` option (#79).

0.8.3
------
#### Changes
* Include request info when NotMatchError occurs (#74).

0.8.2
------
#### Enhancements
* Support filtering on request headers.
    - Add ExVCR.Filter.filter_request_header (#71).

0.8.1
------
#### Changes
* Fix warnings when using elixir v1.4 (#65).

0.8.0
------
#### Changes
* Update dependencies.
    - Update httpotion dependency to 3.0 (#63).

#### Enhancements
* Support regexp request_body pattern (#62).

0.7.4
------
#### Changes
* Ensure blacklist header check is case insensitive (#59).

0.7.3
------
#### Enhancements
* Allow matching requests by headers (#56).

#### Changes
* Fix error at [mix vcr] task when cassette directory does not exist (skip instead of raising errors).
    - Running `mix vcr` without custom cassette folder gives annoying message (#49).
* Fix for duplicated/unnecessary directory creation.
    - Fix configuring cassette_library_dir (#50).
* Fix cached status code for ibrowse (#57).

0.7.2
------
#### Enhancements
* Support recording/replaying gzipped response.
    - Gzipped response body (#46).

0.7.1
------
#### Enhancements
* Support config parameters in config.exs (#37).

#### Changes
* Fix wrong request arguments handling for httpc adapter (#38).

0.7.0
------
#### Changes
* Fix handling for response sequence (#35).
    - If recorded cassettes contain multiple HTTP interactions that match a request, the returned responses are now sequenced.
    - It can break the existing cassettes in certain condition. If error occurred, please try re-recording the cassettes.

0.6.1
------
#### Changes
* Fix for Protocol.UndefinedError when using :multipart with :hackney (#34).

0.6.0
------
#### Changes
* Update dependency module versions.

0.5.2
------
#### Enhancements
* Make the return value from use_cassette block available (#17).

#### Changes
* Exclude `:custom` mode from applying `match_requests_on: [:request_body]` by default.
    - Make it only applies to `:stub` mode, as it breaks existing custom cassettes.
* Avoid throwing Argument Error when option contains tuple (#30).

0.5.1
------
#### Enhancements
* Support matching on request body (#22, #29).
    - match_requests_on: [:request_body]

0.5.0
------
#### Changes
* Update HTTPotion and HTTPoison dependencies (#27).
* Put `:optional` option to HTTPoison dependency.

0.4.1
------
#### Enhancements
* Support for POST requests with form-encoded data in the hackney adapter (#25).
* Support for `filter_sensitive_data` for request url (#26).

0.4.0
------
#### Enhancements
* The `use_cassette` with `custom: true` or `:stub` option can now have either string or regexp format (#13).
    - This item involves json format change. In order to use regexp matching, please wrap the string with "~/" prefix and "/" suffix (ex. "~/regexpstring/")
