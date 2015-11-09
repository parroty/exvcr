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
