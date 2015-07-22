0.4.1
------
#### Enhancements
* Support for POST requests with form-encoded data in the hackney adapter (#25).

0.4.0
------
#### Enhancements
* The `use_cassette` with `custom: true` or `:stub` option can now have either string or regexp format (#13).
    - This item involves json format change. In order to use regexp matching, please wrap the string with "~/" prefix and "/" suffix (ex. "~/regexpstring/")
