0.8.13
------
#### Changes
* Fix for JSX encode argument error (#112)
    - Skipping function option (ex. `path_encode_fun`) when encoding as json.

0.8.12
------
#### Changes
* Upgrade version for exjsx and excoveralls (#115)

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
